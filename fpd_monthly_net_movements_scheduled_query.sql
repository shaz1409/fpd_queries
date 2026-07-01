WITH prospect_visitors AS (
  SELECT known_user_daily_status_is_recognised_user
, pageview_is_prospect_visit
, visit_time_stamp_utc_month
, pageview_user_cohort
, SUM(pageview_number_of_visitors) pageview_number_of_visitors
, SUM(pageview_number_of_devices) pageview_number_of_devices
 FROM `ft-bi-team.BI_layer_tables.fpd_prospect_visitors_scheduled_query` 
 WHERE pageview_user_cohort IN ("registered", "anonymous")
 GROUP BY 1, 2, 3, 4
),

cr_recognised_prospect AS --recognised prospect i.e., registered recognised

(SELECT 
  m.*
  , pageview_number_of_visitors
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query` m
LEFT JOIN prospect_visitors v 
  ON CAST(m.month AS STRING) = CAST(v.visit_time_stamp_utc_month AS STRING)
WHERE 
  (m.movement LIKE "reg-recognised_b2c%" OR m.movement LIKE "reg-recognised_b2b%" OR m.movement LIKE "reg-recognised_reg-%")
  AND v.known_user_daily_status_is_recognised_user = "Yes" 
  AND v.pageview_is_prospect_visit = "Yes"
  AND v.pageview_user_cohort = "registered"
  AND m.month NOT LIKE "%-%M"), 

cr_annon_prospect AS -- anonymous prospect i.e., unrecognised prospect 

(SELECT 
  m.*,
  pageview_number_of_visitors
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query` m
LEFT JOIN prospect_visitors v 
  ON CAST(m.month AS STRING) = CAST(v.visit_time_stamp_utc_month AS STRING)
WHERE 
  (v.known_user_daily_status_is_recognised_user = "No" 
  AND v.pageview_is_prospect_visit = "Yes"
  AND v.pageview_user_cohort = "anonymous")
  AND (m.movement LIKE "a_b2c%" OR m.movement LIKE "a_b2b%"OR m.movement LIKE "a_reg-%")
  AND m.month NOT LIKE "%-%M"), 

cr_registered_unrecognised_prospect AS -- registered unrecognised prospect i.e., unrecognised prospect 

(SELECT 
  m.*,
  pageview_number_of_visitors
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query` m
LEFT JOIN prospect_visitors v 
  ON CAST(m.month AS STRING) = CAST(v.visit_time_stamp_utc_month AS STRING)
WHERE 
  (v.known_user_daily_status_is_recognised_user = "No" 
  AND v.pageview_is_prospect_visit = "Yes"
  AND v.pageview_user_cohort = "registered")
  AND (m.movement LIKE "reg-unrecognised_b2c%" OR m.movement LIKE "reg-unrecognised_b2b%" OR m.movement LIKE "reg-unrecognised_reg-%")
  AND m.month NOT LIKE "%-%M"), 


movements_cr AS (SELECT 
*
, CASE WHEN pageview_number_of_visitors IS NOT NULL THEN users/pageview_number_of_visitors ELSE 0 END AS conversion_rate 
FROM cr_recognised_prospect

UNION ALL 

SELECT 
*
, CASE WHEN pageview_number_of_visitors IS NOT NULL THEN users/pageview_number_of_visitors ELSE 0 END AS conversion_rate 
FROM cr_annon_prospect

UNION ALL 

SELECT 
*
, CASE WHEN pageview_number_of_visitors IS NOT NULL THEN users/pageview_number_of_visitors ELSE 0 END AS conversion_rate 
FROM cr_registered_unrecognised_prospect



UNION ALL

SELECT *
, 0 pageview_number_of_visitors
, 0 conversion_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement NOT LIKE "reg-unrecognised_b2c%"
AND movement NOT LIKE "a_b2c%"
AND movement NOT LIKE "reg-recognised_b2c%"
AND movement NOT LIKE "reg-unrecognised_b2b%"
AND movement NOT LIKE "a_b2b%"
AND movement NOT LIKE "reg-recognised_b2b%"
AND movement NOT LIKE "a_reg-%"
AND movement NOT LIKE "reg-unrecognised_reg-%"
AND movement NOT LIKE "reg-recognised_reg-%"
AND month NOT LIKE "%-%M"),

lr AS (
  SELECT --Prem annual recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cPremAnnual-recognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cPremAnnual-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cPremAnnual-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Prem annual unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cPremAnnual-unrecognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cPremAnnual-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cPremAnnual-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Prem month recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cPremMonth-recognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cPremMonth-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cPremMonth-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Prem month unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cPremMonth-unrecognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cPremMonth-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cPremMonth-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2


UNION ALL

SELECT --Standard annual unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cStanAnnual-unrecognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cStanAnnual-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cStanAnnual-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Standard annual recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cStanAnnual-recognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cStanAnnual-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cStanAnnual-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Standard month unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cStanMonth-unrecognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cStanMonth-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cStanMonth-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Standard month recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cStanMonth-recognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cStanMonth-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cStanMonth-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Trialist unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cTrialist-unrecognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cTrialist-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cTrialist-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Trialist recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2cTrialist-recognised_%' AND movement NOT LIKE '%_b2c%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2cTrialist-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2cTrialist-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --B2B recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2b%' AND movement LIKE '%-recognised_%'AND movement NOT LIKE '%_b2b%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2b%' AND movement LIKE '%-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2b%' AND movement LIKE '%-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --B2B unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'b2b%' AND movement LIKE '%-unrecognised_%'AND movement NOT LIKE '%_b2b%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'b2b%' AND movement LIKE '%-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'b2b%' AND movement LIKE '%-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Registered unrecognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'reg-unrecognised_%'AND movement NOT LIKE '%_reg-%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'reg-unrecognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'reg-unrecognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2

UNION ALL

SELECT --Registered recognised lost rate
  month,
  movement,
  SUM(
    CASE
      WHEN movement LIKE 'reg-recognised_%'AND movement NOT LIKE '%_reg-%' THEN users
      ELSE 0
    END
  ) /
  SUM(SUM(
    CASE
      WHEN movement LIKE 'reg-recognised_%' THEN users
      ELSE 0
    END
  )) OVER (PARTITION BY month) AS lost_rate
FROM `ft-bi-team.BI_layer_tables.fpd_raw_monthly_net_movements_scheduled_query`
WHERE movement LIKE 'reg-recognised_%'
AND month NOT LIKE "%-%M"
GROUP BY 1, 2), 

movements_cr_lt AS (SELECT movements_cr.*
, lost_rate
FROM movements_cr
LEFT JOIN lr
ON movements_cr.month = lr.month
AND movements_cr.movement = lr.movement)

SELECT * FROM movements_cr_lt
WHERE PARSE_DATE('%Y-%m', month) < DATE_TRUNC(CURRENT_DATE(), MONTH)
