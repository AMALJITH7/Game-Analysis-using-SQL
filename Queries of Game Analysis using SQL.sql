use game;

-- Q1
SELECT level_details2.P_ID, level_details2.Dev_ID,
player_details.PName, level_details2.Difficulty
FROM level_details2 
JOIN player_details  ON
level_details2.P_ID = player_details.P_ID
WHERE level_details2.Level = 0;

-- Q2
 select player_details. L1_Status, avg(Kill_Count)
 from level_details2 
 left join player_details on
 level_details2.P_ID=player_details.P_ID
 where level_details2.Lives_Earned=2
 and level_details2.Stages_crossed>=3 group by
 player_details.L1_Status;
 
 -- Q3
select level_details2. Difficulty,
SUM(level_details2.Stages_crossed) AS 'total number of stages crossed'
FROM level_details2
LEFT JOIN player_details ON level_details2.P_ID = player_details.P_ID
WHERE level_details2.Dev_ID LIKE 'zm%'
AND level_details2.Level = 2
GROUP BY level_details2.Difficulty
ORDER BY SUM(level_details2.Stages_crossed) DESC;

-- Q4
SELECT P_ID, COUNT(DISTINCT start_datetime) AS
 Unique_Dates
 FROM level_details2
 GROUP BY P_ID
 HAVING COUNT(DISTINCT start_datetime) > 1;
 
 -- Q5
WITH MediumAvg AS (
    SELECT AVG(kill_count) AS Avg_kill_Count
    FROM level_details2
    WHERE Difficulty = 'Medium'
)
SELECT P_ID, Level, SUM(kill_count) AS Total_Kill_Count
FROM level_details2
WHERE kill_count > (SELECT Avg_Kill_Count FROM MediumAvg)
GROUP BY P_ID, Level;

-- Q6
SELECT level_details2.Level, player_details.L1_code,
 player_details.L2_code,
 SUM(level_details2.lives_earned) AS Total_Lives_Earned
 FROM level_details2
 INNER JOIN player_details ON level_details2.P_ID=
 player_details.P_ID
 WHERE level_details2.Level!=0
 GROUP BY level_details2.Level,
 player_details.L1_code, player_details.L2_code
 ORDER BY level_details2.Level ASC;

-- Q7
 with table1 as
 (select Dev_ID, Difficulty, Score, row_number() over
 (partition by Dev_ID order by Score desc)
 as Ranked from level_details2)
 select Dev_ID, Score, Difficulty Ranked from table1
 where Ranked<=3;
 
 -- Q8
 SELECT Dev_ID, MIN(start_datetime) AS
 first_login_datetime
 FROM level_details2
 GROUP BY Dev_ID;
 
 -- Q9
  with table2 as
 (select Dev_ID, Score, Difficulty, rank() over (partition
 by Difficulty order by Score desc)
 as ranked from level_details2)
 select Dev_ID, Difficulty, Score, ranked from table2
 where Ranked<=5;
 
-- Q10
 SELECT P_ID, Dev_ID, MIN(start_datetime) AS
 min_start_datetime
 FROM level_details2
 GROUP BY Dev_ID, P_ID;
 
 -- Q11 (a)
 SELECT distinct P_ID, cast(start_datetime as date) as dated,
      SUM(Kill_Count) OVER (PARTITION BY P_ID, cast(start_datetime as date) 
      order by cast(start_datetime as date)) AS
 games_pl FROM level_details2 order by P_ID, dated;
 
 -- Q11 (b)
  SELECT P_ID, cast(start_datetime as date) as dated,
      SUM(Kill_Count) FROM level_details2 group by P_ID,
 cast(start_datetime as date) order by P_ID, dated;

-- Q12
 with cstages as (select P_ID, Stages_crossed,
 start_datetime, row_number() over (partition by P_ID order by start_datetime desc) as rn
 from level_details2)
 select P_ID, sum(Stages_crossed), start_datetime from cstages
 where rn>1 group by P_ID, start_datetime;
 
 -- Q13
 WITH RankedScores AS ( SELECT P_ID, Dev_ID,
 SUM(Score) AS Total_Score,
 ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER
 BY SUM(Score) DESC) AS ranked 
from level_details2 
GROUP BY  Dev_ID, P_ID)
 SELECT Dev_ID, P_ID, Total_Score
 from RankedScores
 WHERE ranked <= 3;
 
 -- Q14
 select P_ID, SUM(Score) from level_details2
 group by P_ID
 having
 sum(Score)>0.5*(select avg(Score) from
 level_details2);
 
 -- Q15
 DELIMITER //
 CREATE PROCEDURE MajorTopN(IN n INT)
 BEGIN 
SELECT Dev_ID, Headshots_Count, Difficulty
 FROM(
 SELECT
 Dev_ID,
 Headshots_Count,
 Difficulty,
 ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER
 BY Headshots_Count) AS ranked
 FROM
 level_details2) AS cstages
 WHERE ranked <= n;
 END //
 DELIMITER ;
 call MajorTopN(6)