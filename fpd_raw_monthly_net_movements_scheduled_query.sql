DROP TABLE IF EXISTS bilayer.fpd_raw_monthly_net_movements_scheduled_query;

CREATE TABLE bilayer.fpd_raw_monthly_net_movements_scheduled_query AS
--code covers movements up to dec 2028. Post 2027 code is commented out

WITH p1 as (
select
user_guid
, user_status_date
, user_cohort_primary
, case
when user_cohort_primary = 'subscriber_active_b2b' AND product_name = 'Standard FT.com' then 'b2bStan-'
when user_cohort_primary = 'subscriber_active_b2b' AND product_name IN ('Premium FT.com','Syndication,Premium FT.com') then 'b2bPrem-'
when user_cohort_primary = 'subscriber_active_b2b' AND product_name IN ('') then 'b2bOther-'
when user_cohort_primary = 'subscriber_active_b2c' AND b2c_product_name_and_term IN ('Other','') then 'b2cOther-'
when user_cohort_primary = 'subscriber_active_b2c' AND product_arrangement_type = 'B2C Trial' then 'b2cTrialist-'
when user_cohort_primary = 'subscriber_active_b2c' AND b2c_product_name_and_term = 'Premium Annual' then 'b2cPremAnnual-'
when user_cohort_primary = 'subscriber_active_b2c' AND b2c_product_name_and_term = 'Premium Monthly' then 'b2cPremMonth-'
when user_cohort_primary = 'subscriber_active_b2c' AND b2c_product_name_and_term = 'Standard Annual' then 'b2cStanAnnual-'
when user_cohort_primary = 'subscriber_active_b2c' AND b2c_product_name_and_term = 'Standard Monthly' then 'b2cStanMonth-'
when user_cohort_primary = 'registered_incl_ex_subscribers' then 'reg-'
else user_cohort_primary
end as cohort

,case
when is_recognised_user is true then 'recognised'
else 'unrecognised'
end as recog

, is_recognised_user
, count(distinct user_guid) as users
FROM bi_layer_integration.known_user_daily_status
WHERE user_status_date IN (
    '2021-12-31', '2022-01-31', '2022-02-28', '2022-03-31', '2022-04-30', '2022-05-31', '2022-06-30',
    '2022-07-31', '2022-08-31', '2022-09-30', '2022-10-31', '2022-11-30', '2022-12-31', '2023-01-31',
    '2023-02-28', '2023-03-31', '2023-04-30', '2023-05-31', '2023-06-30', '2023-07-31',
    '2023-08-31', '2023-09-30', '2023-10-31', '2023-11-30', '2023-12-31', '2024-01-31', '2024-02-29',
    '2024-03-31', '2024-04-30', '2024-05-31', '2024-06-30', '2024-07-31', '2024-08-31', '2024-09-30',
    '2024-10-31', '2024-11-30', '2024-12-31', '2025-01-31', '2025-02-28', '2025-03-31', '2025-04-30',
    '2025-05-31', '2025-06-30', '2025-07-31', '2025-08-31', '2025-09-30', '2025-10-31', '2025-11-30',
    '2025-12-31', '2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31', '2026-06-30',
    '2026-07-31', '2026-08-31', '2026-09-30', '2026-10-31', '2026-11-30', '2026-12-31', '2027-01-31',
    '2027-02-28', '2027-03-31', '2027-04-30', '2027-05-31', '2027-06-30', '2027-07-31', '2027-08-31',
    '2027-09-30', '2027-10-31', '2027-11-30', '2027-12-31', '2028-01-31', '2028-02-29', '2028-03-31',
    '2028-04-30', '2028-05-31', '2028-06-30', '2028-07-31', '2028-08-31', '2028-09-30', '2028-10-31',
    '2028-11-30', '2028-12-31'
) --add new months here 
and user_cohort_primary != 'non_login'
group by 1,2,3,4,5,6
)
, p2 as (
select
user_guid
, user_status_date
,concat(cohort,recog) as status
, count(distinct user_guid) as users
FROM p1
--where user_guid = '000208ad-34c6-4486-8488-e04000b73f72'-- '000007f3-eb60-4bb9-9a7a-17f8ed3b2d76'
group by 1,2,3
)

