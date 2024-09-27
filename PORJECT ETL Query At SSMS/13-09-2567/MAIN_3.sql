WITH Sales_facter AS (
    SELECT COUNT([so_number]) AS total_sales,
	SUM([revenue]) AS total_revenue,
	SUM([eng_cost]) AS total_eng_cost,
	SUM([internal]) AS total_internal,
	SUM([actual_cost]) AS total_actual_cost,
	SUM([external_jv]) AS total_external_jv,
	SUM([external]) AS total_external
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
CVM AS (
SELECT 
    COUNT(*) AS Total_Count,
    CASE 
        WHEN COUNT(*) < 4500 THEN 'Red'
        WHEN COUNT(*) >= 4500 THEN 'Green'
    END AS [status]
FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_CVM_BlockCustomer]
),
Revenue AS (
SELECT 
       SUM([revenue]) AS Total_Revenue,
	   SUM([actual_cost]) AS Total_Revenue_actual_cost,
	   SUM([margin]) AS Total_Revenue_margin,
	   CASE 
        WHEN  SUM([revenue]) < 97182500 THEN 'Red'
        WHEN  SUM([revenue]) >= 97182500 THEN 'Green '
    END AS [status]
  FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
TotalVMICTE AS (
    SELECT 
        SUM([vmi]) AS Total_VMI
    FROM 
        [Quotation].[dbo].[dm_VMIMonitor_Cutoff]
    WHERE 
        [data_type] = 'current week'
),
UniqueCustomerCountCTE AS (
    SELECT 
        COUNT(DISTINCT [customer_id]) AS UniqueCustomerCount
    FROM 
        [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Forecast]
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
check_in_status_count AS (
    SELECT COUNT(*) AS count_check_in_status
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_CLC]
    WHERE check_in_status = 'เข้าพบแล้ว'
),
cvm_id_count AS (
    SELECT COUNT(*) AS count_cvm_id 
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_CLC]
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


-----------------------------------------RoadMap------------------------------------------------------
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
 Total_Health_This_Year AS (
   SELECT 
        SUM([claimExpense]) AS TotalClaimExpense
    FROM [HR].[dbo].[dm_MedicalService_Detail]
    WHERE YEAR([createdAt]) = YEAR(GETDATE())
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
    FROM [HR].[dbo].[API_OT_OverTime]
    WHERE [start] >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
      AND [start] <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
      AND [status] <> 0
),
Set_row_number AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY [employee_name] ORDER BY [start] DESC) AS rn
    FROM [HR].[dbo].[API_OT_OverTime]
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
),

-----------------------------------------Fina--------------------------------------------------------

