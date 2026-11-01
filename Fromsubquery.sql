--The match table in the European Soccer Database does not contain country or team names. You can get this information by joining it to the country table, and use this to aggregate information, such as the number of matches played in each country.
--If you're interested in filtering data from one of these tables, you can also create a subquery from one of the tables, and then join it to an existing table in the database. A subquery in FROM is an effective way of answering detailed questions that requires filtering or transforming data before including it in your final results.
--Your goal in this exercise is to generate a subquery using the match table, and then join that subquery to the country table to calculate information about matches with 10 or more goals in total!

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


--Building on Subqueries in FROM
--In the previous exercise, you found that England, Netherlands, Germany and Spain were the only countries that had matches in the database where 10 or more goals were scored overall. Let's find out some more details about those matches 
-- when they were played, during which seasons, and how many of the goals were home versus away goals.
--You'll notice that in this exercise, the table alias is excluded for every column selected in the main query. This is because the main query is extracting data from the subquery, which is treated as a single table.
SELECT
	-- Select country, date, home, and away goals from the subquery
    country,
    date,
    home_goal,
    away_goal
FROM 
	-- Select country name, date, home_goal, away_goal, and total goals in the subquery
	(SELECT c.name AS country, 
     	    m.date, 
     		m.home_goal, 
     		m.away_goal,
           (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
-- Filter by total goals scored in the main query
WHERE total_goals >= 10;

--Subqueries in SELECT statements generate a single value that allow you to pass an aggregate value down a data frame. This is useful for performing calculations on data within your database.
--In the following exercise, you will construct a query that calculates the average number of goals per match in each country's league.

SELECT 
	l.name AS league,
    -- Round the average of the league's total goals
    ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
    -- Select and round the average total goals for the season
    (SELECT ROUND(AVG(home_goal + away_goal), 2) 
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Filter for the 2013/2014 season
WHERE m.season = '2013/2014'
GROUP BY l.name;

--Subqueries in Select for Calculations
-- Subqueries in SELECT are a useful way to create calculated columns in a query. A subquery in SELECT can be treated as a single numeric value to use in your calculations. When writing queries in SELECT, it's important to remember that filtering the main query does not filter the subquery -- and vice versa.
-- In the previous exercise, you created a column to compare each league's average total goals to the overall average goals in the 2013/2014 season. In this exercise, you will add a column that directly compares these values by subtracting the overall average from the subquery.
SELECT
	-- Select the league name and average goals scored
	l.name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Subtract the overall average from the league average
	ROUND(AVG(m.home_goal + m.away_goal) - 
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Only include 2013/2014 results
WHERE season = '2013/2014'
GROUP BY l.name;


--In soccer leagues, games are played at different stages. Winning teams progress from one stage to the next, until they reach the final stage. In each stage, the stakes become higher than the previous one. The match table includes data about the different stages that each match took place in.
SELECT 
	-- Select the stage and average goals for each stage
	m.stage,
    ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Select the average overall goals for the 2012/2013 season
    ROUND((SELECT AVG(home_goal + away_goal) 
           FROM match 
           WHERE season = '2012/2013'),2) AS overall
FROM match AS m
-- Filter for the 2012/2013 season
WHERE season = '2012/2013'
-- Group by stage
GROUP BY m.stage;

--Add a subquery in FROM
--Calculate the average total goals from the match table for each stage in the FROM clause subquery.
--Add a subquery to the WHERE clause that calculates the overall average total goals.
--Filter the main query for stages where the average total goals is higher than the overall average.
--Select the stage and avg_goals columns from the s subquery into the main query.

SELECT 
	-- 4. Select the stage and average goals from the subquery
	s.stage,
	ROUND(s.avg_goals,2) AS avg_goals
FROM 
	-- 1. Select the stage and average goals in 2012/2013
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	-- 2. 3. Filter the main query using the subquery
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');


-- Add a subquery in SELECT
--you will add a subquery in SELECT to compare the average number of goals scored in each stage to the total.
--Create a subquery in SELECT that yields the average total goals scored in the 2012/2013 season and stores it in a column named overall_avg
-- Create a subquery in FROM that calculates the average total goals scored in each stage during the 2012/2013 season.
-- Filter the main query for stages where the average total goals exceeds the overall average in 2012/2013.
SELECT 
	-- 4.Select the stage and average goals from s
	s.stage,
    ROUND(s.avg_goals,2) AS avg_goal,
    -- 1. Select the overall average for 2012/2013
    (SELECT AVG(home_goal + away_goal) FROM match WHERE season = '2012/2013') AS overall_avg
FROM 
	-- 2. Select the stage and average goals in 2012/2013 from match
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	-- 3. Filter the main query using the subquery
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');


-- Correlated subqueries
-- Correlated subqueries are subqueries that reference one or more columns in the main query. Correlated subqueries depend on information in the main query to run, and thus, cannot be executed on their own.
-- Correlated subqueries are evaluated in SQL once per row of data retrieved—a process that takes a lot more computing power and time than a simple subquery.
-- In this exercise, you will practice using correlated subqueries to examine matches with scores that are extreme outliers for each country—above 3 times the average score!
-- Start the subquery in WHERE by taking the average/mean of the home and away goals.
-- Complete the subquery column references, so that country_id is matched in the main and sub tables.
SELECT 
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE 
	-- Filter the main query by the subquery
	(home_goal + away_goal) > 
        (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
         FROM match AS sub
         -- Join the main query to the subquery with country_id in WHERE
         WHERE main.country_id = sub.country_id);

-- Complete the subquery to select the matches with the highest number of total goals.
-- Match the subquery to the main query using the country_id and season columns in both tables.
SELECT 
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE 
	-- Filter for matches with the maximum number of total goals scored
	(home_goal + away_goal) = 
        (SELECT max(sub.home_goal + sub.away_goal)
         FROM match AS sub
         -- Join the main query to the subquery in WHERE
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);

-- Nested subqueries (use to filter and aggregation)
-- Nested subqueries are subqueries that contain another subquery within them. Nested subqueries can be used to perform multiple levels of filtering or aggregation, allowing for more complex queries and data analysis.
-- You'll compare the maximum number of goals scored in a single match across each season against the maximum for the England Premier League.
-- Complete a nested subquery to select the country_id for 'England Premier League' from league, which will be used to filter the parent subquery.

SELECT 
    season,
    MAX(home_goal + away_goal) AS max_goals,
    (SELECT MAX(home_goal + away_goal) 
     FROM match 
     WHERE season = main.season
     -- Subquery to get the max goals in an 'England Premier League' match for the same season
     AND country_id IN (SELECT country_id FROM league WHERE name = 'England Premier League')
    ) AS pl_max_goals
FROM match AS main
GROUP BY season;


-- Nest a subquery in FROM
-- What's the average number of matches per season where a team scored 5 or more goals? How does this differ by country?
-- Let's use a nested, correlated subquery to perform this operation. In the real world, you will probably find that nesting multiple subqueries is a task you don't have to perform often. In some cases, however, you may find yourself struggling to properly group by the column you want, or to calculate information requiring multiple mathematical transformations (i.e., an AVG of a COUNT).
-- Nesting subqueries and performing your transformations one step at a time, adding it to a subquery, and then performing the next set of transformations is often the easiest way to yield accurate information about your data. Let's get to it!

-- 1. Generate a list of matches where at least one team scored 5 or more goals.
SELECT
	country_id,
    season,
	id
FROM match
WHERE home_goal >= 5  OR away_goal  >= 5;

/*2. Turn the query from the previous step into a subquery in the FROM statement.
COUNT the match table ids generated in the previous step. */
-- Count match ids
SELECT
    country_id,
    season,
    COUNT(subquery.country_id) AS matches
-- Set up and alias the subquery
FROM (
	SELECT
    	country_id,
    	season,
    	id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5)
    AS subquery
GROUP BY country_id, season;

/*Finally, declare the same query from step 2 as a subquery in FROM with the alias outer_s.
Left join it to the country table using the outer query's country_id column.
Calculate an AVG of high scoring matches per country in the main query.*/

SELECT
	c.name AS country,
    -- Calculate the average matches per season
	AVG(outer_s.matches) AS avg_seasonal_high_scores  --step 4
FROM country AS c
-- Left join outer_s to country
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS inner_s  -- step 1
  -- Close parentheses and alias the subquery
  GROUP BY country_id, season) AS outer_s  --step 2
ON c.id = outer_s.country_id   -- step 3
GROUP BY country;


-- CTEs (Common Table Expressions)
-- You can list one (or more) subqueries as common table expressions (CTEs) by declaring them ahead of your main query, which is an excellent tool for organizing information and placing it in a logical order.
-- In this exercise, let's rewrite a similar query using a CTE.
-- Complete the syntax to declare your CTE.
-- Select the country_id and match id from the match table in your CTE.
-- LEFT JOIN the CTE to the league table using country_id.

-- Set up your CTE
WITH match_list AS (
    SELECT 
  		country_id, 
  		id
    FROM match
    WHERE (home_goal + away_goal) >= 10)
-- Select league name and count of matches from the CTE
SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM league AS l
-- Join the CTE to the league table using country_id
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;


--Declare your CTE, where you create a list of all matches with the league name.
--Select the league, date, home, and away goals from the CTE.
-- Filter the main query for matches with 10 or more goals.
-- Set up your CTE
WITH match_list AS (
  -- Select the league name, date, home, and away goals
    SELECT 
  		l.name AS league, 
     	m.date, 
  		m.home_goal, 
  		m.away_goal,
       (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN league as l ON m.country_id = l.id)
-- Select the league, date, home, and away goals from the CTE
SELECT league, date, home_goal, away_goal
FROM match_list
-- Filter by total goals
WHERE  match_list.total_goals>=10;



-- Declare a CTE that calculates the total goals from matches in August of the '2013/2014' season.
-- Filter the list on the inner subquery to only select matches in August of the '2013/2014' season.
-- LEFT JOIN the CTE onto the league table using country_id from the match_list CTE.
-- Set up your CTE
WITH match_list AS (
    SELECT 
  		country_id,
  	   (home_goal + away_goal) AS goals
    FROM match
  	-- Create a list of match IDs to filter data in the CTE
    WHERE id IN (
       SELECT id
       FROM match
       WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = 08))
-- Select the league name and average of goals in the CTE
SELECT 
	l.name,
    AVG(match_list.goals)
FROM league AS l
-- Join the CTE onto the league table using country_id
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;


--Window function
-- The OVER() clause allows you to apply an aggregate function across a dataset, similar to subqueries in SELECT. The OVER() clause offers significant benefits over subqueries in SELECT -- namely, your queries will run faster, and the OVER() clause has a wide range of additional functions and clauses you can include with it which we will cover later in this chapter.
-- Select the match ID, country name, season, home_goal, and away_goal from the match and country tables.
-- Complete the query that calculates the average number of goals scored overall and then includes the aggregate value in each row using a window function.
SELECT 
	-- Select the match id, country name, season, home, and away goals
	m.id, 
    c.name AS country, 
    m.season,
	m.home_goal,
	m.away_goal,
    -- Use a window to include the aggregate average in each row
	AVG(m.home_goal + m.away_goal) OVER() AS overall_avg
FROM match AS m
LEFT JOIN country AS c ON m.country_id = c.id;



-- RANK() OVER
-- Window functions allow you to create a RANK of information according to any variable you want to use to sort your data. When setting this up, you will need to specify what column/calculation you want to use to calculate your rank. This is done by including an ORDER BY clause inside the OVER() clause. Below is an example:

/*SELECT 
    id,
    RANK() OVER(ORDER BY home_goal) AS rank
FROM match;*/
-- SELECT the league name and average total goals scored from league and match.
--Complete the window function so it calculates the RANK() of average goals scored across all leagues in the database. 
-- Order the rank OVER the average total of home and away goals scored.
SELECT 
	-- Select the league name and average goals scored
	l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    -- Rank each league over the average goals
    RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal)) AS league_rank --or     RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal) DESC)
FROM league AS l
LEFT JOIN match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
-- Order the query by the rank you created
ORDER BY league_rank;