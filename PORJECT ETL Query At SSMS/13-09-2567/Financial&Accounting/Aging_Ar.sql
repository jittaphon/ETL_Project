WITH againg  AS (

SELECT 
	CONVERT(NUMERIC(18, 2), SUM(ISNULL([Overdue_181-360], 0) + ISNULL([Overdue_360], 0))) AS Overdue_180 
FROM 
    [SO].[dbo].[API_Customer_Aging]
),
total_Overdue_blance AS (
SELECT 
      CONVERT(NUMERIC(18, 2), SUM(ISNULL([Overdue_Balance], 0)))  AS total_Overdue_blance
     
  FROM [SO].[dbo].[API_Customer_Aging]
)
SELECT
Overdue_180 / total_Overdue_blance * 100 AS total_Overdue_blance,
    CASE 
        WHEN Overdue_180 / total_Overdue_blance * 100 > 20 THEN 'Red'
        ELSE 'Green'
 END AS [Status]
FROM againg,total_Overdue_blance