WITH CTE_RemoveDuplicates AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY [employee_name] ORDER BY [start] DESC) AS rn
    FROM [OT].[dbo].[API_OT_OverTime]
    WHERE [start] >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
      AND [start] <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
      AND [status] <> 0
),
Set_row_number AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY [employee_name] ORDER BY [start] DESC) AS rn
    FROM [OT].[dbo].[API_OT_OverTime]
    WHERE [start] >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
      AND [start] <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
      AND [status] <> 0
),
COUNT_People AS (
    SELECT COUNT(*) AS Total_People 
    FROM Set_row_number 
    WHERE rn = 1
),
Total_rate AS (
    SELECT 
        SUM(rate1) AS TotalRate1, 
        SUM(rate1_5) AS TotalRate1_5, 
        SUM(rate3) AS TotalRate3 
    FROM CTE_RemoveDuplicates
)
SELECT 
      NULL AS Total_Amount,
     Total_People,
    (TotalRate1 + TotalRate1_5+TotalRate3) / Total_People AS [AVG]
FROM 
    Total_rate,COUNT_People
