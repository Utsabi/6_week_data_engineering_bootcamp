CREATE TYPE films AS(
	film TEXT,
	votes Integer,
	rating REAL,
	filmid TEXT
);


CREATE TYPE quality_class AS
	ENUM ('star', 'good','average','bad');


CREATE TABLE actors(
	actor TEXT,
	actorid TEXT,
	films films[],
	quality_class quality_class,
	is_active BOOLEAN,
	PRIMARY KEY (actorid)
);

