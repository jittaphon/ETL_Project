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

-- �֧�ѹ�������ش�ҡ������
SELECT @LatestDate = MAX([updated_at_etl])
FROM [TrainingSQL].[dbo].[Training_Insert];

-- �ӹǳ�ѹ���˹���ѻ�����͹�ҡ�ѹ�������ش
SET @OneWeekAgo = DATEADD(WEEK, -1, @LatestDate);

PRINT @LatestDate;
PRINT @OneWeekAgo;
-- ź�����ŷ����ҡ����ѻ����˹�觨ҡ�ѹ�������ش
DELETE FROM [TrainingSQL].[dbo].[Training_Insert]
WHERE [updated_at_etl] < @OneWeekAgo;


