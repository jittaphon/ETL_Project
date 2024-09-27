WITH [Internal_facter] AS (
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
Cal_Actual_Internal AS (
SELECT 
SUM([ActualCost]) AS Total_Actual_Cost ,
SUM([TotalInternal]) AS Total_Internal
FROM [Internal_facter]
)
SELECT 
Total_Actual_Cost , 
Total_Internal ,
Total_Internal / Total_Actual_Cost AS [Internal],
 CASE 
        WHEN Total_Internal / Total_Actual_Cost <= 0.60 THEN 'Red'
        WHEN Total_Internal / Total_Actual_Cost BETWEEN 0.60 AND 0.75 THEN 'Yellow'
        WHEN Total_Internal / Total_Actual_Cost > 0.75 THEN 'Green'
    END AS status_color
FROM Cal_Actual_Internal