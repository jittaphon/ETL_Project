WITH [Enternal_facter] AS (
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
SUM([ActualCost]) AS TotalActualCost,
SUM(TotalExternalJV) AS TotalExternalJV ,
SUM(TotalExternal) AS TotalExternal
FROM [Enternal_facter]
)
SELECT 

(TotalExternalJV + TotalExternal) / TotalActualCost AS [External],
 CASE 
        WHEN (TotalExternalJV + TotalExternal) / TotalActualCost >= 0.40 THEN 'Red'
        WHEN (TotalExternalJV + TotalExternal) / TotalActualCost BETWEEN 0.25 AND 0.40 THEN 'Yellow'
        WHEN (TotalExternalJV + TotalExternal) / TotalActualCost <= 0.25 THEN 'Green'
    END AS status_color
FROM Cal_Actual_Internal