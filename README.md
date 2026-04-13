# NBA PLAYER STATS

## Introduction

I analyse the given dataset covering NBA players across many seasons with information on age, height, weight, draft position, and advanced stats (points, rebounds, assists, usage %, true shooting %, etc.).

## Project Overview

This project analyzes NBA player statistics to:

- Calculate a weighted MVP index for each season.
- Compare your data-driven MVP picks with actual NBA MVPs
- Build a dream starting 5 (PG, SG, SF, PF, C) using height + stats + role.
- Identify most improved players, top-performing teams, and player size trends across decades

All analysis is done in PostgreSQL using pure SQL

## Technologies Used

- PostgreSQL - for data storage and analysis
- SQL - for all queries, CTEs, window functions, and aggregations
- VS Code - for editing and running SQL queries
- Qwen 3 - for AI-assisted query building and debugging

## Data Cleaning and ETL

Before analysis, the following steps were taken to ensure data integrity:

Trimmed whitespaces: Use `trim(player_name)` to remove all leadin whitespaces from the string.

Deduplication: Resolved records for players traded mid-season to avoid double-counting totals.

```sql
  DELETE FROM allseasons
  WHERE id NOT IN (
      SELECT MIN(id)
      FROM allseasons
      GROUP BY player_name, season, team_abbreviation
  );
```

Handled Outliers: Resolved the outliers by getting the average of players with outliers exluding season with outlier then updating outliers with individual averages.

## The main objectives were:

## Player Performance Analysis

- Rank players in each season by points, rebounds, assists per game.
- Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
- Identify most improved players across seasons (biggest jump in points/rebounds/assists).

## Era & Team Comparisons

- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
- Identify which teams consistently produce top-performing players.
- Look at rookies vs veterans - how do their contributions differ?

## MVP & Dream Team

- Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.
- Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.

- Bonus: Compare your MVP pick with the actual NBA MVP that season.

# Key Findings

## Player Performance Analysis

- Comparing efficiency stats: There is little to no correlation between true shooting percentage and usage rate for players averaging above 25 points per game.Volume scorers don't sacrifice efficiency.
  <img width="576" height="455" alt="TS vs usage rate comp" src="https://github.com/user-attachments/assets/dbb49949-565c-4569-a4fe-878d9b5b63a3" />

- Most improved players across seasons:
  - Scoring: MarShon Brooks improved by 15.6 points in 2017, Louis King by 15.5 points in 2022 and JaKarr Sampson 15.3 points in 2018.

  - Rebounding: Julius Randle improved by 10.2 rebounds in 2015,Danny Fortson improved by 9.6 rebounds in 2000 and Jaylen Hoard improved by 8.6 rebounds in 2021.

  - Playmaking: Skylar Mars improved by 7.7 assists in 2022, Derrick Walton Jr. improved by 6 assists in 2021 and Kendall Marshall improved by 5.8 assists in 2013.

## Era and Team Comparisons

- **Player size trends**: Average height and weight have decreased since the 1990s, with a slight plateau in the 2020s. This may reflect increased emphasis on athleticism and versatility.
- **Scoring trends**: Points and assists per game have risen, likely due to faster pace and 3-point shooting. Rebounds have remained stable, suggesting teams prioritize spacing over rebounding.
- **Top-performing teams**: The Lakers, Phoenix Suns, Minnesota Timberwolves, Philadelphia Sixers, and Utah Jazz consistently produced top-5 players in scoring, rebounding, or assists across multiple seasons.

- **Vets vs Rookies**: The veterans were significantly better than the rookies in every metric except usage rate. This is due to gaining experience the more games you play.

## MVP & Dream Team Selection

Comparing the weighted mvp to the actual shows that the model is fairly accurate in predicting the actual mvp.

My dream team would include Russell Westbrook as the point guard, Stephen Curry as the shooting guard, Lebron James as the small forward, Giannis Antetokounmpo as the power forward and Shaquille O'neal as the centre
