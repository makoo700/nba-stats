UPDATE allseasons
SET player_name = NULLIF(TRIM(player_name), ''),
    team_abbreviation = NULLIF(TRIM(team_abbreviation), ''),
    college = NULLIF(TRIM(college), ''),
    country = NULLIF(TRIM(country), ''),
    draft_year = CAST(NULLIF(TRIM(draft_year), 'Undrafted') AS INT),
    draft_round = CAST(NULLIF(TRIM(draft_round), 'Undrafted') AS INT),
    draft_number = CAST(NULLIF(TRIM(draft_number), 'Undrafted') AS INT),
    season = CAST(LEFT(TRIM(season), 4) AS INT);