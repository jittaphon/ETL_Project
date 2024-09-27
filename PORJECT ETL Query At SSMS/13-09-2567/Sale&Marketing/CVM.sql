SELECT 
    COUNT(*) AS TotalCount,
    CASE 
        WHEN COUNT(*) < 4500 THEN 'Red'
        WHEN COUNT(*) >= 4500 THEN 'Green'
    END AS status_color
FROM [SO].[dbo].[API_Block_Customer];
