
%sql
CREATE SCHEMA IF NOT EXISTS Datalake


%sql
SELECT * FROM `epam_2_hm`.`default`.`part_00023_e_75_efed_7_c_7_e_2_474_d_9_d_80_f_70_b_0_ff_83_dfb_c_000_snappy`;


%sql
-- first task top 10 hotels with max t difference during months
SELECT name AS hotel_name, wthr_date, MAX(ABS(avg_tmpr_c - avg_tmpr_f)) AS max_temp_diff
FROM `epam_2_hm`.`default`.`part_00023_e_75_efed_7_c_7_e_2_474_d_9_d_80_f_70_b_0_ff_83_dfb_c_000_snappy`
WHERE avg_tmpr_c IS NOT NULL AND avg_tmpr_f IS NOT NULL
GROUP BY name, wthr_date
ORDER BY max_temp_diff DESC
LIMIT 10;


%sql
SELECT * FROM `epam_2_hm`.`default`.`part_00123_e_75_efed_7_c_7_e_2_474_d_9_d_80_f_70_b_0_ff_83_dfb_c_000_snappy`;

%sql
--TASK 2 -  top 10 hotels with the highest visit count for each unique wthr_date (weather date)
with MonthlyVisits as (
  select name as hotel_name, wthr_date, count(*) as visit_count
  from `epam_2_hm`.`default`.`part_00123_e_75_efed_7_c_7_e_2_474_d_9_d_80_f_70_b_0_ff_83_dfb_c_000_snappy`
  where wthr_date is not null
  group by name, wthr_date
)

select hotel_name, wthr_date, visit_count
from (
  select hotel_name, wthr_date, visit_count, ROW_NUMBER() OVER (PARTITION BY wthr_date order by visit_count desc) as rank
from MonthlyVisits
) ranked
where rank <= 10
order by wthr_date, rank;



%sql
--Task 3
WITH ExtendedStays AS (
  SELECT name AS hotel_name, wthr_date, AVG(avg_tmpr_c) AS avg_temperature, MAX(avg_tmpr_c) - MIN(avg_tmpr_c) AS temperature_diff
  FROM `epam_2_hm`.`default`.`part_00123_e_75_efed_7_c_7_e_2_474_d_9_d_80_f_70_b_0_ff_83_dfb_c_000_snappy`
  GROUP BY name, wthr_date
  HAVING DATEDIFF(MAX(wthr_date), MIN(wthr_date)) > 7
)

SELECT hotel_name, wthr_date AS start_date, DATE_ADD(wthr_date, DATEDIFF(MAX(wthr_date), MIN(wthr_date))) AS end_date, AVG(avg_temperature) AS avg_temperature, MAX(temperature_diff) AS temperature_diff
FROM ExtendedStays
GROUP BY hotel_name, wthr_date
ORDER BY hotel_name, wthr_date;
