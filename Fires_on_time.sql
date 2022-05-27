-- In this query I get the info to answer if the wildfires are more frequents and consume
-- more lands now than in the past.

WITH fire_times AS (
SELECT
	fod_id AS Global_id,
	datetime(DISCOVERY_DATE) AS start_date,
	datetime(CONT_DATE) AS end_date,
	fire_size AS size
FROM Fires
),
fire_avg AS (
SELECT 
	strftime('%Y', start_date) AS Y_start,
	COUNT(Global_id) AS count,
	AVG(COUNT(Global_id)) OVER(ORDER BY start_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS avg_5_last,
	SUM(size) AS total_size
FROM fire_times
GROUP BY Y_start
ORDER BY Y_start
)

SELECT
	Y_start,
	count,
	MAX(count) OVER(ORDER BY Y_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS max_count_until_now,
	MAX(count) OVER(ORDER BY Y_start ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)  AS max_count_last_5,
	DENSE_RANK() OVER(ORDER BY count DESC) AS count_rank,
 	ROUND(total_size) AS total_size,
 	MAX(ROUND(total_size)) OVER(ORDER BY Y_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS max_tsize_until_now,
 	MAX(ROUND(total_size)) OVER(ORDER BY Y_start ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)  AS max_tsize_last_5,
	DENSE_RANK() OVER(ORDER BY total_size DESC) AS tsize_rank
FROM fire_avg;

-- With this results, I can tell that the wildfires are more frequent than in the past (having a big peack in the 
-- interval between 2005 and 2011) and they are burning more area than before.