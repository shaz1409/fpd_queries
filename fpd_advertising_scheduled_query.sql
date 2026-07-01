DROP TABLE IF EXISTS bilayer.fpd_advertising_scheduled_query;

CREATE TABLE bilayer.fpd_advertising_scheduled_query AS
--- ARPU calculations:
--- ARPU calculations:
WITH c AS (
  WITH b AS (
    WITH a AS (
      WITH revenue AS (
        WITH adbook AS (
          SELECT
            line_item_id,
            line_item_net_total_value,
            line_item_start_date,
            line_item_end_date
          FROM
            product_analytics.booking_system_product
          WHERE
            1 = 1
            AND line_item_id IS NOT NULL
            AND line_item_position_path_1 = 'Digital'
            AND line_item_position_path_2 IN ('FT.com')
            AND line_item_position_path_3 != 'Branded Content/Native'
            AND line_item_cancellation_status IS NULL
        ),
        ad_imps AS (
          SELECT
            COALESCE(
              NULLIF(CASE WHEN LOWER(user_guid) IN ('', 'null', 'unknown') THEN NULL ELSE user_guid END, ''), 
              NULLIF(CASE WHEN LOWER(spoor_id) IN ('', 'null', 'unknown') THEN NULL ELSE spoor_id END, '')
            ) AS ft_user_id,
            CAST(time_day AS DATE) AS date,
            line_item_id
          FROM master_ads_events.master_ads_events 
          WHERE time_day >= '2025-04-01'
        ),
        gl AS (
          SELECT 
            line_item_id, 
            single_impression_revenue AS pre_gl_revenue
          FROM revenue.ads_user_revenue_base
          
        )
        SELECT
          ft_user_id,
          date,
          SUM(COALESCE(pre_gl_revenue)) AS total_revenue
        FROM
          ad_imps AS ma
        LEFT JOIN gl AS pre ON ma.line_item_id = pre.line_item_id 
        INNER JOIN adbook AS ab ON ma.line_item_id = ab.line_item_id
        GROUP BY 1,2
      ),
      known_users AS (
        SELECT
          user_status_date,
          user_guid,
          user_cohort_primary,
          user_cohort_sub,
          -- engagement_top_cluster,
          -- engagement_rfv_cluster,
          behav_cookies_consent,
          behav_marketing_email_consent,
          CASE WHEN is_recognised_user IS TRUE THEN 'recognised' ELSE 'unrecognised' END AS user_recognised_status,
          user_demographic_points_number
        FROM
          bi_layer_integration.known_user_daily_status
        WHERE
          user_status_date >= '2025-04-01'
          AND user_cohort_primary NOT IN ('non_login')
      ),
      known_users_rollup AS (
        SELECT
          user_status_date,
          user_guid,
          user_cohort_primary,
          user_cohort_sub,
          -- engagement_top_cluster,
          -- engagement_rfv_cluster,
          behav_cookies_consent,
          behav_marketing_email_consent,
          user_recognised_status,
          user_demographic_points_number AS demo_count
        FROM
          known_users
      )
      SELECT
        ft_user_id,
        EXTRACT(YEAR FROM date) AS date_year,
        EXTRACT(MONTH FROM date) AS date_month,
        IFNULL(demo_count, 0) AS demo_count,
        IFNULL(user_cohort_primary, 'anonymous') AS user_cohort,
        user_cohort_sub,
        -- engagement_top_cluster,
        -- engagement_rfv_cluster,
        behav_cookies_consent,
        behav_marketing_email_consent,
        user_recognised_status,
        SUM(total_revenue) AS total_revenue
      FROM
        revenue
      LEFT JOIN
        known_users_rollup ON ft_user_id = user_guid AND date = user_status_date
      GROUP BY
        1,2,3,4,5,6,7,8,9
    )
    SELECT
      date_year,
      date_month,
      demo_count,
      user_cohort,
      user_cohort_sub,
      -- engagement_top_cluster,
      -- engagement_rfv_cluster,
      behav_cookies_consent,
      behav_marketing_email_consent,
      user_recognised_status,
      SUM(total_revenue) AS total_revenue,
      COUNT(DISTINCT ft_user_id) AS user_count
    FROM
      a
    GROUP BY
      1,2,3,4,5,6,7,8
  )
  SELECT
    date_year,
    date_month,
    demo_count,
    user_cohort,
    user_cohort_sub,
    -- engagement_top_cluster,
    -- engagement_rfv_cluster,
    behav_cookies_consent,
    behav_marketing_email_consent,
    user_recognised_status,
    PERCENTILE_CONT(user_count, 0.5) OVER(PARTITION BY date_year, date_month, demo_count, user_cohort, user_cohort_sub, behav_cookies_consent,
  behav_marketing_email_consent, user_recognised_status) AS median_user_count,
    PERCENTILE_CONT(total_revenue, 0.5) OVER(PARTITION BY date_year, date_month, demo_count, user_cohort, user_cohort_sub, behav_cookies_consent,
  behav_marketing_email_consent, user_recognised_status) AS median_total_revenue,
    PERCENTILE_CONT(total_revenue / user_count, 0.5) OVER(PARTITION BY date_year, date_month, demo_count, user_cohort, behav_cookies_consent,
  behav_marketing_email_consent, user_cohort_sub, user_recognised_status) AS median_arpu
  FROM
    b
)
  SELECT
    demo_count,
    user_cohort,
    user_cohort_sub,
    -- engagement_top_cluster,
    -- engagement_rfv_cluster,
    behav_cookies_consent,
    behav_marketing_email_consent,
    user_recognised_status,
    date_year,
    date_month,
    TO_DATE(date_year || '-' || LPAD(date_month::VARCHAR, 2, '0') || '-01', 'YYYY-MM-DD') AS date,
    median_user_count,
    median_total_revenue,
    median_arpu
  FROM
    c
  GROUP BY
    1,2,3,4,5,6,7,8,9,10,11,12
  ORDER BY
    2,1 

