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
- <img width="1389" height="590" alt="average height and weight over time" src="https://github.com/user-attachments/assets/11cdfe16-fd8f-4ce6-a25b-066bd64b8db6" />

- **Scoring trends**: Points and assists per game have risen, likely due to faster pace and 3-point shooting. Rebounds have remained stable, suggesting teams prioritize spacing over rebounding.
- **Top-perorming teams**: The Lakers, Phoenix Suns, Minnesota Timberwolves, Philadelphia Sixers, and Utah Jazz consistently produced top-5 players in scoring, rebounding, or assists across multiple seasons.
- **Vets vs Rookies**: The veterans were significantly better than the rookies in every metric except usage rate. This is due to gaining experience the more games you play.
- <img width="1489" height="1490" alt="rookie vs vet comp" src="https://github.com/user-attachments/assets/33da3f09-976a-43eb-aee9-834846deb339" />

## MVP & Dream Team Selection

Comparing the weighted mvp to the actual shows that the model is fairly accurate in predicting the actual mvp.
-- 40% Points, 30% (Assists + Rebounds), 30% (TS% + Net Rating)
- <img width="790" height="590" alt="weighted vs actual mvp comp" src="https://github.com/user-attachments/assets/85cd7845-47d5-482d-ac7e-4edd86e373d8" />


My dream team would include Russell Westbrook as the point guard, Stephen Curry as the shooting guard, Lebron James as the small forward, Giannis Antetokounmpo as the power forward and Shaquille O'neal as the centre

## Conclusion

This project successfully demonstrates the power of **pure SQL analysis** in 
extracting meaningful insights from NBA player data spanning multiple decades. 
Using PostgreSQL, we were able to build a **data-driven framework** for 
evaluating player performance, predicting MVPs, and constructing a dream team 
— all without the need for external tools or programming languages.

---

### What the Analysis Got Right

- **MVP Prediction**: The weighted index (40% PPG, 30% AST+RPG, 30% TS%+NET) 
  proved to be a **reliable predictor** of actual NBA MVPs, correctly 
  identifying winners across most seasons. This suggests that a combination 
  of scoring, playmaking, and efficiency is a strong proxy for MVP-caliber 
  performance.

- **Most Improved Players**: The year-over-year improvement analysis using 
  `LAG()` successfully identified players with the biggest jumps in scoring, 
  rebounding, and playmaking — providing a **data-backed definition** of 
  improvement rather than a subjective one.

- **Rookie vs Veteran Comparison**: Veterans consistently outperformed rookies 
  in every key metric except usage rate — confirming the widely held belief 
  that **experience translates to better performance** in the NBA.

- **Era Comparisons**: The decade-by-decade analysis revealed clear trends in 
  player size and performance — showing how the game has evolved toward 
  **faster pace, higher scoring, and greater positional versatility**.

- **Team Performance**: Identifying teams that consistently produce top-5 
  players provided a **quantifiable measure of organizational excellence** — 
  going beyond wins and losses to evaluate talent development.

---

## Where Further Analysis is Needed

- **Dream Team Position Logic**: While using **height + stats** improved 
  position assignment significantly (e.g., correctly placing Giannis at PF 
  instead of SG), the logic still has **overlapping height ranges** for PF 
  and C. A more robust approach would incorporate:
  - **Shot zone data** (e.g., % of shots from paint vs. perimeter)
  - **Defensive stats** (e.g., blocks for centers, steals for guards)
  - **Actual position data** (if available in the dataset)

- **MVP Model Accuracy**: While the weighted index performed well, it 
  **does not account for**:
  - **Narrative factors** (e.g., team record, media perception)
  - **Defensive impact** (e.g., DPOY-caliber seasons)
  - **Advanced metrics** (e.g., win shares, VORP, PER)
  - A more complete model would incorporate these factors for **higher 
    predictive accuracy**.

- **Outlier Handling**: Replacing outliers with player averages is a 
  reasonable approach, but **may not always be accurate** - especially for 
  players with small sample sizes (e.g., injured players with few games). 
  A more robust approach would:
  - Filter by **minimum games played** (e.g., ≥ 50 games)
  - Use **median** instead of mean for skewed distributions

- **Correlation Analysis**: The observation that **volume scorers don't 
  sacrifice efficiency** was based on visual inspection - not a formal 
  statistical test. A more rigorous analysis would:
  - Calculate **Pearson's r** between usage rate and TS%
  - Test for **statistical significance** (p-value < 0.05)
  - Control for **position and era** to avoid confounding variables

- **Era Comparisons**: The finding that players were taller and heavier in 
  the 2000s needs **further validation** - specifically:
  - Breaking down size trends **by position** (e.g., are centers getting 
    shorter? Are guards getting taller?)
  - Accounting for **rule changes** (e.g., hand-checking rules in 2004) 
    that may have influenced player size preferences

---

## Future Work

To build on this analysis, future work could include:

1. **Add defensive stats** (blocks, steals, defensive rating) to the MVP 
   index and dream team selection
2. **Incorporate shot zone data** for more accurate position assignment
3. **Build a machine learning model** (e.g., logistic regression) to predict 
   MVPs with higher accuracy
4. **Visualize findings** using Tableau, Power BI, or Python (matplotlib/seaborn)
5. **Expand the dataset** to include playoff stats, All-Star selections, and 
   award voting data
6. **Validate correlation findings** using formal statistical tests

---

###  Final Thoughts

> *"Data tells a story — but only if you ask the right questions."*

This project laid a **strong foundation** for NBA performance analysis using 
SQL. While some findings are **statistically sound and well-supported**, others 
require **deeper investigation and more sophisticated methods** to be fully 
validated. The insights generated here are a **starting point** - not a final 
verdict - and serve as a compelling case for the power of **data-driven 
decision making in sports analytics**.

---

>  **Built with ❤️ for basketball fans and data nerds alike.**

