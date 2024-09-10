;WITH CTE AS (
    SELECT 
	
        [qt_number],
		[updatedAt],
		[updated_at_etl],
        ROW_NUMBER() OVER (PARTITION BY [qt_number],[updatedAt] ORDER BY updated_at_etl DESC) AS RowNum
    FROM 
       [TrainingSQL].[dbo].[Training_Insert]

)
SELECT * FROM CTE
--DELETE FROM  CTE
--WHERE RowNum > 1

--SELECT * FROM CTE WHERE [qt_number] = 'Lead-202306002397' ORDER BY updated_at_etl DESC
--SELECT * FROM CTE


--SELECT DISTINCT [updated_at_etl] FROM  CTE


  
