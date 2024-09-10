SET DATEFIRST 6;

SELECT 
    DISTINCT
    QuatationNo,
    UPPER([Type]) AS [Type],
    [block_customer],
    UPPER([Status]) AS [Status],
    COALESCE([vm], 0) AS [vm],
    [Startdate],
    DATEPART(YEAR, [Startdate]) AS [Year],
    DATEPART(QUARTER, [Startdate]) AS [Q],
	DATEPART(WEEK, GETDATE()) AS [week],  
    updated_at_etl,
	NULL AS [DataType]

FROM
    [Quotation].[dbo].[API_Summary_QT_Sale]
WHERE  
    UPPER([Status]) IN ('W','O','R')
    AND [block_customer] IS NOT NULL 
    AND UPPER([Type]) = 'RECURRING'