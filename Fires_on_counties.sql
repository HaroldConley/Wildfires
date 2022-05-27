-- Query to answer wich counties are fire-prone

WITH county_fires AS (
SELECT
	fips_name AS county,
	COUNT(*) AS num_fires,
	longitude 
FROM fires
GROUP BY fips_name
)

SELECT
	county,
	num_fires,
	DENSE_RANK() OVER(ORDER BY num_fires DESC) AS num_rank,
	ROUND(num_fires *100.0 / (SELECT SUM(num_fires)
	FROM county_fires
	WHERE county IS NOT NULL), 2) AS perc_of_tot
FROM county_fires
WHERE county IS NOT NULL
ORDER BY num_rank;

-- In this query I check that there are some counties prone to wildfires, but,
-- because of the great number of counties, each one of the prone ones only 
-- represents a very little proportion (less than 1%). So, I will make another
-- query looking for geographical zones prone to fire.