-- SQLite
-- AIM:  generate a list of matches in which Manchester United was defeated during the 2014/2015 English Premier League season.

-- 1. Setting up the home team CTE
/* Create a CASE statement that identifies each match as a win, lose, or tie for 'Manchester United'.
Fill out the logical operators for each WHEN clause in the CASE statement (greater than, less than, equals).
Join the tables on hometeam_id from match, and team_api_id from team.
Filter the query to only include games from the '2014/2015' season where 'Manchester United' was the home team.*/
SELECT 
	m.id, 
    t.team_long_name,
    -- Identify matches as home/away wins or ties
	CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Win'
		 WHEN m.home_team_goal < m.away_team_goal THEN 'MU Loss'
         ELSE 'Tie' END AS outcome
FROM match AS m
-- Left join team on the hometeam_ID and team_API_id
LEFT JOIN team AS t 
ON m.home_team_api_id = t.team_api_id
WHERE 
	-- Filter for 2014/2015 and Manchester United as the home team
	m.season = '2014/2015'
	AND t.team_long_name = 'Manchester United';

/* Identify the away team*/
SELECT 
	m.id, 
    t.team_long_name,
    -- Identify matches as home/away wins or ties
	CASE  WHEN m.home_team_goal > m.away_team_goal THEN 'MU Loss'
		WHEN m.home_team_goal < m.away_team_goal THEN 'MU Win'
        ELSE 'Tie' END AS outcome
-- Join the match table's awayteam_id to the team table
FROM match AS m
LEFT JOIN team AS t 
ON m.away_team_api_id = t.team_api_id
WHERE 
	-- Filter for 2014/2015 and Manchester United as the away team
	m.season = '2014/2015'
	AND t.team_long_name = 'Manchester United';


-- rearrange your query with the home and away subqueries as Common Table Expressions (CTEs). You'll notice that the main query includes the phrase, SELECT DISTINCT. Without identifying only DISTINCT matches, you might return a duplicate record for each game played.
/*Declare the home and away CTEs before your main query.
Join your CTEs to the match table using a LEFT JOIN.
Select the relevant data from the CTEs into the main query.
Select the date from match, team names from the CTEs, and home/ away goals from match in the main query.
*/


-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Win'
		   WHEN m.home_team_goal < m.away_team_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.home_team_api_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Loss'
		   WHEN m.home_team_goal < m.away_team_goal THEN 'MU Win' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.away_team_api_id = t.team_api_id)
-- Select the date, team names and goals
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team_name,
    away.team_long_name AS away_team_name,
    m.home_team_goal,
    m.away_team_goal
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND (home.team_long_name = 'Manchester United' 
           OR away.team_long_name = 'Manchester United');



-- Add a window function
-- Answer: how badly did Manchester United lose in each match?
-- add a window function to the main query that ranks matches by the absolute value of the difference between home_team_goal and away_team_goal. This allows us to directly compare the difference in scores without having to consider whether Manchester United played as the home or away team!
/*
Set up the CTEs so that the home and away teams each have a name, ID, and score associated with them.
Select the date, home team name, away team name, home goals, and away goals scored in the main query.
Rank the matches and order by the difference in scores in descending order.*/


-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Win'
		   WHEN m.home_team_goal < m.away_team_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.home_team_api_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Loss'
		   WHEN m.home_team_goal < m.away_team_goal THEN 'MU Win' 
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.away_team_api_id = t.team_api_id)
-- Select columns and and rank the matches by goal difference
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_team_goal, m.away_team_goal,
    RANK() OVER(ORDER BY ABS(m.home_team_goal - m.away_team_goal) DESC) as match_rank
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));