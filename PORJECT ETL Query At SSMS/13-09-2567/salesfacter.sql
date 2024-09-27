WITH factor AS (

SELECT CONVERT(NVARCHAR(10), period_month) AS period_month,
	CONVERT(NUMERIC(18, 2), SUM(period_amount)/SUM(eng_cost)) AS sale_factor,
	CONVERT(NUMERIC(18, 2), SUM(internal)/SUM(actual_cost)) AS internal_factor,
	CONVERT(NUMERIC(18, 2), SUM(ISNULL(external_jv, 0) + ISNULL([external], 0))/SUM(ISNULL(actual_cost, 0))) AS external_factor,
	N'Sale&Marketing' AS parameter
FROM (SELECT DISTINCT
	So_Number AS so_number,
	FORMAT(PeriodStartDate, 'yyyy-MM') AS period_month,
	PerioAmount_CutCN AS period_amount,
	EngCost AS eng_cost,
	ActualCost AS actual_cost,
	SUM(Cost_Unit) OVER(PARTITION BY So_Number) AS cost_unit,
	SUM(Internal) OVER(PARTITION BY So_Number) AS internal,
	SUM(ExternalJV) OVER(PARTITION BY So_Number) AS external_jv,
	SUM([External]) OVER(PARTITION BY So_Number) AS [external]
FROM [SO].[dbo].[dm_CS_AI_VMI]
/* current month - 1 */
WHERE FORMAT(PeriodStartDate, 'yyyy-MM') = FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')
	) f
GROUP BY period_month

), revenue AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	CONVERT(NUMERIC(18, 2), SUM([Revenue])) AS revenue,
	N'Sale&Marketing - Revenue' AS parameter,
	N'Revenue' AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]

), forecast AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	CONVERT(NUMERIC(18, 2), SUM(vmi)/(SELECT COUNT(customer_id)
				FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Forecast])) 
	AS vmi_sales_week,
	CONVERT(NUMERIC(18, 2), (SUM(vmi)/(SELECT COUNT(customer_id)
				FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Forecast]))*2500) 
	AS vmi_selling_price,
	N'Sale&Marketing - Forecast' AS parameter,
	N'Forecast' AS data_type
	/* (SELECT COUNT(customer_id) AS cnt_sales FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Forecast]) AS cnt_sales */
FROM [Quotation].[dbo].[dm_VMIMonitor_Cutoff]
WHERE data_type = 'current week'
AND year_start_date = YEAR(GETDATE())
AND quarter_start_date = DATEPART(QUARTER, GETDATE())
AND block_customer IS NOT NULL

), cvm AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	COUNT(DISTINCT customer_name) AS total_customer,
	N'Sale&Marketing - CVM' AS parameter,
	N'CVM' AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_CVM_BlockCustomer]

), clc AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	SUM(IIF(check_in_status = N'เข้าพบแล้ว', 1, 0)) AS cnt_status,
	SUM(IIF(check_in_status = N'เข้าพบแล้ว' AND cvm_id <> '[]', 1, 0)) AS cnt_cvm,
	CONVERT(NUMERIC(18, 2), SUM(IIF(check_in_status = N'เข้าพบแล้ว' AND cvm_id <> '[]', 1, 0))*100/SUM(IIF(check_in_status = N'เข้าพบแล้ว', 1, 0))) AS [percent],
	N'Sale&Marketing - CLC' AS parameter,
	N'CLC' AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_CLC]

), cash_in AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	CONVERT(NUMERIC(18, 2), [percent]) AS [percent],
	N'Financial&Accounting - Cash In' AS parameter,
	N'Cash In' AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_CashIn]
