-- Query to answer wich geograpical zones are fire-prone

WITH fire_zones AS (
	SELECT
		longitude,
		CASE WHEN longitude > -80 THEN '1_Far west'
				WHEN longitude < -80 AND longitude > -90 THEN '2_West'
				WHEN longitude < -90 AND longitude > -100 THEN '3_Center'
				WHEN longitude < -100 AND longitude > -110 THEN '4_East'
				ELSE '5_Far East'
				END AS long_zone,
		CASE WHEN latitude < 35 THEN '1_South'
			WHEN latitude > 35 AND latitude < 53 THEN '2_Center'
			ELSE '3_North'
			END AS lat_zone
	FROM fires
),

zone_count AS (
	SELECT
		long_zone,
		lat_zone,
		COUNT(*) AS num_fires
	FROM fire_zones
	GROUP BY long_zone, lat_zone
)

SELECT
	long_zone,
	lat_zone,
	num_fires,
	DENSE_RANK() OVER(ORDER BY num_fires DESC) AS rank_num_fires,
	ROUND(num_fires * 100.0 / (SELECT
									SUM(num_fires)
								FROM zone_count), 2) AS perc_total
FROM zone_count
ORDER BY long_zone, lat_zone

-- With this query I can see thet 3 zones are the most prone to wildfires, with more than 50%
-- of fires only in this areas:
-- 1.- West/South: 23.89%
-- 2.- Far East/Center: 19.34%
-- 3.- Center/South: 11.02%