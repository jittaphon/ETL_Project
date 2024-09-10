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

-- �֧�������ѻ������л�����ش
SELECT @LatestWeek = DATEPART(WEEK, MAX([updated_at_etl])),
       @LatestYear = DATEPART(YEAR, MAX([updated_at_etl]))
FROM [TrainingSQL].[dbo].[Training_Insert];

-- �ӹǳ�ѻ�������ź
-- �ó��ѻ���� <= 2 �е�ͧ�ٷ��շ������
IF @LatestWeek <= 2
BEGIN
    SET @WeekToDelete = 53 + (@LatestWeek - 2); 
END
ELSE
BEGIN
    SET @WeekToDelete = @LatestWeek - 2;
END

-- ź�����ŵ���ѻ������ӹǳ
DELETE FROM [TrainingSQL].[dbo].[Training_Insert]
WHERE DATEPART(WEEK, [updated_at_etl]) = @WeekToDelete


