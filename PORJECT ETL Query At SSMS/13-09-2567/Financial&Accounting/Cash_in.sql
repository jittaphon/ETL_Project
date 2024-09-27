-- Calculate the date two months prior to the current month
SELECT 
    [percent],
	'Cash_In' AS Source,
    CASE 
        WHEN LEN(REPLACE([percent], '%', '')) > 0 AND ISNUMERIC(REPLACE([percent], '%', '')) = 1 AND CAST(REPLACE([percent], '%', '') AS decimal) > 90 THEN 'Green'
        ELSE 'Red'
    END AS status_color
FROM 
    [SO].[dbo].[API_Cash_In]
WHERE 
    [Month] = DATEADD(MONTH, -2, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
