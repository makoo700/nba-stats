CREATE TABLE allseasons_copy AS (
    SELECT *
    FROM allseasons
);
UPDATE allseasons
SET player_name = NULLIF(TRIM(player_name), ''),
    team_abbreviation = NULLIF(TRIM(team_abbreviation), ''),
    college = NULLIF(TRIM(college), ''),
    country = NULLIF(TRIM(country), ''),
    draft_year = CAST(NULLIF(TRIM(draft_year), 'Undrafted') AS INT),
    draft_round = CAST(NULLIF(TRIM(draft_round), 'Undrafted') AS INT),
    draft_number = CAST(NULLIF(TRIM(draft_number), 'Undrafted') AS INT),
    season = CAST(LEFT(TRIM(season), 4) AS INT);
-- check for duplicates
SELECT player_name,
    team_abbreviation,
    age,
    player_height,
    player_weight,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    games_played,
    points_per_game,
    rebound,
    assist_per_game,
    net_rating,
    offensive_rebound_pct,
    defensive_rebound_pct,
    usage_pct,
    true_shooting_pct,
    assist_pct,
    season
FROM allseasons
GROUP BY player_name,
    team_abbreviation,
    age,
    player_height,
    player_weight,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    games_played,
    points_per_game,
    rebound,
    assist_per_game,
    net_rating,
    offensive_rebound_pct,
    defensive_rebound_pct,
    usage_pct,
    true_shooting_pct,
    assist_pct,
    season
HAVING COUNT(*) > 1;
-- no duplicates exist
-- how many seasons have there been? 
SELECT COUNT(DISTINCT season) AS num_of_seasons
FROM allseasons;
SELECT MIN(season) AS start_season,
    MAX(season) AS last_season
FROM allseasons;
-- There are 27 seasons spanning from 1996 to 2022
--How many unique players are in the dataset?
SELECT COUNT (DISTINCT player_name)
FROM allseasons;
-- 2551 unique players
--check for maximums and minimums from stats to check for outliers
SELECT MAX(games_played) AS max_gp,
    MIN(games_played) AS min_gp,
    MAX(points_per_game) AS max_ppg,
    MIN(points_per_game) AS min_ppg,
    MAX(rebound) AS max_rbnd,
    MIN(rebound) AS min_rbnd,
    MAX(assist_per_game) AS max_apg,
    MIN(assist_per_game) AS min_apg
FROM allseasons;
--check for outliers in advanced stats
SELECT MAX(net_rating) AS max_net,
    MIN(net_rating) AS min_ret,
    MAX(true_shooting_pct) AS max_tsp,
    MIN(true_shooting_pct) AS min_tsp,
    MAX(usage_pct) AS max_up,
    MIN(usage_pct) AS min_up,
    MAX(offensive_rebound_pct) AS max_orp,
    MIN(offensive_rebound_pct) AS min_orp,
    MAX(defensive_rebound_pct) AS max_drp,
    MIN(defensive_rebound_pct) AS min_drp,
    MAX(assist_pct) AS max_apct,
    MIN(assist_pct) AS min_apct
FROM allseasons;
-- advanced stats are measured from 0 to 1 only true shooting percentage has a max of 1.5 
--checking for outliers in true shooting percentage 
SELECT player_name,
    true_shooting_pct,
    season,
    games_played,
    net_rating
FROM allseasons
WHERE true_shooting_pct > 1;
-- checking for outliers in net rating
SELECT player_name,
    games_played,
    net_rating,
    season,
    points_per_game
FROM allseasons
WHERE net_rating <= -30
    OR net_rating >= 30;
/*Handling outliers
 1.get players with outliers
 2.get the average of players with outliers ecluding season with outlier
 3.update outliers with individual averages
 */
--get players with outliers
CREATE TEMPORARY TABLE players_with_outliers AS
SELECT DISTINCT player_name,
    net_rating,
    true_shooting_pct
FROM allseasons
WHERE net_rating < -30
    OR net_rating > 30
    OR true_shooting_pct > 1;
SELECT *
FROM players_with_outliers;
--get avg of players with outliers
WITH pwo_avg AS (
    SELECT allsn.player_name,
        AVG(
            CASE
                WHEN allsn.net_rating BETWEEN -30 AND 30 THEN allsn.net_rating
            END -- Average net_rating, but only for values between -30 and 30 (exclude outliers)
        ) AS avg_net_rating,
        AVG(
            CASE
                WHEN allsn.true_shooting_pct <= 1 THEN allsn.true_shooting_pct
            END -- Average true_shooting_pct, but only for values <= 1 (exclude impossible values)
        ) AS avg_ts_pct
    FROM allseasons AS allsn
        JOIN players_with_outliers AS pwo ON allsn.player_name = pwo.player_name
    GROUP BY allsn.player_name
) --update outliers
UPDATE allseasons AS allsn
SET net_rating = CASE
        WHEN allsn.net_rating > 30
        OR allsn.net_rating < -30 THEN pwo_avg.avg_net_rating -- replaces outlier net rating with player's average
        ELSE allsn.net_rating
    END,
    true_shooting_pct = CASE
        WHEN allsn.true_shooting_pct > 1 THEN pwo_avg.avg_ts_pct --replaces outlier with average true shooting percentage
        ELSE allsn.true_shooting_pct
    END
FROM pwo_avg
WHERE allsn.player_name = pwo_avg.player_name;
SELECT DISTINCT player_name
FROM allseasons
WHERE true_shooting_pct > 1.0
    OR net_rating > 30
    OR net_rating < -30;