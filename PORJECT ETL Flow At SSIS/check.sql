SELECT TOP (1000) [Business]
      ,[Type]
      ,[Doc_type]
      ,[Document_id]
      ,[Document_status]
      ,[Document_type_name]
      ,[Transaction_id]
      ,[127_Total_advance_payment]
      ,[128_Spent_amount]
      ,[129_Amount_left]
      ,[130_Using_money]
      ,[126_Ref_doc_ADV]
      ,[Department]
      ,[29_Actual_working_days]
      ,[30_Amount_day]
      ,[31_Total_allowance]
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
      ,[Total_amount]
      ,[Detail1_frist]
      ,[Detail2_frist]
      ,[Detail3_frist]
      ,[Detail4_frist]
      ,[Detail5_frist]
      ,[Detail6_frist]
      ,[Detail7_frist]
      ,[Detail8_frist]
      ,[Detail9_frist]
      ,[Detail10_frist]
      ,[CreatedAt]
      ,[UpdatedAt]
      ,[Create_at_bi]
      ,[Create_at_etl]
  FROM [TrainingSQL].[dbo].[API_Approved]

SELECT 
   *
FROM 
    [TrainingSQL].[dbo].[API_Approved]
WHERE 
    Business = 'อินเทอร์เน็ตประเทศไทย'



SELECT * FROM [TrainingSQL].[dbo].[API_Approved] 
WHERE Document_id = 'PC-256703004255'


SELECT 
    *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Document_id ORDER BY [UpdatedAt] DESC) AS RowNum
    FROM 
        [TrainingSQL].[dbo].[API_Approved]
    WHERE 
        Business = 'อินเทอร์เน็ตประเทศไทย' AND Type = 'pettycash'
) AS RankedData
ORDER BY 
    Document_id, RowNum;

SELECT TOP (1000) 

      [Detail1_frist]
      ,[Detail2_frist]
      ,[Detail3_frist]
      ,[Detail4_frist]
      ,[Detail5_frist]
      ,[Detail6_frist]
      ,[Detail7_frist]
      ,[Detail8_frist]
      ,[Detail9_frist]
      ,[Detail10_frist]
     
  FROM [TrainingSQL].[dbo].[API_Approved]