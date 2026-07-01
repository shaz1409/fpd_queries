DROP TABLE IF EXISTS bilayer.fpd_prospect_visitors_scheduled_query;

CREATE TABLE bilayer.fpd_prospect_visitors_scheduled_query AS
--keeping FULL code, including other combinations OF prospect and recognised vistors in casethis info is relevant for the future
SELECT
  (CASE
      WHEN known_user_daily_status.is_recognised_user THEN 'Yes'
    ELSE
    'No'
  END
    ) AS known_user_daily_status_is_recognised_user,
  pageview.user_cohort pageview_user_cohort, --adding breakdown BY cohort 
  (CASE
    WHEN pageview.user_cohort IN ('registered', 'anonymous') THEN 'Yes'
  ELSE
  'No'
END
  ) AS pageview_is_prospect_visit,
  (CASE
      WHEN known_user_daily_status.behav_marketing_email_consent THEN 'Yes'
    ELSE
    'No'
  END
    ) AS behav_marketing_email_consent,
  (CASE
      WHEN known_user_daily_status.behav_cookies_consent THEN 'Yes'
    ELSE
    'No'
  END
    ) AS behav_cookies_consent,
  (CASE
      WHEN known_user_daily_status.user_with_demographic_data THEN 'Yes'
    ELSE
    'No'
  END
    ) AS user_with_demographic_data,
  (TO_CHAR(visit.time_stamp_utc, 'YYYY-MM')) AS visit_time_stamp_utc_month,
  COUNT(DISTINCT (
      CASE
        WHEN pageview.user_guid IS NOT NULL AND pageview.user_guid <> '' THEN pageview.user_guid
      ELSE
      CAST(pageview.visitor_id AS VARCHAR)
    END
      ) ) AS pageview_number_of_visitors,
  COUNT(DISTINCT pageview.device_spoor_id ) AS pageview_number_of_devices
FROM
  bi_layer_integration.pageview AS pageview
INNER JOIN
  bi_layer_integration.visit AS visit
ON
  pageview.visit_id = visit.visit_id
  AND visit.time_stamp_utc >= TIMESTAMP '2022-01-01'
LEFT JOIN
  bi_layer_integration.known_user_daily_status AS known_user_daily_status
ON
  known_user_daily_status.user_guid = pageview.user_guid
  -- this section was changed as per Jono's feedback: AND known_user_daily_status.user_status_date = (CAST(pageview.time_stamp_utc  AS DATE)) 
  AND known_user_daily_status.user_status_date = (CAST(visit.visit_date  AS DATE)) 
  AND visit.time_stamp_utc >= TIMESTAMP '2022-01-01'
WHERE
  pageview.time_stamp_utc >= TIMESTAMP '2022-01-01'
GROUP BY
  1,
  2,
  3,
  4, 
  5, 
  6,
  7;
