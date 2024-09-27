WITH Sales_facter AS (
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
----------------------------------------------------------------------------------------
Cal_Actual_Internal AS (
   SELECT 
       SUM([ActualCost]) AS Total_Actual_Cost,
       SUM([TotalInternal]) AS Total_Internal
   FROM Sales_facter
),
----------------------------------------------------------------------------------------
Cal_Actual_External AS (
   SELECT 
       SUM([ActualCost]) AS Total_Actual_Cost,
       SUM([TotalExternalJV]) AS Total_ExternalJV,
       SUM([TotalExternal]) AS Total_External
   FROM Sales_facter
),
----------------------------------------------------------------------------------------
Cal_Eng AS (
SELECT 
SUM([EngCost]) AS Total_EngCost, 
SUM([PerioAmount_CutCN]) AS Total_Revenue
FROM Sales_facter
),
---------------------------------------------------------------------------------------------------
Revenue AS (
SELECT 
       SUM([Revenue]) AS Total_Revenue,
	   CASE 
        WHEN  SUM([Revenue]) < 97182500 THEN 'Red'
        WHEN  SUM([Revenue]) >= 97182500 THEN 'Green '
    END AS [status]
  FROM [SO].[dbo].[API_Revenue]

),
----------------------------------------------------------------------------------------
CVM AS (
SELECT 
    COUNT(*) AS Total_Count,
    CASE 
        WHEN COUNT(*) < 4500 THEN 'Red'
        WHEN COUNT(*) >= 4500 THEN 'Green'
    END AS [status]
FROM [SO].[dbo].[API_Block_Customer]
),
----------------------------------------------------------------------------------------
check_in_status_count AS (
    SELECT COUNT(*) AS count_check_in_status
    FROM [SO].[dbo].[API_visit_clc_aug]
    WHERE check_in_status = 'เข้าพบแล้ว'
),
cvm_id_count AS (
    SELECT COUNT(*) AS count_cvm_id 
    FROM [SO].[dbo].[API_visit_clc_aug]
    WHERE check_in_status = 'เข้าพบแล้ว' AND cvm_id <> '[]'
),
CLC AS (
SELECT 
    c.count_cvm_id,
    s.count_check_in_status,
    (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 AS percentage_cvm_id,
    CASE 
        WHEN (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 < 80 THEN 'Red'
        WHEN (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 BETWEEN 80 AND 89 THEN 'Yellow'
        WHEN (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 >= 90 THEN 'Green'
    END AS [status]
FROM cvm_id_count c, check_in_status_count s
),
----------------------------------------------------------------------------------------
TotalVMICTE AS (
    SELECT 
        SUM([vmi]) AS Total_VMI
    FROM 
        [SO].[dbo].[dm_VMIMonitor_Cutoff]
    WHERE 
        [data_type] = 'current week'
),
UniqueCustomerCountCTE AS (
    SELECT 
        COUNT(DISTINCT [Customer_ID]) AS UniqueCustomerCount
    FROM 
        [SO].[dbo].[API_Sales_Forcast]
),
ForCast AS (
SELECT 
    TotalVMICTE.Total_VMI,
    UniqueCustomerCountCTE.UniqueCustomerCount,
    CASE 
        WHEN UniqueCustomerCountCTE.UniqueCustomerCount = 0 THEN NULL  -- Avoid division by zero
        ELSE TotalVMICTE.Total_VMI / UniqueCustomerCountCTE.UniqueCustomerCount
    END AS VMI_Per_Customer,
    CASE 
        WHEN TotalVMICTE.Total_VMI / UniqueCustomerCountCTE.UniqueCustomerCount < 5 THEN 'Red'
        WHEN TotalVMICTE.Total_VMI / UniqueCustomerCountCTE.UniqueCustomerCount BETWEEN 5 AND 10 THEN 'Yellow'
        ELSE 'Green'
    END AS [status]
FROM 
    TotalVMICTE, 
    UniqueCustomerCountCTE

),
----------------------------------------------------------------------------------------
-----------------------------------Financial&Costing------------------------------------
Cash_In AS (
-- Calculate the date two months prior to the current month
SELECT 
    [percent],
	'Cash_In' AS Source,
    CASE 
        WHEN LEN(REPLACE([percent], '%', '')) > 0 AND ISNUMERIC(REPLACE([percent], '%', '')) = 1 AND CAST(REPLACE([percent], '%', '') AS FLOAT) > 90 THEN 'Green'
        ELSE 'Red'
    END AS [status]
FROM 
    [SO].[dbo].[API_Cash_In]
WHERE 
    [Month] = DATEADD(MONTH, -2, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
),
Againg  AS (

SELECT 
	CONVERT(NUMERIC(18, 2), SUM(ISNULL([Overdue_181-360], 0) + ISNULL([Overdue_360], 0))) AS Overdue_180 
FROM 
    [SO].[dbo].[API_Customer_Aging]
),
total_Overdue_blance AS (
SELECT 
      CONVERT(NUMERIC(18, 2), SUM(ISNULL([Overdue_Balance], 0)))  AS total_Overdue_blance
     
  FROM [SO].[dbo].[API_Customer_Aging]
),




-----------------------------------Roadmap------------------------------------------------------
RCP AS (
 SELECT
      COUNT(DISTINCT employeeId_All) AS Total_People
  FROM [HR].[dbo].[dm_EmployeeRatio] WHERE sec_dep_line IS NOT NULL

),
Total_Health AS (
    SELECT 
        SUM([claimExpense]) AS TotalClaimExpense
    FROM [HR].[dbo].[dm_MedicalService_Detail]
    WHERE [createdAt] >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
      AND [createdAt] < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
      AND [status] NOT IN (3,6)
),
CTE_RemoveDuplicates AS (
    SELECT 
        [accountId],
        ROW_NUMBER() OVER (PARTITION BY [accountId] ORDER BY [createdAt] DESC) AS rn  
    FROM [HR].[dbo].[dm_MedicalService_Detail]
    WHERE [createdAt] >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
      AND [createdAt] < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
      AND [status] NOT IN (3,6)
),
COUNT_People_Health AS (
    SELECT COUNT(*) AS Total_Count
    FROM CTE_RemoveDuplicates
    WHERE rn = 1 
),
CTE_RemoveDuplicates_OT AS (
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
    FROM CTE_RemoveDuplicates_OT
)
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Query to combine results
SELECT 
    'Sale&Marketing ' AS [Source],
	'Internal' AS Parameter,
    Total_Internal / Total_Actual_Cost AS [Value],
    CASE 
        WHEN Total_Internal / Total_Actual_Cost <= 0.60 THEN 'Red'
        WHEN Total_Internal / Total_Actual_Cost BETWEEN 0.60 AND 0.75 THEN 'Yellow'
        WHEN Total_Internal / Total_Actual_Cost > 0.75 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Cal_Actual_Internal
-----------------------------------------------------------------------------------------
UNION ALL

SELECT 
    'Sale&Marketing ' AS [Source],
	'External' AS Parameter,
    (Total_ExternalJV + Total_External) / Total_Actual_Cost AS [Value],
    CASE 
        WHEN (Total_ExternalJV + Total_External) / Total_Actual_Cost >= 0.40 THEN 'Red'
        WHEN (Total_ExternalJV + Total_External) / Total_Actual_Cost BETWEEN 0.25 AND 0.40 THEN 'Yellow'
        WHEN (Total_ExternalJV + Total_External) / Total_Actual_Cost <= 0.25 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Cal_Actual_External
-----------------------------------------------------------------------------------------
UNION ALL

SELECT  
        'Sale&Marketing ' AS [Source],
	    'Sale_facter' AS Parameter,
    Total_Revenue / Total_EngCost AS Sale_Facter,
    CASE 
        WHEN Total_Revenue / Total_EngCost <= 0.85 THEN 'Red'
        WHEN Total_Revenue / Total_EngCost BETWEEN 0.85 AND 0.99 THEN 'Yellow'
        WHEN Total_Revenue / Total_EngCost > 1 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Cal_Eng
-----------------------------------------------------------------------------------------
UNION ALL

SELECT 
'Sale&Marketing ' AS [Source],
'Revenue' AS Parameter,
Total_Revenue  , 
[status],
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM Revenue
-----------------------------------------------------------------------------------------
UNION ALL

SELECT 
'Sale&Marketing ' AS [Source],
'CVM' AS Parameter,
Total_Count  , 
[status] ,
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM CVM
-----------------------------------------------------------------------------------------
UNION ALL

SELECT
'Sale&Marketing ' AS [Source],
'CLC' AS Parameter,
percentage_cvm_id , 
[status] ,
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM CLC
-----------------------------------------------------------------------------------------

UNION ALL

SELECT
'Sale&Marketing ' AS [Source],
'ForCast' AS Parameter,
VMI_Per_Customer , 
[status],
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM ForCast
-----------------------------------------------------------------------------------------
UNION ALL

SELECT
'Financial&Costing' AS [Source],
'Aging_Ar' AS Parameter,
Overdue_180 / total_Overdue_blance * 100 AS total_Overdue_blance,
    CASE 
        WHEN Overdue_180 / total_Overdue_blance * 100 >= 20 THEN 'Red'
        ELSE 'Green'
 END AS [Status],
 CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM againg,total_Overdue_blance

UNION ALL
SELECT 
    'Financial&Costing' AS [Source],
	'Cash_In' AS Parameter,
	CAST(REPLACE([percent], '%', '') AS decimal(18, 2)),
    CASE 
        WHEN CAST(REPLACE([percent], '%', '') AS decimal(18, 2)) < 90 THEN 'Red'
        ELSE 'Green'
    END AS [Status], 
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    [SO].[dbo].[API_Cash_In]
WHERE 
    [Month] = DATEADD(MONTH, -2, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
UNION ALL 
SELECT 
   'Financial&Costing' AS [Source],
	UPPER(TRIM([Detail])) AS [Detail], 
    CASE 
        WHEN ISNUMERIC(REPLACE([Number], '%', '')) = 1 
        THEN CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2))  -- แปลงเป็นทศนิยม 2 ตำแหน่ง
        ELSE NULL  -- หรือแสดงข้อความหรือค่าที่คุณต้องการแทน
    END AS [Number_Decimal],
	CASE 
        WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 2.30 
        THEN 'Red'
        WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 2.00 AND 2.30 
        THEN 'Yellow'  
        WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 2.30 
        THEN 'Green'
		----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 4.30 
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 4.00 AND 4.30 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 4.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 30.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 30.00 AND 34.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 34.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'EBIT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 20.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'EBIT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 20.00 AND 22.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'EBIT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 22.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'EBITDA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 40.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'EBITDA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 40.00 AND 48.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'EBITDA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 48.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'EBT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 6.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'EBT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 6.00 AND 8.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'EBT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 8.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'NP (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 7.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'NP (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 7.00 AND 11.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'NP (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 11.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'ICR (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 1.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'ICR (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 1.00 AND 1.20 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'ICR (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 1.20
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'ROA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 6.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'ROA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 6.00 AND 7.10 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'ROA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 7.10
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'ROE (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 8.00
        THEN 'Red'
		WHEN UPPER(TRIM([Detail])) = 'ROE (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 8.00 AND 9.20 
        THEN 'Yellow'
		WHEN UPPER(TRIM([Detail])) = 'ROE (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 9.20
        THEN 'Green'
    END AS [Status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM [SO].[dbo].[API_finance_ratio]


-----------------------------------------------------------------------------------------
UNION ALL



SELECT 
'Roadmap' AS [Source],
'Resource_capacity_planning' AS Parameter,
[Total_People]  , 
    CASE 
        WHEN [total_people] > 3050 THEN 'Red'
        WHEN [total_people] BETWEEN 3001 AND 3050 THEN 'Yellow'
        WHEN [total_people] < 3000 THEN 'Green'
    END AS [status],
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM RCP

UNION ALL 
SELECT 
'Roadmap' AS [Source],
'OT' AS Parameter,
    (TotalRate1 + TotalRate1_5+TotalRate3) / Total_People ,
	 CASE 
        WHEN (TotalRate1 + TotalRate1_5+TotalRate3) / Total_People > 41 THEN 'Red'
		WHEN (TotalRate1 + TotalRate1_5+TotalRate3) / Total_People BETWEEN 31 AND 40 THEN 'Yellow'
        WHEN (TotalRate1 + TotalRate1_5+TotalRate3) / Total_People <= 30 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    Total_rate,COUNT_People
UNION ALL 
SELECT 
'Roadmap' AS [Source],
'ค่ารักษาพยาบาล' AS Parameter,
    Total_Health.TotalClaimExpense / COUNT_People_Health.Total_Count AS AverageClaimExpense,
	 CASE 
        WHEN  Total_Health.TotalClaimExpense / COUNT_People_Health.Total_Count > 7001 THEN 'Red'
		WHEN  Total_Health.TotalClaimExpense / COUNT_People_Health.Total_Count BETWEEN 5001 AND 7000 THEN 'Yellow'
        WHEN  Total_Health.TotalClaimExpense / COUNT_People_Health.Total_Count <= 5000 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    Total_Health, COUNT_People_Health
UNION ALL 
-----------------------------------------------------------------------------------------


SELECT 
    'Operation' AS [Source],
    [Network Layer] AS Parameter,
    [Healthscore_percent],
    CASE
        WHEN [Healthscore_percent] >= 50 THEN 'Green'
        WHEN [Healthscore_percent] BETWEEN 30 AND 49 THEN 'Yellow'
        WHEN [Healthscore_percent] BETWEEN 0 AND 29 THEN 'Red'
        ELSE 'Unknown'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM [SO].[dbo].[API_Operation_Network] WHERE [Network Layer] <> 'Grand Total'
-----------------------------------------------------------------------------------------
UNION ALL 
SELECT
      'Operation' AS [Source],
      [Platform],
      [Healthscore_percent],
      CASE
        WHEN [Healthscore_percent] >= 50 THEN 'Green'
        WHEN [Healthscore_percent] BETWEEN 30 AND 49 THEN 'Yellow'
        WHEN [Healthscore_percent] BETWEEN 0 AND 29 THEN 'Red'
        ELSE NULL
    END AS [Status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
  FROM [SO].[dbo].[API_Operation_Cloud] WHERE [Platform] <> 'Grand Total'


