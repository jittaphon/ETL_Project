SELECT 
       SUM([Revenue]),
	   CASE 
        WHEN  SUM([Revenue]) < 97182500 THEN 'Red'
        WHEN  SUM([Revenue]) >=97182500 THEN 'Green'
    END AS status_color
  FROM [SO].[dbo].[API_Revenue]
