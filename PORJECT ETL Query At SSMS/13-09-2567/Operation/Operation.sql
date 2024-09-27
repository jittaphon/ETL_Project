SELECT 
    [Network Layer],
    [Healthscore_percent],
    CASE
        WHEN [Healthscore_percent] >= 50 THEN 'Normal'
        WHEN [Healthscore_percent] BETWEEN 30 AND 49 THEN 'Warning'
        WHEN [Healthscore_percent] BETWEEN 0 AND 29 THEN 'Critical'
        ELSE 'Unknown'
    END AS [Status]
FROM [SO].[dbo].[API_Operation_Network];
