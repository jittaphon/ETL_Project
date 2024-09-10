

--SELECT * FROM [TrainingSQL].[dbo].[Training_Insert]

--;WITH CTE AS (
--   SELECT 
--        [qt_number],
--        [updatedAt],
--        MAX(updated_at_etl) AS MaxUpdatedAt
--    FROM 
--        [TrainingSQL].[dbo].[Training_Insert]
--    GROUP BY 
--        [qt_number],
--        [updatedAt]
--) /*ข้อมูลล่าสุด*/

DELETE FROM [TrainingSQL].[dbo].[Training_Insert] 
WHERE [updated_at_etl] < (SELECT MAX(updated_at_etl) FROM [TrainingSQL].[dbo].[Training_Insert])



SELECT * FROM [TrainingSQL].[dbo].[Training_Insert] 

