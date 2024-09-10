SELECT TOP (1000) [Doc_id]
      ,[Date_approve]
      ,[Status_approve]
      ,[Department]
      ,[Amount1]
      ,[Amount2]
      ,[Amount3]
      ,[Amount4]
      ,[Amount5]
      ,[Amount6]
      ,[Amount7]
      ,[Amount8]
      ,[Amount9]
      ,[Amount10]
      ,[Doc_Type]
      ,[status]
      ,[Detail1]
      ,[Detail2]
      ,[Detail3]
      ,[Detail4]
      ,[Detail5]
      ,[Detail6]
      ,[Detail7]
      ,[Detail8]
      ,[Detail9]
      ,[Detail10]
      ,[Total_Amount]
  FROM [TrainingSQL].[dbo].[keypettycash]


 SELECT Doc_id,Date_approve,Amount,Detail,SourceDetail FROM [TrainingSQL].[dbo].[keypettycash] AS KP CROSS APPLY 
 (
 VALUES
  (KP.amount1, KP.detail1,'Detail1'),
  (KP.amount2, KP.detail2,'Detail2'),
  (KP.amount3, KP.detail2,'Detail3')
 ) AS A (Amount,Detail,SourceDetail) 
UNION ALL
SELECT 
    Doc_id,
    doc_accept AS Date_approve,
    NULL AS Amount,
    NULL AS First_Detail,
    NULL AS Detail_Column
FROM [TrainingSQL].[dbo].[KeyAdvance]