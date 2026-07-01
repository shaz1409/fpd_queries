DROP TABLE IF EXISTS bilayer.fpd_b2b_arpu_scheduled_query;

CREATE TABLE bilayer.fpd_b2b_arpu_scheduled_query AS
WITH RECURSIVE month_beginning(month_beginning) AS (
  SELECT DATE_TRUNC('year', DATEADD(year, -5, CURRENT_DATE))::DATE
  UNION ALL
  SELECT DATEADD(month, 1, month_beginning)::DATE
  FROM month_beginning
  WHERE month_beginning < CURRENT_DATE
),
dt_ccr_median_dates AS (
  SELECT
    month_beginning,
    DATEADD(
      day,
      CEIL(DATEDIFF(day, DATE_TRUNC('month', month_beginning), DATEADD(month, 1, DATE_TRUNC('month', month_beginning))) / 2.0)::INT - 1,
      DATE_TRUNC('month', month_beginning)
    )::DATE AS median_date
  FROM month_beginning
),
active_subscriptions AS (
  SELECT DISTINCT
    DATE_TRUNC('month', d.median_date)::DATE AS dt_ccr_start_month,
    dim_subscription.orgarrangement_id_dd,
    dim_subscription.sub_core_readers_assetlevel
  FROM lighthouse.dim_subscription AS dim_subscription
  INNER JOIN dt_ccr_median_dates d
    ON CAST(dim_subscription.sub_enddate AS DATE) >= d.median_date
    AND CAST(dim_subscription.sub_startdate AS DATE) < DATEADD(day, 1, d.median_date)
  WHERE
    (
      (dim_subscription.accountname) NOT LIKE '%Test Account%'
      AND (dim_subscription.accountname) NOT LIKE '%B2B Staff%'
      AND (dim_subscription.accountname) NOT LIKE '%- SSI%'
      AND (dim_subscription.accountname) NOT LIKE '%-SSI%'
      OR (dim_subscription.accountname) IS NULL
    )
    AND ((dim_subscription.sub_licencesolution) <> 'Print Only Licence'
      OR (dim_subscription.sub_licencesolution) IS NULL)
    AND ((dim_subscription.sub_productname) <> 'Additional Distribution Rights'
      OR (dim_subscription.sub_productname) IS NULL)
    AND dim_subscription.sub_productname IN ('Standard FT.com', 'Premium FT.com')
    AND d.median_date >= DATE '2022-01-01'
    AND d.median_date < DATEADD(year, 1, DATE_TRUNC('year', CURRENT_DATE))
)
SELECT
  dt_ccr_start_month,
  ROUND(COALESCE(SUM(sub_core_readers_assetlevel), 0), 6) AS dim_subscription_latest_sub_total_core_readers
FROM active_subscriptions
GROUP BY 1
ORDER BY 1;
