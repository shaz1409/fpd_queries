WITH
  dt_ccr_median_dates AS (
  SELECT
    *,
    DATE(EXTRACT(YEAR
      FROM
        month_beginning), EXTRACT(MONTH
      FROM
        month_beginning), CAST(CEIL((DATE_DIFF(DATE_TRUNC(DATE_ADD(month_beginning, INTERVAL 1 MONTH), MONTH), DATE_TRUNC(month_beginning, MONTH), DAY))/2) AS INT64)) AS median_date
  FROM
    UNNEST(GENERATE_DATE_ARRAY(DATE_TRUNC(DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR), YEAR), CURRENT_DATE, INTERVAL 1 MONTH)) month_beginning
  WHERE
    DATE(EXTRACT(YEAR
      FROM
        month_beginning), EXTRACT(MONTH
      FROM
        month_beginning), CAST(CEIL((DATE_DIFF(DATE_TRUNC(DATE_ADD(month_beginning, INTERVAL 1 MONTH), MONTH), DATE_TRUNC(month_beginning, MONTH), DAY))/2) AS INT64)) <= CURRENT_DATE )
SELECT
  DATE_TRUNC(dt_ccr_median_dates.median_date , MONTH) AS dt_ccr_start_month, -- previous code: (dt_ccr_median_dates.median_date ) AS dt_ccr_median_dates_median_date,
  ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE(CASE
                      WHEN ( dim_subscription.sub_productname IN ('Standard FT.com', 'Premium FT.com')) THEN dim_subscription.sub_core_readers_assetlevel
                    ELSE
                    NULL
                  END
                    ,0)*(1/1000*1.0), 9) AS NUMERIC) + (CAST(cast(CONCAT('0x', SUBSTR(TO_HEX(MD5(CAST(CASE
                                WHEN ( dim_subscription.sub_productname IN ('Standard FT.com', 'Premium FT.com')) THEN dim_subscription.orgarrangement_id_dd
                              ELSE
                              NULL
                            END
                              AS STRING))), 1, 15)) AS int64) AS numeric) * 4294967296 + CAST(cast(CONCAT('0x', SUBSTR(TO_HEX(MD5(CAST(CASE
                                WHEN ( dim_subscription.sub_productname IN ('Standard FT.com', 'Premium FT.com')) THEN dim_subscription.orgarrangement_id_dd
                              ELSE
                              NULL
                            END
                              AS STRING))), 16, 8)) AS int64) AS numeric)) * 0.000000001 )) - SUM(DISTINCT (CAST(cast(CONCAT('0x', SUBSTR(TO_HEX(MD5(CAST(CASE
                              WHEN ( dim_subscription.sub_productname IN ('Standard FT.com', 'Premium FT.com')) THEN dim_subscription.orgarrangement_id_dd
                            ELSE
                            NULL
                          END
                            AS STRING))), 1, 15)) AS int64) AS numeric) * 4294967296 + CAST(cast(CONCAT('0x', SUBSTR(TO_HEX(MD5(CAST(CASE
                              WHEN ( dim_subscription.sub_productname IN ('Standard FT.com', 'Premium FT.com')) THEN dim_subscription.orgarrangement_id_dd
                            ELSE
                            NULL
                          END
                            AS STRING))), 16, 8)) AS int64) AS numeric)) * 0.000000001) ) / (1/1000*1.0) AS NUMERIC), 0), 6) AS dim_subscription_latest_sub_total_core_readers
FROM
  `ft-lighthouse.lighthouse.dim_subscription` AS dim_subscription
INNER JOIN
  dt_ccr_median_dates
ON
  (DATE(dim_subscription.sub_enddate )) >= dt_ccr_median_dates.median_date
  AND (DATE(dim_subscription.sub_startdate )) < DATE_ADD(dt_ccr_median_dates.median_date, INTERVAL 1 DAY)
WHERE
  ((dim_subscription.accountname ) NOT LIKE '%Test Account%'
    AND (dim_subscription.accountname ) NOT LIKE '%B2B Staff%'
    AND (dim_subscription.accountname ) NOT LIKE '%- SSI%'
    AND (dim_subscription.accountname ) NOT LIKE '%-SSI%'
    OR (dim_subscription.accountname ) IS NULL)
  AND ((dim_subscription.sub_licencesolution ) <> 'Print Only Licence'
    OR (dim_subscription.sub_licencesolution ) IS NULL)
  AND ((dim_subscription.sub_productname ) <> 'Additional Distribution Rights'
    OR (dim_subscription.sub_productname ) IS NULL)
  AND ((( dt_ccr_median_dates.median_date ) >= '2022-01-01'
      AND ( dt_ccr_median_dates.median_date ) < ((DATE_ADD(DATE_TRUNC(CURRENT_DATE('UTC'), YEAR), INTERVAL 1 YEAR)))))
GROUP BY
  1
ORDER BY
  1
