SELECT [QuatationNo]
      ,[Type]
      ,[BlockCustomer]
      ,[Status]
      ,[Vm]
      ,[StartDate]
      ,[Year]
      ,[Q]
      ,[Week]
      ,[Updated_At_Etl]
      ,[DataType]
  FROM [TrainingSQL].[dbo].[Training_Insert]  ORDER BY [updated_at_etl] DESC

SET DATEFIRST 6;

DECLARE @LatestDate DATETIME;
DECLARE @OneWeekAgo DATETIME;

-- ดึงวันที่ล่าสุดจากข้อมูล
SELECT @LatestDate = MAX([updated_at_etl])
FROM [TrainingSQL].[dbo].[Training_Insert];

-- คำนวณวันที่หนึ่งสัปดาห์ก่อนจากวันที่ล่าสุด
SET @OneWeekAgo = DATEADD(WEEK, -1, @LatestDate);

PRINT @LatestDate;
PRINT @OneWeekAgo;
-- ลบข้อมูลที่เก่ากว่าสัปดาห์หนึ่งจากวันที่ล่าสุด
DELETE FROM [TrainingSQL].[dbo].[Training_Insert]
WHERE [updated_at_etl] < @OneWeekAgo;