,p3 as (
SELECT
    user_guid,
    CASE WHEN user_status_date = '2021-12-31' THEN status ELSE 'a' END AS dec_21,
    CASE WHEN user_status_date = '2022-01-31' THEN status ELSE 'a' END AS jan_22,
    CASE WHEN user_status_date = '2022-02-28' THEN status ELSE 'a' END AS feb_22,
    CASE WHEN user_status_date = '2022-03-31' THEN status ELSE 'a' END AS mar_22,
    CASE WHEN user_status_date = '2022-04-30' THEN status ELSE 'a' END AS apr_22,
    CASE WHEN user_status_date = '2022-05-31' THEN status ELSE 'a' END AS may_22,
    CASE WHEN user_status_date = '2022-06-30' THEN status ELSE 'a' END AS jun_22,
    CASE WHEN user_status_date = '2022-07-31' THEN status ELSE 'a' END AS jul_22,
    CASE WHEN user_status_date = '2022-08-31' THEN status ELSE 'a' END AS aug_22,
    CASE WHEN user_status_date = '2022-09-30' THEN status ELSE 'a' END AS sep_22,
    CASE WHEN user_status_date = '2022-10-31' THEN status ELSE 'a' END AS oct_22,
    CASE WHEN user_status_date = '2022-11-30' THEN status ELSE 'a' END AS nov_22,
    CASE WHEN user_status_date = '2022-12-31' THEN status ELSE 'a' END AS dec_22,
    CASE WHEN user_status_date = '2023-01-31' THEN status ELSE 'a' END AS jan_23,
    CASE WHEN user_status_date = '2023-02-28' THEN status ELSE 'a' END AS feb_23,
    CASE WHEN user_status_date = '2023-03-31' THEN status ELSE 'a' END AS mar_23,
    CASE WHEN user_status_date = '2023-04-30' THEN status ELSE 'a' END AS apr_23,
    CASE WHEN user_status_date = '2023-05-31' THEN status ELSE 'a' END AS may_23,
    CASE WHEN user_status_date = '2023-06-30' THEN status ELSE 'a' END AS jun_23,
    CASE WHEN user_status_date = '2023-07-31' THEN status ELSE 'a' END AS jul_23,
    CASE WHEN user_status_date = '2023-08-31' THEN status ELSE 'a' END AS aug_23,
    CASE WHEN user_status_date = '2023-09-30' THEN status ELSE 'a' END AS sep_23,
    CASE WHEN user_status_date = '2023-10-31' THEN status ELSE 'a' END AS oct_23,
    CASE WHEN user_status_date = '2023-11-30' THEN status ELSE 'a' END AS nov_23,
    CASE WHEN user_status_date = '2023-12-31' THEN status ELSE 'a' END AS dec_23,
    CASE WHEN user_status_date = '2024-01-31' THEN status ELSE 'a' END AS jan_24,
    CASE WHEN user_status_date = '2024-02-29' THEN status ELSE 'a' END AS feb_24,
    CASE WHEN user_status_date = '2024-03-31' THEN status ELSE 'a' END AS mar_24,
    CASE WHEN user_status_date = '2024-04-30' THEN status ELSE 'a' END AS apr_24,
    CASE WHEN user_status_date = '2024-05-31' THEN status ELSE 'a' END AS may_24,
    CASE WHEN user_status_date = '2024-06-30' THEN status ELSE 'a' END AS jun_24,
    CASE WHEN user_status_date = '2024-07-31' THEN status ELSE 'a' END AS jul_24,
    CASE WHEN user_status_date = '2024-08-31' THEN status ELSE 'a' END AS aug_24,
    CASE WHEN user_status_date = '2024-09-30' THEN status ELSE 'a' END AS sep_24,
    CASE WHEN user_status_date = '2024-10-31' THEN status ELSE 'a' END AS oct_24,
    CASE WHEN user_status_date = '2024-11-30' THEN status ELSE 'a' END AS nov_24,
    CASE WHEN user_status_date = '2024-12-31' THEN status ELSE 'a' END AS dec_24,
    CASE WHEN user_status_date = '2025-01-31' THEN status ELSE 'a' END AS jan_25,
    CASE WHEN user_status_date = '2025-02-28' THEN status ELSE 'a' END AS feb_25,
    CASE WHEN user_status_date = '2025-03-31' THEN status ELSE 'a' END AS mar_25,
    CASE WHEN user_status_date = '2025-04-30' THEN status ELSE 'a' END AS apr_25,
    CASE WHEN user_status_date = '2025-05-31' THEN status ELSE 'a' END AS may_25,
    CASE WHEN user_status_date = '2025-06-30' THEN status ELSE 'a' END AS jun_25,
    CASE WHEN user_status_date = '2025-07-31' THEN status ELSE 'a' END AS jul_25,
    CASE WHEN user_status_date = '2025-08-31' THEN status ELSE 'a' END AS aug_25,
    CASE WHEN user_status_date = '2025-09-30' THEN status ELSE 'a' END AS sep_25,
    CASE WHEN user_status_date = '2025-10-31' THEN status ELSE 'a' END AS oct_25,
    CASE WHEN user_status_date = '2025-11-30' THEN status ELSE 'a' END AS nov_25,
    CASE WHEN user_status_date = '2025-12-31' THEN status ELSE 'a' END AS dec_25,
    CASE WHEN user_status_date = '2026-01-31' THEN status ELSE 'a' END AS jan_26,
    CASE WHEN user_status_date = '2026-02-28' THEN status ELSE 'a' END AS feb_26,
    CASE WHEN user_status_date = '2026-03-31' THEN status ELSE 'a' END AS mar_26,
    CASE WHEN user_status_date = '2026-04-30' THEN status ELSE 'a' END AS apr_26,
    CASE WHEN user_status_date = '2026-05-31' THEN status ELSE 'a' END AS may_26,
    CASE WHEN user_status_date = '2026-06-30' THEN status ELSE 'a' END AS jun_26,
    CASE WHEN user_status_date = '2026-07-31' THEN status ELSE 'a' END AS jul_26,
    CASE WHEN user_status_date = '2026-08-31' THEN status ELSE 'a' END AS aug_26,
    CASE WHEN user_status_date = '2026-09-30' THEN status ELSE 'a' END AS sep_26,
    CASE WHEN user_status_date = '2026-10-31' THEN status ELSE 'a' END AS oct_26,
    CASE WHEN user_status_date = '2026-11-30' THEN status ELSE 'a' END AS nov_26,
    CASE WHEN user_status_date = '2026-12-31' THEN status ELSE 'a' END AS dec_26,
    CASE WHEN user_status_date = '2027-01-31' THEN status ELSE 'a' END AS jan_27,
    CASE WHEN user_status_date = '2027-02-28' THEN status ELSE 'a' END AS feb_27,
    CASE WHEN user_status_date = '2027-03-31' THEN status ELSE 'a' END AS mar_27,
    CASE WHEN user_status_date = '2027-04-30' THEN status ELSE 'a' END AS apr_27,
    CASE WHEN user_status_date = '2027-05-31' THEN status ELSE 'a' END AS may_27,
    CASE WHEN user_status_date = '2027-06-30' THEN status ELSE 'a' END AS jun_27,
    CASE WHEN user_status_date = '2027-07-31' THEN status ELSE 'a' END AS jul_27,
    CASE WHEN user_status_date = '2027-08-31' THEN status ELSE 'a' END AS aug_27,
    CASE WHEN user_status_date = '2027-09-30' THEN status ELSE 'a' END AS sep_27,
    CASE WHEN user_status_date = '2027-10-31' THEN status ELSE 'a' END AS oct_27,
    CASE WHEN user_status_date = '2027-11-30' THEN status ELSE 'a' END AS nov_27,
    CASE WHEN user_status_date = '2027-12-31' THEN status ELSE 'a' END AS dec_27
    
    /* Commented out SQL code
    ,
    CASE WHEN user_status_date = '2028-01-31' THEN status ELSE 'a' END AS jan_28,
    CASE WHEN user_status_date = '2028-02-29' THEN status ELSE 'a' END AS feb_28,
    CASE WHEN user_status_date = '2028-03-31' THEN status ELSE 'a' END AS mar_28,
    CASE WHEN user_status_date = '2028-04-30' THEN status ELSE 'a' END AS apr_28,
    CASE WHEN user_status_date = '2028-05-31' THEN status ELSE 'a' END AS may_28,
    CASE WHEN user_status_date = '2028-06-30' THEN status ELSE 'a' END AS jun_28,
    CASE WHEN user_status_date = '2028-07-31' THEN status ELSE 'a' END AS jul_28,
    CASE WHEN user_status_date = '2028-08-31' THEN status ELSE 'a' END AS aug_28,
    CASE WHEN user_status_date = '2028-09-30' THEN status ELSE 'a' END AS sep_28,
    CASE WHEN user_status_date = '2028-10-31' THEN status ELSE 'a' END AS oct_28,
    CASE WHEN user_status_date = '2028-11-30' THEN status ELSE 'a' END AS nov_28,
    CASE WHEN user_status_date = '2028-12-31' THEN status ELSE 'a' END AS dec_28 
    */   --add new months here
from p2
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74
/* Commented out SQL code 
, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86
*/ --add new group, after adding new months
) 

