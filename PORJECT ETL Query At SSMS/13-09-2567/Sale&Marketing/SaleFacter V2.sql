WITH Sales_facter AS (
    SELECT COUNT([so_number]) AS total_sales
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
Total_revenue AS (
    SELECT SUM([revenue]) AS total_revenue
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
Total_Eng_Cost AS (
    SELECT SUM([eng_cost]) AS total_eng_cost
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
Total_Internal AS (
    SELECT SUM([internal]) AS total_internal
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
Total_actual_cost AS (
    SELECT SUM([actual_cost]) AS total_actual_cost
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
),
Total_External As (
    SELECT SUM([external_jv]) AS total_external_jv,
	       SUM([external]) AS total_external
    FROM [Parameter].[dbo].[API_HealthCheckParameter_SaleFactor_Revenue]
)



SELECT 
total_revenue / total_eng_cost AS Sale_facter

FROM Total_Eng_Cost,Total_revenue,Sales_facter;
