DROP TABLE IF EXISTS bilayer.fpd_capped_12_months_b2c_ltv_scheduled_query;

CREATE TABLE bilayer.fpd_capped_12_months_b2c_ltv_scheduled_query AS
SELECT 
DATE_TRUNC('month', DATEADD(day, -1, CAST(run_date AS DATE))) AS date
,CASE WHEN  acquisition_method = 'Trial' THEN 'Trial' 
WHEN product = 'Premium FT.com' THEN 'Premium' 
WHEN product = 'Standard FT.com' THEN 'Standard' END AS product_name
,case when arrangementlength_id in ('28D','1M') then 'Month' else 'Annual' end as term
, ROUND(AVG(acquisition_initial_12m_ltv), 2) avg_capped_ltv_12mth
, ROUND(AVG(acquisition_initial_12m_ltv)/12, 2) estimated_monthly_avg_capped_ltv_12mth
, SUM(user_count) sum_user_count
FROM historic.b2c_acquisition_initial_12m_ltv
WHERE DATE_TRUNC('month', run_date) BETWEEN '2022-01-01' AND '2028-12-01'
AND EXTRACT(DAY FROM run_date) = 1
GROUP BY 1, 2, 3

 /* Previous code

 
WITH ltv_cap1 AS  (SELECT
run_date,
user_guid,
is_active,
arrangement_id,
residual_ltv,
earned_value,
total_ltv,
residual_years, active_years, first_join_date,
arrangementlength_id, is_trial_conversion, product_name_rollup,
region, discount
from
latest.b2c_arrangement_ltv
where is_active is true and
active_years<=0.25
and region<>'Unknown'), 


ltv_cap2 AS (SELECT a.*,
case when is_trial_conversion is true then 'Trial Convert'
when is_trial_conversion is false and product_name_rollup<>'Trial' then 'Direct' else 'Active Trial' end
as source_band,
case when discount=0 then 'None'
when discount between 1 and 25 then '1-25'
when discount between 26 and 35 then '26-35'
when discount>35 then '36-100'
else 'NA' end as discount_band,
case when arrangementlength_id in ('28D','1M') then 'Month' else 'Annual' end as term
from ltv_cap1 a),


ltv_cap3 AS (SELECT region, discount_band, product_name_rollup,
term, source_band,
count (*) as num_subs,
round(avg(earned_value),2) as avg_earned,
round(avg(active_years),3) as avg_active,
round(avg(residual_ltv),2) as avg_resid_ltv,
round(avg(residual_years),2) as avg_resid_yrs
from ltv_cap2
group by 1,2,3,4,5
order by 1,2,3,4,5),


ltv_cap4 AS (SELECT
a.*,
case when
term='Annual' then avg_earned
when
term='Month' and (avg_resid_yrs+avg_active)<1
then avg_earned+avg_resid_ltv
when
term='Month' and (avg_resid_yrs+avg_active)>=1
then avg_earned+(avg_resid_ltv*((1-avg_active)/avg_resid_yrs))
end as capped_ltv_12mth
from ltv_cap3 a)

SELECT 
ltv_cap4.product_name_rollup
, term
, ROUND(AVG(capped_ltv_12mth), 2) avg_capped_ltv_12mth
, ROUND(AVG(capped_ltv_12mth)/12, 2) estimated_monthly_avg_capped_ltv_12mth
FROM ltv_cap4
GROUP BY 1, 2
ORDER BY ltv_cap4.product_name_rollup ASC

*/;
