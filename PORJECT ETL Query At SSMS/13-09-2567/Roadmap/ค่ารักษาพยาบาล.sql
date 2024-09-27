WITH Total_Health AS (
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
)
SELECT 
    Total_Health.TotalClaimExpense / COUNT_People_Health.Total_Count AS AverageClaimExpense
FROM 
    Total_Health, COUNT_People_Health;
