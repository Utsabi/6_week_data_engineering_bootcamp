WITH
year_timeline AS(
select  generate_series(1970,2021) AS year
)
, actor_careers as(
	select
		actorid,
		max(actor) as actor_name,
		min(year) as debut_year,
		max(year) as recent_release_year
	from actor_films
	group by actorid
)
,actor_years as(
	select
		ac.actorid as actorid,
		ac.actor_name as actor_name,
		yt.year as current_year
	from actor_careers ac
	join year_timeline yt on yt.year >= ac.debut_year
)
,film_release_year as(
	SELECT
		ay.actorid,
		ay.current_year,
		MAX(af.year) AS latest_year
	FROM actor_films af
	join actor_years ay ON af.actorid =ay.actorid AND af.year <= ay.current_year
	group by ay.actorid, ay.current_year
)
, film_aggregrated AS(
	SELECT
		ay.actorid,
		ay.actor_name AS actor,
		ay.current_year,
		ARRAY_AGG(
			ROW(
				af.film,
				af.votes,
				af.rating,
				af.filmid
			)::films
			ORDER BY af.year, af.filmid
		)AS films
	from actor_years ay
	left join actor_films af
	on af.actorid = ay.actorid and af.year <= ay.current_year
	group by ay.actorid, ay.actor_name, ay.current_year
)
, avg_rating_latest_year AS(
	SELECT
		f.actorid,
		f.current_year,
		AVG(af.rating) AS avg_rating
	FROM film_release_year f
	join actor_films af
	on af.actorid =f.actorid and af.year=f.latest_year
	group by f.actorid, f.current_year
)
,actor_summary AS(
	SELECT
		f.actorid,
		f.actor,
		f.current_year,
		f.films,
		a.avg_rating,
		COUNT(CASE WHEN af.year =f.current_year then 1 end) as film_count
	from film_aggregrated f
	join avg_rating_latest_year a
	on f.actorid =a.actorid and f.current_year =a.current_year
	left join actor_films af
	on af.actorid = f.actorid and af.year =f.current_year
	group by f.actorid, f.actor, f.current_year,f.films, a.avg_rating
)
,actor_film_final AS(
	SELECT
		actorid,
		actor,
		current_year,
		films as film,
		case
			when avg_rating > 8 then 'star'
			when avg_rating > 7 then 'good'
			when avg_rating > 6 then 'average'
			else 'bad'
		END::quality_class as quality_class,
		(film_count > 0) as is_active
	from actor_summary
)
select * from actor_film_final;