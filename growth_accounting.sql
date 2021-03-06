
-- retained
WITH monthly_activity as (
    SELECT DISTINCT
        DATE_TRUNC('month', Reporting_Date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE Reporting_Date > '2017-11-30')
SELECT
    DISTINCT this_month.month, count(distinct this_month.uuid_hash) as retained
FROM monthly_activity this_month
JOIN monthly_activity last_month
    ON this_month.uuid_hash = last_month.uuid_hash
    AND this_month.month = ADD_MONTHS(last_month.month, 1)
GROUP BY this_month.month
ORDER BY this_month.month

-- churned
WITH monthly_activity as (
    SELECT DISTINCT 
        DATE_TRUNC('month', reporting_date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE reporting_date > '2017-11-30')
SELECT
  ADD_MONTHS(last_month.month,1),
  -1*count(distinct last_month.uuid_hash) as churned
FROM monthly_activity last_month
LEFT JOIN monthly_activity this_month
  ON this_month.uuid_hash = last_month.uuid_hash
  AND this_month.month = ADD_MONTHS(last_month.month,1)
WHERE this_month.UUID_HASH is null
GROUP BY 1
ORDER BY 1

-- resurrected
WITH monthly_activity AS (
    SELECT DISTINCT 
        DATE_TRUNC('month', reporting_date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE reporting_date > '2017-10-31'
),
first_activity AS (
    SELECT DISTINCT uuid_hash, MIN(reporting_date) AS month
    FROM public.dish_activity
    WHERE reporting_date > '2017-11-30'
    GROUP BY 1
    ORDER BY 1
)
SELECT
  this_month.month as month,
  COUNT(distinct this_month.uuid_hash) AS new
FROM monthly_activity this_month
LEFT JOIN monthly_activity last_month
  ON this_month.uuid_hash = last_month.uuid_hash
  AND this_month.month = ADD_MONTHS(last_month.month,1)
JOIN first_activity
  ON this_month.uuid_hash = first_activity.uuid_hash
  AND first_activity.month = this_month.month
WHERE last_month.uuid_hash is null
GROUP BY 1
ORDER BY 1

-- new
WITH monthly_activity AS (
    SELECT DISTINCT 
        DATE_TRUNC('month', reporting_date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE reporting_date > '2017-10-31'
),
first_activity AS (
    SELECT DISTINCT uuid_hash, min(reporting_date) as month
    FROM public.dish_activity
    WHERE reporting_date > '2017-11-30'
    GROUP BY 1
    ORDER BY 1
)
SELECT
  this_month.month AS month,
  COUNT(DISTINCT this_month.uuid_hash) AS new
FROM monthly_activity this_month
LEFT JOIN monthly_activity last_month
  ON this_month.uuid_hash = last_month.uuid_hash
  AND this_month.month = ADD_MONTHS(last_month.month,1)
JOIN first_activity
  ON this_month.uuid_hash = first_activity.uuid_hash
  AND first_activity.month = this_month.month
WHERE last_month.uuid_hash is null
GROUP BY 1
ORDER BY 1
