SELECT TOP (1000)
    [Month],
    [Target],
	CAST(REPLACE([percent_ACC], '%', '') AS DECIMAL(5, 2)) AS [percent],
    CAST(REPLACE([percent_ACC], '%', '') AS DECIMAL(5, 2)) AS [percent_ACC],
    CAST(REPLACE([percent_predit], '%', '') AS DECIMAL(5, 2)) AS [percent_predit]
FROM [SO].[dbo].[API_Cash_IN]
WHERE [Month] = DATEADD(MONTH, -2, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
