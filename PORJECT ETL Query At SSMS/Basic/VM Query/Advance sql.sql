SELECT TOP (1000) [doc_id]
      ,[doc_accept]
      ,[doc_status]
      ,[127_Total_Advance_Payment]
      ,[130_Using_Money]
      ,[129_Amount_Left]
      ,[126_Ref_Doc_ADV]
      ,[8_Department]
      ,[13_Doc_Type]
      ,[15_Total_Amount]
  FROM [TrainingSQL].[dbo].[KeyAdvance]

  SELECT COUNT(*),[doc_id] FROM [TrainingSQL].[dbo].[KeyAdvance] GROUP BY [doc_id]

  /*-----------------------------------------------------------------*/

 
  /*-----------------------------------------------------------------*/


  /*-----------------------------------------------------------------*/

  SELECT 
  [doc_id],
  [doc_accept]
  [doc_status],
  [130_Using_Money],
  [129_Amount_Left],
  [15_Total_Amount],
  [8_Department]
FROM 
  [TrainingSQL].[dbo].[KeyAdvance]
GROUP BY 
  [doc_id],
  [doc_status],
  [doc_accept],
  [130_Using_Money],
  [15_Total_Amount],
  [8_Department],
  [129_Amount_Left];
  