/* OLD QUERY - Replaced on April 2025 
--- ARPU calculations:
WITH c AS (
  WITH b AS (
    WITH a AS (
      WITH revenue AS (
        SELECT
          COALESCE(ft_user_guid, spoor_id) AS ft_user_id,
          date,
          SUM(total_revenue) AS total_revenue --with new table the query will use  oracle_report_a_revenue
        FROM
            ads_reference.user_guid_revenue --new table: ads_reference.ads_user_daily_revenue
        WHERE
          date >= '2022-01-01'
        GROUP BY
          1,2
      ),

      known_users AS (
        SELECT
          user_status_date,
          user_guid,
          user_cohort_primary,
          user_cohort_sub,
          -- engagement_top_cluster,
          -- engagement_rfv_cluster,
          behav_cookies_consent,
          behav_marketing_email_consent,
          CASE WHEN is_recognised_user IS TRUE THEN 'recognised' ELSE 'unrecognised' END AS user_recognised_status,
          user_demographic_points_number
        FROM
          bi_layer_integration.known_user_daily_status
        WHERE
          user_status_date >= '2022-01-01'
          AND user_cohort_primary NOT IN ('non_login')
      ),

      known_users_rollup AS (
        SELECT
          user_status_date,
          user_guid,
          user_cohort_primary,
          user_cohort_sub,
          -- engagement_top_cluster,
          -- engagement_rfv_cluster,
          behav_cookies_consent,
          behav_marketing_email_consent,
          user_recognised_status,
          user_demographic_points_number AS demo_count
        FROM
          known_users
      )

      SELECT
        ft_user_id,
        EXTRACT(YEAR FROM date) AS date_year,
        EXTRACT(MONTH FROM date) AS date_month,
        IFNULL(demo_count, 0) AS demo_count,
        IFNULL(user_cohort_primary, 'anonymous') AS user_cohort,
        user_cohort_sub,
        -- engagement_top_cluster,
        -- engagement_rfv_cluster,
        behav_cookies_consent,
        behav_marketing_email_consent,
        user_recognised_status,
        SUM(total_revenue) AS total_revenue
      FROM
        revenue
      LEFT JOIN
        known_users_rollup ON ft_user_id = user_guid AND date = user_status_date
      GROUP BY
        1,2,3,4,5,6,7,8,9
    )

    SELECT
      date_year,
      date_month,
      demo_count,
      user_cohort,
      user_cohort_sub,
      -- engagement_top_cluster,
      -- engagement_rfv_cluster,
      behav_cookies_consent,
      behav_marketing_email_consent,
      user_recognised_status,
      SUM(total_revenue) AS total_revenue,
      COUNT(DISTINCT ft_user_id) AS user_count
    FROM
      a
    GROUP BY
      1,2,3,4,5,6,7,8
  )

  SELECT
    date_year,
    date_month,
    demo_count,
    user_cohort,
    user_cohort_sub,
    -- engagement_top_cluster,
    -- engagement_rfv_cluster,
    behav_cookies_consent,
    behav_marketing_email_consent,
    user_recognised_status,
    PERCENTILE_CONT(user_count, 0.5) OVER(PARTITION BY date_year, date_month, demo_count, user_cohort, user_cohort_sub, behav_cookies_consent,
  behav_marketing_email_consent, user_recognised_status) AS median_user_count,
    PERCENTILE_CONT(total_revenue, 0.5) OVER(PARTITION BY date_year, date_month, demo_count, user_cohort, user_cohort_sub, behav_cookies_consent,
  behav_marketing_email_consent, user_recognised_status) AS median_total_revenue,
    PERCENTILE_CONT(total_revenue / user_count, 0.5) OVER(PARTITION BY date_year, date_month, demo_count, user_cohort, behav_cookies_consent,
  behav_marketing_email_consent, user_cohort_sub, user_recognised_status) AS median_arpu
  FROM
    b
)

SELECT
  demo_count,
  user_cohort,
  user_cohort_sub,
  -- engagement_top_cluster,
  -- engagement_rfv_cluster,
  behav_cookies_consent,
  behav_marketing_email_consent,
  user_recognised_status,
  date_year,
  date_month,
  TO_DATE(date_year || '-' || LPAD(date_month::VARCHAR, 2, '0') || '-01', 'YYYY-MM-DD') AS date,
  median_user_count,
  median_total_revenue,
  median_arpu
FROM
  c
GROUP BY
  1,2,3,4,5,6,7,8,9,10,11,12
ORDER BY
  2,1 */;
