WITH [Sale_facter] AS (
SELECT 
    [So_Number],
    [PeriodStartDate],
    [PeriodEndDate],
    [PerioAmount_CutCN],
    [ActualCost],
    [EngCost],
	SUM([Cost_Unit]) AS Cost_Unit,
    SUM([Internal]) AS TotalInternal,
    SUM([ExternalJV]) AS TotalExternalJV,
    SUM([External]) AS TotalExternal,
    ROW_NUMBER() OVER (PARTITION BY [So_Number] ORDER BY [So_Number]) AS rn,
    COUNT([So_Number]) OVER (PARTITION BY [So_Number]) AS SoCount
FROM [SO].[dbo].[API_CS_AI_VMI]
WHERE MONTH([PeriodStartDate]) = 8 
  AND YEAR([PeriodStartDate]) = YEAR(GETDATE()) 
  AND [So_Number] IS NOT NULL
  AND [PeriodStartDate] IS NOT NULL
  AND [PeriodEndDate] IS NOT NULL
  AND [PerioAmount_CutCN] IS NOT NULL
  AND [ActualCost] IS NOT NULL
  AND [Cost_Unit] IS NOT NULL
  AND [EngCost] IS NOT NULL
  AND [Internal] IS NOT NULL
  AND [ExternalJV] IS NOT NULL
  AND [External] IS NOT NULL
GROUP BY 
    [So_Number],
    [PeriodStartDate],
    [PeriodEndDate],
    [PerioAmount_CutCN],
    [ActualCost],
    [EngCost]
),
Cal_Eng AS (
SELECT 
SUM([EngCost]) AS Total_EngCost, 
SUM([PerioAmount_CutCN]) AS Total_Revenue
FROM [Sale_facter]
)
SELECT  
    Total_Revenue / Total_EngCost AS Sale_Facter,
    CASE 
        WHEN Total_Revenue / Total_EngCost <= 0.85 THEN 'Red'
        WHEN Total_Revenue / Total_EngCost BETWEEN 0.85 AND 0.99 THEN 'Yellow'
        WHEN Total_Revenue / Total_EngCost > 1 THEN 'Green'
    END AS status_color
FROM Cal_Eng;
