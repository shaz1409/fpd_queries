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
  (FORMAT_TIMESTAMP('%Y-%m', visit.time_stamp_utc )) AS visit_time_stamp_utc_month,
  COUNT(DISTINCT (
      CASE
        WHEN pageview.user_guid IS NOT NULL AND pageview.user_guid <> '' THEN pageview.user_guid
      ELSE
      CAST(pageview.visitor_id AS STRING)
    END
      ) ) AS pageview_number_of_visitors,
  COUNT(DISTINCT pageview.device_spoor_id ) AS pageview_number_of_devices
FROM
  `ft-bi-team.BI_Layer_Integration.pageview` AS pageview
INNER JOIN
  `ft-bi-team.BI_Layer_Integration.visit` AS visit
ON
  pageview.visit_id = visit.visit_id
  AND visit.time_stamp_utc >= TIMESTAMP('2022-01-01')
LEFT JOIN
  `ft-bi-team.BI_Layer_Integration.known_user_daily_status` AS known_user_daily_status
ON
  known_user_daily_status.user_guid = pageview.user_guid
  -- this section was changed as per Jono's feedback: AND known_user_daily_status.user_status_date = (DATE(pageview.time_stamp_utc )) 
  AND known_user_daily_status.user_status_date = (DATE(visit.visit_date )) 
  AND visit.time_stamp_utc >= TIMESTAMP('2022-01-01')
WHERE
  pageview.time_stamp_utc >= TIMESTAMP('2022-01-01')
GROUP BY
  1,
  2,
  3,
  4, 
  5, 
  6,
  7