,p4 as (
SELECT
    user_guid,
    MAX(dec_21) AS dec_21,
    MAX(jan_22) AS jan_22,
    MAX(feb_22) AS feb_22,
    MAX(mar_22) AS mar_22,
    MAX(apr_22) AS apr_22,
    MAX(may_22) AS may_22,
    MAX(jun_22) AS jun_22,
    MAX(jul_22) AS jul_22,
    MAX(aug_22) AS aug_22,
    MAX(sep_22) AS sep_22,
    MAX(oct_22) AS oct_22,
    MAX(nov_22) AS nov_22,
    MAX(dec_22) AS dec_22,
    MAX(jan_23) AS jan_23,
    MAX(feb_23) AS feb_23,
    MAX(mar_23) AS mar_23,
    MAX(apr_23) AS apr_23,
    MAX(may_23) AS may_23,
    MAX(jun_23) AS jun_23,
    MAX(jul_23) AS jul_23,
    MAX(aug_23) AS aug_23,
    MAX(sep_23) AS sep_23,
    MAX(oct_23) AS oct_23,
    MAX(nov_23) AS nov_23,
    MAX(dec_23) AS dec_23,
    MAX(jan_24) AS jan_24,
    MAX(feb_24) AS feb_24,
    MAX(mar_24) AS mar_24,
    MAX(apr_24) AS apr_24,
    MAX(may_24) AS may_24,
    MAX(jun_24) AS jun_24,
    MAX(jul_24) AS jul_24,
    MAX(aug_24) AS aug_24,
    MAX(sep_24) AS sep_24,
    MAX(oct_24) AS oct_24,
    MAX(nov_24) AS nov_24,
    MAX(dec_24) AS dec_24,
    MAX(jan_25) AS jan_25,
    MAX(feb_25) AS feb_25,
    MAX(mar_25) AS mar_25,
    MAX(apr_25) AS apr_25,
    MAX(may_25) AS may_25,
    MAX(jun_25) AS jun_25,
    MAX(jul_25) AS jul_25,
    MAX(aug_25) AS aug_25,
    MAX(sep_25) AS sep_25,
    MAX(oct_25) AS oct_25,
    MAX(nov_25) AS nov_25,
    MAX(dec_25) AS dec_25,
    MAX(jan_26) AS jan_26,
    MAX(feb_26) AS feb_26,
    MAX(mar_26) AS mar_26,
    MAX(apr_26) AS apr_26,
    MAX(may_26) AS may_26,
    MAX(jun_26) AS jun_26,
    MAX(jul_26) AS jul_26,
    MAX(aug_26) AS aug_26,
    MAX(sep_26) AS sep_26,
    MAX(oct_26) AS oct_26,
    MAX(nov_26) AS nov_26,
    MAX(dec_26) AS dec_26,
    MAX(jan_27) AS jan_27,
    MAX(feb_27) AS feb_27,
    MAX(mar_27) AS mar_27,
    MAX(apr_27) AS apr_27,
    MAX(may_27) AS may_27,
    MAX(jun_27) AS jun_27,
    MAX(jul_27) AS jul_27,
    MAX(aug_27) AS aug_27,
    MAX(sep_27) AS sep_27,
    MAX(oct_27) AS oct_27,
    MAX(nov_27) AS nov_27,
    MAX(dec_27) AS dec_27
    /* Commented out SQL code
    ,
    MAX(jan_28) AS jan_28,
    MAX(feb_28) AS feb_28,
    MAX(mar_28) AS mar_28,
    MAX(apr_28) AS apr_28,
    MAX(may_28) AS may_28,
    MAX(jun_28) AS jun_28,
    MAX(jul_28) AS jul_28,
    MAX(aug_28) AS aug_28,
    MAX(sep_28) AS sep_28,
    MAX(oct_28) AS oct_28,
    MAX(nov_28) AS nov_28,
    MAX(dec_28) AS dec_28
    */
FROM p3
-- where user_guid in ('7bf31d56-6ebd-4726-b6fe-04dc50bc1672','c9111b63-28fb-4bbf-9961-381177fe172b')
group by 1
--order by 1
), 

