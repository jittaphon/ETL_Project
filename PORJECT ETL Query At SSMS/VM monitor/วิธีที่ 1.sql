SET DATEFIRST 6;
SELECT [QuatationNo]
      ,[Type]
      ,[block_customer]
      ,[Status]
      ,[vm]
      ,[Startdate]
      ,[Year]
      ,[Q]
      ,[week]
      ,[updated_at_etl]
      ,[DataType]
  FROM [TrainingSQL].[dbo].[Training_Insert] ORDER BY [updated_at_etl] DESC

--  DELETE  FROM [TrainingSQL].[dbo].[Training_Insert] WHERE [week] = 3
--  DELETE  FROM [TrainingSQL].[dbo].[Training_Insert] WHERE [week] = 2



SET DATEFIRST 6;

DECLARE @LatestWeek INT;
DECLARE @LatestYear INT;
DECLARE @WeekToDelete INT;

-- ดึงข้อมูลสัปดาห์และปีล่าสุด
SELECT @LatestWeek = DATEPART(WEEK, MAX([updated_at_etl])),
       @LatestYear = DATEPART(YEAR, MAX([updated_at_etl]))
FROM [TrainingSQL].[dbo].[Training_Insert];

-- คำนวณสัปดาห์ที่จะลบ
-- กรณีสัปดาห์ <= 2 จะต้องดูที่ปีที่แล้ว
IF @LatestWeek <= 2
BEGIN
    SET @WeekToDelete = 53 + (@LatestWeek - 2); 
END
ELSE
BEGIN
    SET @WeekToDelete = @LatestWeek - 2;
END

-- ลบข้อมูลตามสัปดาห์ที่คำนวณ
DELETE FROM [TrainingSQL].[dbo].[Training_Insert]
WHERE DATEPART(WEEK, [updated_at_etl]) = @WeekToDelete