/* current month - 2 */
WHERE FORMAT([month], 'yyyy-MM') = FORMAT(DATEADD(MONTH, -2, GETDATE()), 'yyyy-MM')

), aging_ar AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	CONVERT(NUMERIC(18, 2), SUM(ISNULL([Overdue_181_360], 0) + ISNULL([Overdue_360], 0))) AS aging,
	N'Financial&Accounting - Aging / AR' AS parameter,
	N'Aging / AR' AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_Aging]

), finance_ratio AS (

SELECT CONVERT(NVARCHAR(10), '2024-08') AS period_month,
	[detail],
	[number],
	N'Financial&Accounting - Finance ratio' AS parameter,
	N'Finance ratio' AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_FinancialAccounting_FinanceRatio]

), resource_capacity AS (

SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	CONVERT(NUMERIC(18, 2), SUM(total_people)) AS total_people,
	N'Roadmap' AS parameter,
	N'Resource capacity planning' AS data_type
FROM [HR].[dbo].[API_EmployeePlan_ActualManPower_INET]
WHERE FORMAT([date], 'yyyy-MM') = FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')

), overtime AS (

SELECT CONVERT(NVARCHAR(10), FORMAT([start], 'yyyy-MM')) AS period_month,
		SUM(ISNULL([rate1], 0) + ISNULL([rate1_5], 0) + ISNULL([rate3], 0)) AS sum_ot,
		COUNT(DISTINCT employee_name) AS total_people,
		CONVERT(NUMERIC(18, 2), SUM(ISNULL([rate1], 0) + ISNULL([rate1_5], 0) + ISNULL([rate3], 0))/
				COUNT(DISTINCT employee_name)) AS [average],
		N'Roadmap - HRM' AS parameter,
		N'OT' AS data_type
FROM [HR].[dbo].[API_OT_OverTime]
WHERE FORMAT([start], 'yyyy-MM') = FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')
AND [status] <> 0
GROUP BY FORMAT([start], 'yyyy-MM')

), claim_expense AS (

/* logic dashboard */
SELECT 
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	SUM(claimExpense) AS claim_expense,
	COUNT(DISTINCT accountId) AS total_employee_claim,
	CONVERT(NUMERIC(18, 2), SUM(claimExpense)/COUNT(DISTINCT accountId)) AS [average],
	N'Roadmap - HRM' AS parameter,
	N'ค่ารักษาพยาบาล' AS data_type
FROM [HR].[dbo].[dm_MedicalService_Detail]
WHERE FORMAT(createdAt, 'yyyy-MM') = FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')
AND [status] NOT IN (3, 6)

), network AS (

SELECT [healthscore_percent],
	(CASE
		WHEN [healthscore_percent] >= 50 THEN 'Green'
		WHEN [healthscore_percent] < 30 THEN 'Red'
		ELSE 'Yellow' END) AS color,
	N'Operation - Network' AS parameter,
	[network_layer] AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_Operation_Network]
WHERE [network_layer] <> 'Grand Total'

), claster AS (

SELECT [healthscore_percent],
	(CASE
		WHEN [healthscore_percent] >= 50 THEN 'Green'
		WHEN [healthscore_percent] < 30 THEN 'Red'
		WHEN [healthscore_percent] IS NOT NULL THEN 'Yellow'
		ELSE NULL END) AS color,
	N'Operation - Claster' AS parameter,
	[platform] AS data_type
FROM [Parameter].[dbo].[API_HealthCheckParameter_Operation_Cloud]
WHERE [platform] <> 'Grand Total'

)

/* Sale&Marketing */
SELECT period_month, sale_factor AS [value]
, (CASE 
	WHEN sale_factor >= 1 THEN 'Green'
	WHEN sale_factor < 0.85 THEN 'Red'
	ELSE 'Yellow'
	END) AS color
, CONCAT(parameter, ' - Sale factor') AS parameter, 'Sale factor' AS data_type, GETDATE() AS updated_at_etl 
FROM factor

UNION ALL
SELECT period_month, internal_factor AS [value]
, (CASE 
	WHEN internal_factor >= 0.75 THEN 'Green'
	WHEN internal_factor < 0.60 THEN 'Red'
	ELSE 'Yellow'
	END) AS color
, CONCAT(parameter, ' - Internal') AS parameter, 'Internal' AS data_type, GETDATE() AS updated_at_etl 
FROM factor

UNION ALL
SELECT period_month, external_factor AS [value]
, (CASE 
	WHEN external_factor < 0.25 THEN 'Green'
	WHEN external_factor > 0.40 THEN 'Red'
	ELSE 'Yellow'
	END) AS color
, CONCAT(parameter, ' - External') AS parameter, 'External' AS data_type, GETDATE() AS updated_at_etl 
FROM factor

UNION ALL
SELECT period_month, revenue AS [value]
, IIF(revenue >= 97182500, 'Green', 'Red') AS color
, parameter, data_type, GETDATE() AS updated_at_etl 
FROM revenue

UNION ALL
SELECT period_month, vmi_sales_week AS [value]
, (CASE 
	WHEN vmi_sales_week > 10 THEN 'Green'
	WHEN vmi_sales_week < 5 THEN 'Red'
	ELSE 'Yellow'
	END) AS color
, parameter, 'VMI' AS data_type, GETDATE() AS updated_at_etl 
FROM forecast

UNION ALL
SELECT period_month, vmi_selling_price AS [value]
, (CASE 
	WHEN vmi_sales_week > 10 THEN 'Green'
	WHEN vmi_sales_week < 5 THEN 'Red'
	ELSE 'Yellow'
	END) AS color /* ref vmi */
