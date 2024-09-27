WITH TotalVMICTE AS (
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
)
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
    END AS Status
FROM 
    TotalVMICTE, 
    UniqueCustomerCountCTE;
