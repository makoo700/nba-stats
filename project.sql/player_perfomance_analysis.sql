/*
 1.Player Performance Analysis
 Rank players in each season by points, rebounds, assists per game.
 Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
 Identify most improved players across seasons (biggest jump in points/rebounds/assists).
 */
--ranking by points
SELECT player_name,
    points_per_game,
    season,
    RANK() OVER (
        PARTITION BY season
        ORDER BY points_per_game DESC
    ) AS ppg_rank
FROM allseasons;
--ranking players regardles of season
SELECT player_name,
    points_per_game,
    season,
    RANK() OVER (
        ORDER BY points_per_game DESC
    ) AS ppg_rank
FROM allseasons
ORDER BY ppg_rank ASC;
--ranking by assists
SELECT player_name,
    assist_per_game,
    season,
    RANK() OVER(
        PARTITION BY season
        ORDER BY assist_per_game DESC
    ) AS apg_rank
FROM allseasons;
--ranking by rebounds
SELECT player_name,
    rebound,
    season,
    RANK() OVER(
        PARTITION BY season
        ORDER BY rebound DESC
    ) AS rpg_rank
FROM allseasons;
--compare efficiency stats
SELECT player_name,
    AVG(true_shooting_pct) AS avg_tsp,
    AVG(usage_pct) AS avg_upct
FROM allseasons
WHERE points_per_game > 25
GROUP BY player_name
ORDER BY avg_tsp DESC,
    avg_upct DESC;
--no corelation between high usage rate and high true shooting percentage
--Identify the most improved player across seasons
CREATE TEMPORARY TABLE stat_diff AS (
    SELECT player_name,
        season,
        points_per_game,
        assist_per_game,
        rebound,
        ROUND(
            CAST(
                points_per_game - LAG(points_per_game) OVER (
                    PARTITION BY player_name
                    ORDER BY season
                ) AS NUMERIC
            ),
            3
        ) AS point_diff,
        ROUND(
            CAST(
                rebound - LAG(rebound) OVER (
                    PARTITION BY player_name
                    ORDER BY season
                ) AS NUMERIC
            ),
            3
        ) AS rebound_diff,
        ROUND(
            CAST(
                assist_per_game - LAG(assist_per_game) OVER (
                    PARTITION BY player_name
                    ORDER BY season
                ) AS NUMERIC
            ),
            3
        ) AS assist_diff
    FROM allseasons
);
-- Biggest improvement in point
SELECT player_name,
    season,
    points_per_game,
    point_diff
FROM stat_diff
WHERE point_diff > 0
ORDER BY point_diff DESC
LIMIT 10;
-- Biggest improvement in rebound
SELECT player_name,
    season,
    rebound,
    rebound_diff
FROM stat_diff
WHERE rebound_diff > 0
ORDER BY rebound_diff DESC
LIMIT 10;
-- Biggest improvement in assist_per_game
SELECT player_name,
    season,
    assist_per_game,
    assist_diff
FROM stat_diff
WHERE assist_diff > 0
ORDER BY assist_diff DESC
LIMIT 10;