
WITH DataFilter AS (
SELECT 
       [IncomingDoc]
      ,[CREATED_ON]
      ,[UPDATED_ON]
  FROM [SO].[dbo].[ERP_IncomingList_JV]  /*DiSTINCT ข้อมูลไม่ซ้ำออกมาก่อน จากนั้นก็ ค่อยนำไปจัด row เพื่อหาว่ามีซ้ำไหม*/

),
SetRow AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY [IncomingDoc] ORDER BY [IncomingDoc] DESC) AS rn FROM DataFilter 
)
SELECT * FROM SetRow WHERE rn > 1
