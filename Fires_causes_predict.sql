-- Query that given a season, location and size of a fire, returns a table with the causes of
-- the fires with that characteristics. 

WITH fire_causes AS (
	SELECT
		datetime(discovery_date) AS start_date,
		latitude,
		longitude,
		fire_size_class,
		stat_cause_descr AS cause
	FROM fires
	WHERE discovery_date IS NOT NULL
		AND latitude IS NOT NULL
		AND longitude IS NOT NULL
		AND fire_size IS NOT NULL
		AND stat_cause_descr IS NOT NULL
),
fire_seasons_zone AS (
	SELECT
		start_date,
		CASE WHEN CAST(strftime('%m', start_date) AS int) IN (4, 5) 
				OR (CAST(strftime('%m', start_date) AS int) = 3 AND CAST(strftime('%d', start_date) AS int) >= 21) 
				OR (CAST(strftime('%m', start_date) AS int) = 6 AND CAST(strftime('%d', start_date) AS int) < 21) THEN 'Spring'
			WHEN CAST(strftime('%m', start_date) AS int) IN (7, 8) 
				OR (CAST(strftime('%m', start_date) AS int) = 6 AND CAST(strftime('%d', start_date) AS int) >= 21) 
				OR (CAST(strftime('%m', start_date) AS int) = 9 AND CAST(strftime('%d', start_date) AS int) < 21)  THEN 'Summer'
			WHEN CAST(strftime('%m', start_date) AS int) IN (10,11) 
				OR (CAST(strftime('%m', start_date) AS int) = 9 AND CAST(strftime('%d', start_date) AS int) >= 21) 
				OR (CAST(strftime('%m', start_date) AS int) = 12 AND CAST(strftime('%d', start_date) AS int) < 21)  THEN 'Autumn'
			ELSE 'Winter'
		END AS season,
		CASE WHEN longitude > -80 THEN '1_Far_West'
				WHEN longitude < -80 AND longitude > -90 THEN '2_West'
				WHEN longitude < -90 AND longitude > -100 THEN '3_Center'
				WHEN longitude < -100 AND longitude > -110 THEN '4_East'
				ELSE '5_Far_East'
				END AS long_zone,
		CASE WHEN latitude < 35 THEN '1_South'
			WHEN latitude > 35 AND latitude < 53 THEN '2_Center'
			ELSE '3_North'
			END AS lat_zone,	
		fire_size_class,
		cause
	FROM fire_causes
	GROUP BY start_date
	ORDER BY start_date
),
fire_causes_count AS (
	SELECT
		season,
		long_zone,
		lat_zone,
		fire_size_class,
		cause,
		COUNT(cause) AS cause_num
	FROM fire_seasons_zone
	GROUP BY season, long_zone, lat_zone, fire_size_class, cause
	ORDER BY fire_size_class DESC, cause_num DESC
)
SELECT
	season,
	long_zone,
	lat_zone,
	fire_size_class,
	cause,
	cause_num
FROM fire_causes_count
-- Give the data of the fire here:
WHERE fire_size_class IN ('E', 'F', 'G')
	AND long_zone = '5_Far_East'
	AND lat_zone = '2_Center'
	AND season = 'Summer'
GROUP BY season, long_zone, lat_zone, fire_size_class, cause
ORDER BY cause_num DESC;