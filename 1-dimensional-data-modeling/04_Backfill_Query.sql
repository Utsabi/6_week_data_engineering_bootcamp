insert into actors_history_scd
with changes as(
	select actor
			,actorid
			,quality_class
			,is_active
			,year
			,LAG(is_active) OVER (PARTITION BY actorid ORDER BY year) as prev_active_class
			,LAG(quality_class) OVER (PARTITION BY actorid ORDER BY year) as prev_quality_class
			from actors
),
periods as(
		select
			actorid,
			actor,
			quality_class,
			is_active,
			year as start_date,
			(LEAD(year,1,10000) OVER (PARTITION BY actorid ORDER BY YEAR)- 1) as end_date
			from changes
			where quality_class <> prev_quality_class
			or is_active <> prev_active_class
			or prev_quality_class is NULL
)
select
	actorid
	,actor
	,quality_class
	,is_active
	,make_date(start_date,1,1) as start_date
	,make_date(end_date,12,31) as end_date
	,(end_date = 9999) as is_current
from periods
;