p5 as (SELECT
    user_guid,
    CONCAT(dec_21,'_',jan_22) AS dec_21_jan_22, -- Date represents the start of the month, this is the movement from Dec 21 to Jan 22
    CONCAT(jan_22,'_',feb_22) AS jan_22_feb_22,
    CONCAT(feb_22,'_',mar_22) AS feb_22_mar_22,
    CONCAT(mar_22,'_',apr_22) AS mar_22_apr_22,
    CONCAT(apr_22,'_',may_22) AS apr_22_may_22,
    CONCAT(may_22,'_',jun_22) AS may_22_jun_22,
    CONCAT(jun_22,'_',jul_22) AS jun_22_jul_22,
    CONCAT(jul_22,'_',aug_22) AS jul_22_aug_22,
    CONCAT(aug_22,'_',sep_22) AS aug_22_sep_22,
    CONCAT(sep_22,'_',oct_22) AS sep_22_oct_22,
    CONCAT(oct_22,'_',nov_22) AS oct_22_nov_22,
    CONCAT(nov_22,'_',dec_22) AS nov_22_dec_22,
    CONCAT(dec_22,'_',jan_23) AS dec_22_jan_23,
    CONCAT(jan_23,'_',feb_23) AS jan_23_feb_23,
    CONCAT(feb_23,'_',mar_23) AS feb_23_mar_23,
    CONCAT(mar_23,'_',apr_23) AS mar_23_apr_23,
    CONCAT(apr_23,'_',may_23) AS apr_23_may_23,
    CONCAT(may_23,'_',jun_23) AS may_23_jun_23,
    CONCAT(jun_23,'_',jul_23) AS jun_23_jul_23,
    CONCAT(jul_23,'_',aug_23) AS jul_23_aug_23,
    CONCAT(aug_23,'_',sep_23) AS aug_23_sep_23,
    CONCAT(sep_23,'_',oct_23) AS sep_23_oct_23,
    CONCAT(oct_23,'_',nov_23) AS oct_23_nov_23,
    CONCAT(nov_23,'_',dec_23) AS nov_23_dec_23,
    CONCAT(dec_23,'_',jan_24) AS dec_23_jan_24,
    CONCAT(jan_24,'_',feb_24) AS jan_24_feb_24,
    CONCAT(feb_24,'_',mar_24) AS feb_24_mar_24,
    CONCAT(mar_24,'_',apr_24) AS mar_24_apr_24,
    CONCAT(apr_24,'_',may_24) AS apr_24_may_24,
    CONCAT(may_24,'_',jun_24) AS may_24_jun_24,
    CONCAT(jun_24,'_',jul_24) AS jun_24_jul_24,
    CONCAT(jul_24,'_',aug_24) AS jul_24_aug_24,
    CONCAT(aug_24,'_',sep_24) AS aug_24_sep_24,
    CONCAT(sep_24,'_',oct_24) AS sep_24_oct_24,
    CONCAT(oct_24,'_',nov_24) AS oct_24_nov_24,
    CONCAT(nov_24,'_',dec_24) AS nov_24_dec_24,
    CONCAT(dec_24,'_',jan_25) AS dec_24_jan_25,
    CONCAT(jan_25,'_',feb_25) AS jan_25_feb_25,
    CONCAT(feb_25,'_',mar_25) AS feb_25_mar_25,
    CONCAT(mar_25,'_',apr_25) AS mar_25_apr_25,
    CONCAT(apr_25,'_',may_25) AS apr_25_may_25,
    CONCAT(may_25,'_',jun_25) AS may_25_jun_25,
    CONCAT(jun_25,'_',jul_25) AS jun_25_jul_25,
    CONCAT(jul_25,'_',aug_25) AS jul_25_aug_25,
    CONCAT(aug_25,'_',sep_25) AS aug_25_sep_25,
    CONCAT(sep_25,'_',oct_25) AS sep_25_oct_25,
    CONCAT(oct_25,'_',nov_25) AS oct_25_nov_25,
    CONCAT(nov_25,'_',dec_25) AS nov_25_dec_25,
    CONCAT(dec_25,'_',jan_26) AS dec_25_jan_26,
    CONCAT(jan_26,'_',feb_26) AS jan_26_feb_26,
    CONCAT(feb_26,'_',mar_26) AS feb_26_mar_26,
    CONCAT(mar_26,'_',apr_26) AS mar_26_apr_26,
    CONCAT(apr_26,'_',may_26) AS apr_26_may_26,
    CONCAT(may_26,'_',jun_26) AS may_26_jun_26,
    CONCAT(jun_26,'_',jul_26) AS jun_26_jul_26,
    CONCAT(jul_26,'_',aug_26) AS jul_26_aug_26,
    CONCAT(aug_26,'_',sep_26) AS aug_26_sep_26,
    CONCAT(sep_26,'_',oct_26) AS sep_26_oct_26,
    CONCAT(oct_26,'_',nov_26) AS oct_26_nov_26,
    CONCAT(nov_26,'_',dec_26) AS nov_26_dec_26,
    CONCAT(dec_26,'_',jan_27) AS dec_26_jan_27,
    CONCAT(jan_27,'_',feb_27) AS jan_27_feb_27,
    CONCAT(feb_27,'_',mar_27) AS feb_27_mar_27,
    CONCAT(mar_27,'_',apr_27) AS mar_27_apr_27,
    CONCAT(apr_27,'_',may_27) AS apr_27_may_27,
    CONCAT(may_27,'_',jun_27) AS may_27_jun_27,
    CONCAT(jun_27,'_',jul_27) AS jun_27_jul_27,
    CONCAT(jul_27,'_',aug_27) AS jul_27_aug_27,
    CONCAT(aug_27,'_',sep_27) AS aug_27_sep_27,
    CONCAT(sep_27,'_',oct_27) AS sep_27_oct_27,
    CONCAT(oct_27,'_',nov_27) AS oct_27_nov_27,
    CONCAT(nov_27,'_',dec_27) AS nov_27_dec_27
    /* Commented out SQL code
    ,
    CONCAT(dec_27,'_',jan_28) AS dec_27_jan_28,
    CONCAT(jan_28,'_',feb_28) AS jan_28_feb_28,
    CONCAT(feb_28,'_',mar_28) AS feb_28_mar_28,
    CONCAT(mar_28,'_',apr_28) AS mar_28_apr_28,
    CONCAT(apr_28,'_',may_28) AS apr_28_may_28,
    CONCAT(may_28,'_',jun_28) AS may_28_jun_28,
    CONCAT(jun_28,'_',jul_28) AS jun_28_jul_28,
    CONCAT(jul_28,'_',aug_28) AS jul_28_aug_28,
    CONCAT(aug_28,'_',sep_28) AS aug_28_sep_28,
    CONCAT(sep_28,'_',oct_28) AS sep_28_oct_28,
    CONCAT(oct_28,'_',nov_28) AS oct_28_nov_28,
    CONCAT(nov_28,'_',dec_28) AS nov_28_dec_28
    */
FROM
    p4
-- WHERE user_guid IN ('7bf31d56-6ebd-4726-b6fe-04dc50bc1672','c9111b63-28fb-4bbf-9961-381177fe172b')
GROUP BY
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73
    /* Commented out SQL code
    ,74,75,76,77,78,79,80,81,82,83,84, 85  
    */--add new grouping after adding month
)

