merge into actors_history_scd scd
using
(
	select a.*,make_date(year,01,01) as date from actors a
		join
		(select
			actorid,
			max(year) as year
		from actors group by 1
		) max
		on max.actorid = a.actorid
		and max.year = a.year
)src
on (src.date >= scd.start_date
	and src.actorid = scd.actorid
	and is_current = true)
WHEN MATCHED AND (src.quality_class<>scd.quality_class or src.is_active<>scd.is_active)
	UPDATE SET
		scd.end_date = src.date - 1,
		is_current = false
WHEN MATCHED AND (src.quality_class<>scd.quality_class or src.is_active<>scd.is_active)
	INSERT (actor, actorid, quality_class, is_active, start_date, end_date,is_current)
	values (src.actor, arc.actorid, src.quality_class, src.is_active, src.date, make_date(9999,12,31),true);
