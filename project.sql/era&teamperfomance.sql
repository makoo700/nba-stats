/*
 2.Era & Team Comparisons
 Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
 Identify which teams consistently produce top-performing players.
 Look at rookies vs veterans - how do their contributions differ?
 */
--comparing height & weight across different eras
WITH player_decades AS (
    SELECT player_name,
        season,
        player_height,
        player_weight,
        CONCAT(LEFT(season, 3), '0s') AS decade
    FROM allseasons
    WHERE player_height IS NOT NULL
        AND player_weight IS NOT NULL
),
decade_stats AS (
    SELECT decade,
        COUNT(*) AS player_count,
        ROUND(CAST(AVG(player_height) AS NUMERIC), 1) AS avg_height_cm,
        ROUND(CAST(AVG(player_weight) AS NUMERIC), 1) AS avg_weight_kg,
        ROUND(
            CAST(AVG(player_height * 0.0328084) AS NUMERIC),
            1
        ) AS avg_height_ft,
        ROUND(
            CAST(AVG(player_weight * 0.00220462) AS NUMERIC),
            1
        ) AS avg_weight_lbs
    FROM player_decades
    GROUP BY decade
)
SELECT decade,
    player_count,
    avg_height_cm,
    avg_weight_kg,
    avg_height_ft,
    avg_weight_lbs
FROM decade_stats
ORDER BY decade;
CREATE TEMPORARY TABLE ERA AS(
    SELECT player_name,
        season,
        points_per_game,
        assist_per_game,
        rebound,
        true_shooting_pct,
        usage_pct,
        CONCAT(LEFT(season, 3), '0s') AS decade
    FROM allseasons
    WHERE points_per_game IS NOT NULL
        AND assist_per_game IS NOT NULL
        AND true_shooting_pct IS NOT NULL
        AND usage_pct IS NOT NULL
);
SELECT decade,
    COUNT(*) AS player_count,
    ROUND(CAST(AVG(points_per_game) AS NUMERIC), 1) AS avg_ppg,
    ROUND(CAST(AVG(assist_per_game) AS NUMERIC), 1) AS avg_apg,
    ROUND(CAST(AVG(rebound) AS NUMERIC), 1) AS avg_rpg,
    ROUND(CAST(AVG(true_shooting_pct) AS NUMERIC), 1) AS avg_ts,
    ROUND(CAST(AVG(usage_pct) AS NUMERIC), 1) AS avg_up
FROM ERA
GROUP BY decade
ORDER BY decade;
DROP TEMPORARY TABLE ERA;
--Identify which teams consistently produce top-performing players
CREATE VIEW performance_ranking AS(
    SELECT player_name,
        points_per_game,
        assist_per_game,
        rebound,
        season,
        team_abbreviation,
        net_rating,
        RANK() OVER(
            PARTITION BY season
            ORDER BY points_per_game DESC
        ) AS pts_rank,
        RANK() OVER(
            PARTITION BY season
            ORDER BY assist_per_game DESC
        ) AS ast_rank,
        RANK() OVER(
            PARTITION BY season
            ORDER BY rebound DESC
        ) AS rbd_rank,
        RANK() OVER(
            PARTITION BY season
            ORDER BY net_rating DESC
        ) AS net_rank
    FROM allseasons
);
SELECT *
FROM performance_ranking;
--top players by points per game
SELECT player_name,
    team_abbreviation,
    season,
    points_per_game,
    net_rating
FROM performance_ranking
WHERE pts_rank <= 5;
--top players by assists per game 
SELECT player_name,
    team_abbreviation,
    season,
    assist_per_game,
    net_rating
FROM performance_ranking
WHERE ast_rank <= 5;
--top players by rebounds
SELECT player_name,
    team_abbreviation,
    season,
    rebound,
    net_rating
FROM performance_ranking
WHERE rbd_rank <= 5;