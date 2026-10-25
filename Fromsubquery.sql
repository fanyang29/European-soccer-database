SELECT 
    c.name AS country_name,
    m.home_goal,
    m.away_goal,
    (m.home_goal + m.away_goal) AS total_goals
FROM country AS c
JOIN (
    -- Subquery filtering matches with 10 or more total goals
    SELECT country_id, home_goal, away_goal
    FROM match
    WHERE (home_goal + away_goal) >= 10
) AS m
ON c.id = m.country_id;