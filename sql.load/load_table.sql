COPY allseasons
FROM 'C:\Users\PC\Desktop\Developer\nba stats\all_seasons.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );