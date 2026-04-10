/*
 MVP & Dream Team
 Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.
 Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.
 Bonus: Compare your MVP pick with the actual NBA MVP that season.
 */
WITH mvp_index AS (
    SELECT player_name,
        season,
        points_per_game,
        assist_per_game,
        rebound,
        true_shooting_pct,
        net_rating,
        -- Weighted index: 40% PPG, 30% (AST + REB), 30% (TS% + NET)
        ROUND(
            CAST(
                (points_per_game * 0.4) + ((assist_per_game + rebound) * 0.3) + ((true_shooting_pct + net_rating) * 0.3) AS NUMERIC
            ),
            2
        ) AS mvp_score
    FROM allseasons
    WHERE points_per_game IS NOT NULL
        AND assist_per_game IS NOT NULL
        AND rebound IS NOT NULL
        AND true_shooting_pct IS NOT NULL
        AND net_rating IS NOT NULL
),
ranked_mvp AS (
    SELECT player_name,
        season,
        mvp_score,
        RANK() OVER (
            PARTITION BY season
            ORDER BY mvp_score DESC
        ) AS mvp_rank
    FROM mvp_index
)
SELECT season,
    player_name AS your_mvp,
    mvp_score
FROM ranked_mvp
WHERE mvp_rank = 1
ORDER BY season;
--comparing the weighted mvp to the actual mvp
-- Create the actual MVP table
WITH nba_mvp AS (
    SELECT '1996' AS season,
        'Michael Jordan' AS actual_mvp
    UNION ALL
    SELECT '1997',
        'Michael Jordan'
    UNION ALL
    SELECT '1998',
        'Karl Malone'
    UNION ALL
    SELECT '1999',
        'Shaquille O’Neal'
    UNION ALL
    SELECT '2000',
        'Allen Iverson'
    UNION ALL
    SELECT '2001',
        'Tim Duncan'
    UNION ALL
    SELECT '2002',
        'Kevin Garnett'
    UNION ALL
    SELECT '2003',
        'Kevin Garnett'
    UNION ALL
    SELECT '2004',
        'Steve Nash'
    UNION ALL
    SELECT '2005',
        'Steve Nash'
    UNION ALL
    SELECT '2006',
        'Dirk Nowitzki'
    UNION ALL
    SELECT '2007',
        'Kobe Bryant'
    UNION ALL
    SELECT '2008',
        'LeBron James'
    UNION ALL
    SELECT '2009',
        'LeBron James'
    UNION ALL
    SELECT '2010',
        'Derrick Rose'
    UNION ALL
    SELECT '2011',
        'LeBron James'
    UNION ALL
    SELECT '2012',
        'LeBron James'
    UNION ALL
    SELECT '2013',
        'Kevin Durant'
    UNION ALL
    SELECT '2014',
        'Stephen Curry'
    UNION ALL
    SELECT '2015',
        'Stephen Curry'
    UNION ALL
    SELECT '2016',
        'Kevin Durant'
    UNION ALL
    SELECT '2017',
        'James Harden'
    UNION ALL
    SELECT '2018',
        'Giannis Antetokounmpo'
    UNION ALL
    SELECT '2019',
        'LeBron James'
    UNION ALL
    SELECT '2020',
        'Giannis Antetokounmpo'
    UNION ALL
    SELECT '2021',
        'Nikola Jokić'
    UNION ALL
    SELECT '2022',
        'Nikola Jokić'
    UNION ALL
    SELECT '2023',
        'Nikola Jokić'
),
your_mvp AS (
    WITH mvp_index AS (
        SELECT player_name,
            season,
            ROUND(
                CAST(
                    (COALESCE(points_per_game, 0) * 0.4) + (
                        (
                            COALESCE(assist_per_game, 0) + COALESCE(rebound, 0)
                        ) * 0.3
                    ) + (
                        (
                            COALESCE(true_shooting_pct, 0) + COALESCE(net_rating, 0)
                        ) * 0.3
                    ) AS NUMERIC
                ),
                2
            ) AS mvp_score
        FROM allseasons
        WHERE points_per_game IS NOT NULL
            AND assist_per_game IS NOT NULL
            AND rebound IS NOT NULL
            AND true_shooting_pct IS NOT NULL
            AND net_rating IS NOT NULL
    ),
    ranked_mvp AS (
        SELECT player_name,
            season,
            mvp_score,
            RANK() OVER (
                PARTITION BY season
                ORDER BY mvp_score DESC
            ) AS mvp_rank
        FROM mvp_index
    )
    SELECT season,
        player_name AS your_mvp,
        mvp_score
    FROM ranked_mvp
    WHERE mvp_rank = 1
)
SELECT ym.season,
    ym.your_mvp,
    nm.actual_mvp,
    CASE
        WHEN ym.your_mvp = nm.actual_mvp THEN '✅ Match'
        ELSE '❌ Miss'
    END AS result
FROM your_mvp ym
    JOIN nba_mvp nm ON ym.season = nm.season
ORDER BY ym.season;
--build your dream team
WITH player_roles AS (
    SELECT player_name,
        season,
        player_height,
        points_per_game,
        assist_per_game,
        rebound,
        true_shooting_pct,
        net_rating,
        usage_pct,
        -- Estimate position based on height + role
        CASE
            -- Point Guard: Under 6'6" (198 cm), high assists
            WHEN player_height <= 198
            AND assist_per_game >= 8 THEN 'PG' -- Shooting Guard: Under 6'6" (198 cm), high scoring, moderate assists
            WHEN player_height <= 198
            AND points_per_game >= 18
            AND assist_per_game < 6 THEN 'SG' -- Small Forward: 6'6"–6'9" (198–206 cm), versatile
            WHEN player_height BETWEEN 198 AND 206 THEN 'SF' -- Power Forward: 6'8"–6'11" (203–211 cm), rebounds, scores inside
            WHEN player_height BETWEEN 203 AND 211 THEN 'PF' -- Center: 6'10"+ (208 cm+), rebounds, blocks, low assists
            WHEN player_height >= 208 THEN 'C'
            ELSE 'Other'
        END AS estimated_position
    FROM allseasons
    WHERE points_per_game IS NOT NULL
        AND assist_per_game IS NOT NULL
        AND rebound IS NOT NULL
        AND true_shooting_pct IS NOT NULL
        AND net_rating IS NOT NULL
),
position_scores AS (
    SELECT player_name,
        estimated_position,
        ROUND(
            CAST(
                (points_per_game * 0.4) + ((assist_per_game + rebound) * 0.3) + ((true_shooting_pct + net_rating) * 0.3) AS NUMERIC
            ),
            2
        ) AS position_score
    FROM player_roles
),
ranked_positions AS (
    SELECT player_name,
        estimated_position,
        position_score,
        ROW_NUMBER() OVER (
            PARTITION BY estimated_position
            ORDER BY position_score DESC
        ) AS pos_rank
    FROM position_scores
)
SELECT estimated_position,
    player_name,
    position_score
FROM ranked_positions
WHERE pos_rank = 1
ORDER BY CASE
        estimated_position
        WHEN 'PG' THEN 1
        WHEN 'SG' THEN 2
        WHEN 'SF' THEN 3
        WHEN 'PF' THEN 4
        WHEN 'C' THEN 5
    END;