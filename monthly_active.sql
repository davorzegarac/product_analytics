
-- DAU, Rolling-28 MAU, Rolling-7 WAU (code doesn't seem to be working properly, not sure why)
WITH dau_table AS (
  SELECT reporting_date:: DATE as dt, count(distinct uuid_hash) AS dau
  FROM public.dish_activity
  WHERE reporting_date > '2019-12-31'
  GROUP BY 1
  )
SELECT dt, dau,
       (SELECT count(distinct uuid_hash)
        FROM public.dish_activity
        WHERE reporting_date:: DATE BETWEEN a.dt - 28 AND a.dt) AS mau,
       (SELECT count(distinct uuid_hash)
        FROM public.dish_activity
        WHERE reporting_date:: DATE BETWEEN a.dt - 7 AND a.dt) AS wau
FROM dau_table a