Cash_In AS (
   SELECT 
       [target]
      ,[percent_acc]
      ,[percent_predit]
  FROM [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_CashIn]
  WHERE [month] = DATEADD(MONTH, -2, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
),
Againg AS (

SELECT 
	CONVERT(NUMERIC(18, 2), 
	SUM(ISNULL([Overdue_1_30], 0) + 
	ISNULL([Overdue_30_60], 0)+ISNULL([Overdue_61_90], 0)+ISNULL([Overdue_91_180], 0))) AS Overdue_180 
FROM 
    [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_Aging]
),
total_Overdue_blance AS (
SELECT 
      CONVERT(NUMERIC(18, 2), SUM(ISNULL([overdue_balance], 0)))  AS total_Overdue_blance
     
  FROM  [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_Aging]
)


---------------------------------------------------------------------------------------------
----------------------------------------Sale&Marketing -----------------------------------------------------
SELECT 
    'Sale&Marketing-Salesfacter' AS [Source],
	'Sales_facter' AS Parameter,
    total_revenue / total_eng_cost AS [Value],
    CASE 
        WHEN total_revenue / total_eng_cost <= 0.85 THEN 'Red'
        WHEN total_revenue / total_eng_cost BETWEEN 0.85 AND 0.99 THEN 'Yellow'
        WHEN total_revenue / total_eng_cost >= 1 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Sales_facter

UNION ALL

SELECT 
    'Sale&Marketing-Salesfacter' AS [Source],
	'Internal' AS Parameter,
    total_internal / total_actual_cost AS [Value],
    CASE 
        WHEN total_internal / total_actual_cost <= 0.60 THEN 'Red'
        WHEN total_internal / total_actual_cost BETWEEN 0.60 AND 0.75 THEN 'Yellow'
        WHEN total_internal / total_actual_cost > 0.75 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Sales_facter 

UNION ALL

SELECT 
    'Sale&Marketing-Salesfacter' AS [Source],
	'External' AS Parameter,
    (total_external_jv + total_external) / total_actual_cost AS [Value],
    CASE 
        WHEN (total_external_jv + total_external) / total_actual_cost > 0.40 THEN 'Red'
        WHEN (total_external_jv + total_external) / total_actual_cost BETWEEN 0.25 AND 0.40 THEN 'Yellow'
        WHEN (total_external_jv + total_external) / total_actual_cost < 0.25 THEN 'Green'
    END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Sales_facter

UNION ALL

SELECT 
    'Sale&Marketing-Revenue' AS [Source],
	'Revenue' AS Parameter,
     Total_Revenue,
     [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Revenue

UNION ALL

SELECT 
    'Sale&Marketing-Revenue' AS [Source],
	'Actual_Cost' AS Parameter,
     Total_Revenue_actual_cost,
     NULL AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Revenue

UNION ALL

SELECT 
    'Sale&Marketing-Revenue' AS [Source],
	'Margin ' AS Parameter,
     Total_Revenue_margin,
     NULL AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM Revenue

UNION ALL

SELECT
'Sale&Marketing-ForCast' AS [Source],
'ForCast' AS Parameter,
VMI_Per_Customer , 
[status],
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM ForCast

UNION ALL

SELECT
'Sale&Marketing ' AS [Source],
'CLC' AS Parameter,
percentage_cvm_id , 
[status] ,
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM CLC

UNION ALL

SELECT 
'Sale&Marketing ' AS [Source],
'CVM' AS Parameter,
Total_Count  , 
[status] ,
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM CVM

-------------------------------------Operation----------------------------------------------------
UNION ALL 
SELECT 
	    CASE 
        WHEN UPPER(TRIM([catagories])) IN ('SLA','BACKUP') THEN 'Operation-Infrastructure-Availability'
	    WHEN UPPER(TRIM([catagories])) IN ('CAPACITY STRETCH CLUSTER','RESOURCE PLANNING','CAPACITY DC-DR CLUSTER') THEN 'Operation-Infrastructure-Performance'
		WHEN UPPER(TRIM([catagories])) IN ('MTTN','MTTR','CUSTOMER SATISFACTION') THEN 'Operation-Infrastructure-Compliance'
		WHEN UPPER(TRIM([catagories])) IN ('2FA','ANTIVIURS') THEN 'Operation-Infrastructure-Security'
		END AS [Source] ,
	    CASE 
        WHEN UPPER(TRIM([catagories])) IN ( 'CAPACITY DC-DR CLUSTER' ,'CAPACITY STRETCH CLUSTER' )
        THEN CONCAT(UPPER(TRIM([catagories])), ' ', UPPER(TRIM([detail])))
        ELSE UPPER(TRIM([catagories]))
        END AS [Parameter]

      ,CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) AS [health_score]
	  ,
    	CASE 
        WHEN UPPER(TRIM([catagories])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 95.95 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 99.5 AND 100  
		THEN 'Green'  
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'BACKUP' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 100 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'BACKUP' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) = 100
		THEN 'Green' 
			----------------------------
		WHEN UPPER(TRIM([catagories])) = 'RESOURCE PLANNING' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) <= 10000
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'RESOURCE PLANNING' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) > 10000
		THEN 'Green' 

		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'CPU' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 45 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'CPU' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 45
		THEN 'Green' 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'RAM' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 45 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'RAM' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 45
		THEN 'Green' 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'DISK' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 70 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'DISK' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 50
		THEN 'Green' 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY DC-DR CLUSTER' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 70 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY DC-DR CLUSTER' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) <= 50
		THEN 'Green'

		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'CPU' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 51 AND 69
        THEN 'Yellow'
        
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'MTTN' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 80
        THEN 'Red'
		WHEN UPPER(TRIM([catagories])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  BETWEEN 80 AND 94
		THEN 'Yellow' 
        WHEN UPPER(TRIM([catagories])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100
		THEN 'Green' 
		 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'MTTR' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 95
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'MTTR' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100
		THEN 'Green' 
			----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CUSTOMER SATISFACTION' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  BETWEEN 0 AND 79
        THEN 'Red'
		WHEN UPPER(TRIM([catagories])) = 'CUSTOMER SATISFACTION' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  BETWEEN 80 AND 94
		THEN 'Yellow' 
        WHEN UPPER(TRIM([catagories])) = 'CUSTOMER SATISFACTION' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100
		THEN 'Green'
				----------------------------
		WHEN UPPER(TRIM([catagories])) = '2FA' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  < 100
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = '2FA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 100
		THEN 'Green' 
					----------------------------
		WHEN UPPER(TRIM([catagories])) = 'ANTIVIURS' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  < 95
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'ANTIVIURS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) > 95
		THEN 'Green' 
	END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
  FROM [Parameter].[dbo].[API_HealthCheckParameter_Operation_Infrastructure]
  WHERE health_score IS NOT NULL

UNION ALL 
SELECT 
   CASE
	    WHEN UPPER(TRIM([parameter])) IN( 'SLA') THEN 'Operation-CII-Availability'
	    WHEN UPPER(TRIM([parameter])) IN( 'RESPONSE TIME','SUCCESS STATUS') THEN 'Operation-CII-Performance'
		WHEN UPPER(TRIM([parameter])) IN( 'MTTN','MTTR') THEN 'Operation-CII-Compliance'
		ELSE 'Operation-CII-Security'
   END AS [Source],
	UPPER(TRIM([parameter])) AS [parameter], 
    CASE 
        WHEN ISNUMERIC(REPLACE([health_score], '%', '')) = 1 
        THEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  -- แปลงเป็นทศนิยม 2 ตำแหน่ง
        ELSE NULL  -- หรือแสดงข้อความหรือค่าที่คุณต้องการแทน
    END AS [Health_Score],
	CASE 
        WHEN UPPER(TRIM([parameter])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 0 AND 99 
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 99 AND 99.9 
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 99.9 AND 100  
		THEN 'Green'  
		--------------------------
		WHEN UPPER(TRIM([parameter])) = 'RESPONSE TIME' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) > 5
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'RESPONSE TIME' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 1 AND 5
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'RESPONSE TIME' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 1 
		THEN 'Green'  
		-----------------------------------
		WHEN UPPER(TRIM([parameter])) = 'SUCCESS STATUS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 80
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'SUCCESS STATUS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 80 AND 94
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'SUCCESS STATUS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100 
		THEN 'Green'  
		----------------------------------
		WHEN UPPER(TRIM([parameter])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 80
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 80 AND 94
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100 
		THEN 'Green'  
		--------------------------------------
		WHEN UPPER(TRIM([parameter])) = 'MTTR' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 95
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'MTTR' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100 
		THEN 'Green'  
		---------------------------------------
	    WHEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 50
        THEN 'Red'
        WHEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 50 AND 79
        THEN 'Yellow'  
        WHEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 80 AND 100 
		THEN 'Green'  
	END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM [Parameter].[dbo].[API_HealthCheckParameter_Operation_Cii]

 
UNION ALL 
---------------------------------------RoadMap--------------------------------------------------
SELECT 
'Roadmap-Resource_capacity_planning' AS [Source],
'Resource_capacity_planning' AS Parameter,
[Total_People]  , 
    CASE 
        WHEN Total_People > 3050 THEN 'Red'
        WHEN Total_People BETWEEN 3001 AND 3050 THEN 'Yellow'
        WHEN Total_People < 3000 THEN 'Green'
    END AS [status],
CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM RCP
UNION ALL 
SELECT 
'Roadmap-HRM' AS [Source],
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
'Roadmap-HRM' AS [Source],
'จำนวนพนักงานเบิก OT ' AS Parameter,
     Total_People,
	 NULL [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    COUNT_People

UNION ALL 
SELECT 
'Roadmap-HRM' AS [Source],
'ค่าเฉลี่ย OT ' AS Parameter,
     NULL ,
	 NULL [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    COUNT_People

UNION ALL 
SELECT 
'Roadmap-HRM' AS [Source],
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
SELECT 
'Roadmap-HRM' AS [Source],
'จำนวนคนที่เบิก' AS Parameter,
    Total_Count ,
	NULL AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    COUNT_People_Health

UNION ALL 
SELECT 
'Roadmap-HRM' AS [Source],
'จำนวนเงิน' AS Parameter,
    TotalClaimExpense ,
	NULL AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM 
    Total_Health_This_Year

----------------------------------------------Financial&Costing----------------------------------------------------------------------
UNION ALL

SELECT
'Financial&Costing-Aging_Ar' AS [Source],
'Aging_Ar' AS Parameter,
Overdue_180 / total_Overdue_blance * 100 AS total_Overdue_blance,
    CASE 
        WHEN Overdue_180 / total_Overdue_blance * 100 >= 20 THEN 'Red'
        ELSE 'Green'
 END AS [Status],
 CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
GETDATE() AS update_at_etl
FROM Againg,total_Overdue_blance

UNION ALL
SELECT 
    'Financial&Costing-Cash_In' AS [Source],
	'Cash_In' AS Parameter,
	CAST(REPLACE([percent_acc], '%', '') AS decimal(18, 2)),
    CASE 
        WHEN [percent_acc] < 90 THEN 'Red'
        ELSE 'Green'
    END AS [Status], 
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM  Cash_In

UNION ALL
SELECT 
    'Financial&Costing-Cash_In' AS [Source],
	'Target' AS Parameter,
	[target],
    NULL AS [Status], 
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM  Cash_In

UNION ALL
SELECT 
    'Financial&Costing-Cash_In' AS [Source],
	'Action' AS Parameter,
	[percent_acc],
    NULL AS [Status], 
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM  Cash_In

UNION ALL
SELECT 
    'Financial&Costing-Cash_In' AS [Source],
	'Predict' AS Parameter,
	[percent_predit],
    NULL AS [Status], 
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM  Cash_In

UNION ALL 
SELECT 
   'Financial&Costing' AS [Source],
	UPPER(TRIM([detail])) AS [Detail], 
    CASE 
        WHEN ISNUMERIC(REPLACE([number], '%', '')) = 1 
        THEN CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2))  -- แปลงเป็นทศนิยม 2 ตำแหน่ง
        ELSE NULL  -- หรือแสดงข้อความหรือค่าที่คุณต้องการแทน
    END AS [Number_Decimal],
	CASE 
        WHEN UPPER(TRIM([detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 2.30 
        THEN 'Red'
        WHEN UPPER(TRIM([detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 2.00 AND 2.30 
        THEN 'Yellow'  
        WHEN UPPER(TRIM([detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 2.30 
        THEN 'Green'
		----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 4.30 
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 4.00 AND 4.30 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 4.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 30.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 30.00 AND 34.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 34.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'EBIT (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 20.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'EBIT (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 20.00 AND 22.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'EBIT (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 22.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'EBITDA (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 40.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'EBITDA (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 40.00 AND 48.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'EBITDA (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 48.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'EBT (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 6.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'EBT (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 6.00 AND 8.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'EBT (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 8.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'NP (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 7.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'NP (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 7.00 AND 11.00 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'NP (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 11.00
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'ICR (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 1.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'ICR (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 1.00 AND 1.20 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'ICR (เท่า)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 1.20
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'ROA (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 6.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'ROA (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 6.00 AND 7.10 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'ROA (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 7.10
        THEN 'Green'
		-----------------------------------------
		WHEN UPPER(TRIM([detail])) = 'ROE (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) < 8.00
        THEN 'Red'
		WHEN UPPER(TRIM([detail])) = 'ROE (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) BETWEEN 8.00 AND 9.20 
        THEN 'Yellow'
		WHEN UPPER(TRIM([detail])) = 'ROE (%)' AND CAST(REPLACE([number], '%', '') AS DECIMAL(18, 2)) > 9.20
        THEN 'Green'
    END AS [Status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_FinanceRatio]