, parameter, 'VMI Selling price' AS data_type, GETDATE() AS updated_at_etl 
FROM forecast

UNION ALL
SELECT period_month, total_customer AS [value]
, IIF(total_customer >= 4500, 'Green', 'Red') AS color
, parameter, data_type, GETDATE() AS updated_at_etl 
FROM cvm

UNION ALL
SELECT period_month, [percent] AS [value]
, (CASE 
	WHEN [percent] >= 90 THEN 'Green'
	WHEN [percent] < 80 THEN 'Red'
	ELSE 'Yellow'
	END) AS color
, parameter, data_type, GETDATE() AS updated_at_etl FROM clc

/* Financial&Accounting */
UNION ALL
SELECT period_month, [percent] AS [value]
, IIF([percent] >= 90, 'Green', 'Red') AS color
, parameter, data_type, GETDATE() AS updated_at_etl FROM cash_in

UNION ALL
SELECT period_month, ISNULL(aging, 0) AS [value]
, IIF(ISNULL(aging, 0) = 0, 'Green', 'Red') AS color
, parameter, data_type, GETDATE() AS updated_at_etl FROM aging_ar

UNION ALL
SELECT period_month, [number] AS [value]
, (CASE 
		WHEN [detail] LIKE 'IBD/E ratio Non Reit%'
			THEN (CASE 
				WHEN [number] < 4.0 THEN 'Green'
				WHEN [number] > 4.3 THEN 'Red'
				ELSE 'Yellow' END)
        WHEN [detail] LIKE 'IBD/E ratio%' 
			THEN (CASE 
				WHEN [number] < 2.0 THEN 'Green'
                WHEN [number] > 2.3 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] = 'Gross Profit Margin (%)' 
			THEN (CASE 
                WHEN [number] > 34 THEN 'Green'
                WHEN [number] < 30 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] = 'EBIT (%)' 
			THEN (CASE 
                WHEN [number] > 22 THEN 'Green'
                WHEN [number] < 20 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] = 'EBITDA (%)' 
			THEN (CASE 
                WHEN [number] > 48 THEN 'Green'
                WHEN [number] < 40 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] = 'EBT (%)' 
			THEN (CASE 
                WHEN [number] > 8 THEN 'Green'
                WHEN [number] < 6 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] = 'NP (%)' 
			THEN (CASE 
                WHEN [number] > 11 THEN 'Green'
                WHEN [number] < 7 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] LIKE 'ICR%'  
			THEN (CASE 
                WHEN [number] > 1.20 THEN 'Green'
                WHEN [number] < 1 THEN 'Red'
				ELSE 'Yellow' END)
        WHEN [detail] = 'ROA (%)' 
			THEN (CASE 
                WHEN [number] > 7.10 THEN 'Green'
                WHEN [number] < 6.00 THEN 'Red'
                ELSE 'Yellow' END)
        WHEN [detail] = 'ROE (%)' 
			THEN (CASE 
                WHEN [number] > 9.2 THEN 'Green'
                WHEN [number] < 8 THEN 'Red'
                ELSE 'Yellow' END)
        ELSE NULL
    END) AS color
, parameter, detail, GETDATE() AS updated_at_etl FROM finance_ratio

/* Roadmap */
UNION ALL
SELECT period_month, total_people AS [value]
, (CASE 
	WHEN total_people > 3050 THEN 'Green'
	WHEN total_people < 3000 THEN 'Red'
	ELSE 'Yellow'
	END) AS color
, parameter, data_type, GETDATE() AS updated_at_etl FROM resource_capacity

UNION ALL
SELECT period_month, [average] AS [value]
, (CASE
	WHEN [average] >= 41 THEN 'Red'
	WHEN [average] <= 30 THEN 'Green'
	ELSE 'Yellow' END) AS color
, parameter, data_type, GETDATE() AS updated_at_etl FROM overtime

UNION ALL
SELECT period_month, [average] AS [value]
, (CASE
	WHEN [average] >= 7001 THEN 'Red'
	WHEN [average] <= 5000 THEN 'Green'
	ELSE 'Yellow' END) AS color
, parameter, data_type, GETDATE() AS updated_at_etl FROM claim_expense

/* operation */
UNION ALL
SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	healthscore_percent AS [value],
	color, parameter, data_type, GETDATE() AS updated_at_etl FROM network

UNION ALL
SELECT CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	healthscore_percent AS [value],
	color, parameter, data_type, GETDATE() AS updated_at_etl FROM claster