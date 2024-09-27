
WITH DataFilter AS (
SELECT 
       [IncomingDoc]
      ,[CREATED_ON]
      ,[UPDATED_ON]
  FROM [SO].[dbo].[ERP_IncomingList_JV]  /*DiSTINCT ������������͡�ҡ�͹ �ҡ��鹡� ���¹�仨Ѵ row ����������ի�����*/

),
SetRow AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY [IncomingDoc] ORDER BY [IncomingDoc] DESC) AS rn FROM DataFilter 
)
SELECT * FROM SetRow WHERE rn > 1