-- creating column with end month date to represent movement in model (i.e., first row is net movement from dec 21 to jan 22)
SELECT '2022-01' as month, p5.dec_21_jan_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-02' as month, p5.jan_22_feb_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-03' as month, p5.feb_22_mar_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-04' as month, p5.mar_22_apr_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-05' as month, p5.apr_22_may_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-06' as month, p5.may_22_jun_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-07' as month, p5.jun_22_jul_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-08' as month, p5.jul_22_aug_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-09' as month, p5.aug_22_sep_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-10' as month, p5.sep_22_oct_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-11' as month, p5.oct_22_nov_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2022-12' as month, p5.nov_22_dec_22 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-01' as month, p5.dec_22_jan_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-02' as month, p5.jan_23_feb_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-03' as month, p5.feb_23_mar_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-04' as month, p5.mar_23_apr_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-05' as month, p5.apr_23_may_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-06' as month, p5.may_23_jun_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-07' as month, p5.jun_23_jul_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-08' as month, p5.jul_23_aug_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-09' as month, p5.aug_23_sep_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-10' as month, p5.sep_23_oct_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-11' as month, p5.oct_23_nov_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2023-12' as month, p5.nov_23_dec_23 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-01' as month, p5.dec_23_jan_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-02' as month, p5.jan_24_feb_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-03' as month, p5.feb_24_mar_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-04' as month, p5.mar_24_apr_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-05' as month, p5.apr_24_may_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-06' as month, p5.may_24_jun_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-07' as month, p5.jun_24_jul_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-08' as month, p5.jul_24_aug_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-09' as month, p5.aug_24_sep_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-10' as month, p5.sep_24_oct_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-11' as month, p5.oct_24_nov_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2024-12' as month, p5.nov_24_dec_24 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-01' as month, p5.dec_24_jan_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-02' as month, p5.jan_25_feb_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-03' as month, p5.feb_25_mar_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-04' as month, p5.mar_25_apr_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-05' as month, p5.apr_25_may_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-06' as month, p5.may_25_jun_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-07' as month, p5.jun_25_jul_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-08' as month, p5.jul_25_aug_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-09' as month, p5.aug_25_sep_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-10' as month, p5.sep_25_oct_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-11' as month, p5.oct_25_nov_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2025-12' as month, p5.nov_25_dec_25 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-01' as month, p5.dec_25_jan_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-02' as month, p5.jan_26_feb_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-03' as month, p5.feb_26_mar_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-04' as month, p5.mar_26_apr_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-05' as month, p5.apr_26_may_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-06' as month, p5.may_26_jun_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-07' as month, p5.jun_26_jul_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-08' as month, p5.jul_26_aug_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-09' as month, p5.aug_26_sep_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-10' as month, p5.sep_26_oct_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-11' as month, p5.oct_26_nov_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2026-12' as month, p5.nov_26_dec_26 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-01' as month, p5.dec_26_jan_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-02' as month, p5.jan_27_feb_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-03' as month, p5.feb_27_mar_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-04' as month, p5.mar_27_apr_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-05' as month, p5.apr_27_may_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-06' as month, p5.may_27_jun_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-07' as month, p5.jun_27_jul_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-08' as month, p5.jul_27_aug_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-09' as month, p5.aug_27_sep_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-10' as month, p5.sep_27_oct_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-11' as month, p5.oct_27_nov_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2027-12' as month, p5.nov_27_dec_27 as movement, count(distinct user_guid) as users from p5 group by 1,2 
/* Commented out SQL code
union all
SELECT '2028-01' as month, p5.dec_27_jan_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-02' as month, p5.jan_28_feb_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-03' as month, p5.feb_28_mar_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-04' as month, p5.mar_28_apr_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-05' as month, p5.apr_28_may_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-06' as month, p5.may_28_jun_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-07' as month, p5.jun_28_jul_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-08' as month, p5.jul_28_aug_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-09' as month, p5.aug_28_sep_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-10' as month, p5.sep_28_oct_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-11' as month, p5.oct_28_nov_28 as movement, count(distinct user_guid) as users from p5 group by 1,2 union all
SELECT '2028-12' as month, p5.nov_28_dec_28 as movement, count(distinct user_guid) as users from p5 group by 1,2
*/;
