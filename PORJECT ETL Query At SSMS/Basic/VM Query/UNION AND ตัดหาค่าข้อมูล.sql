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



  SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount1 AS Amount,
    Detail1 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]

UNION ALL

SELECT
    [doc_id] AS Doc_id,                        -- Map columns to match other SELECT statements
    NULL AS Date_approve,                     -- Use NULL or default values if not available
    NULL AS Status_approve,                   -- Adjust as needed
    [8_Department] AS Department,
    [127_Total_Advance_Payment] AS Amount,    -- Map accordingly
    [126_Ref_Doc_ADV] AS Detail,
    [13_Doc_Type] AS Doc_Type,
    NULL AS status,                           -- Use NULL or default values if not available
    [15_Total_Amount] AS Total_Amount
FROM [TrainingSQL].[dbo].[KeyAdvance]





SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount1 AS Amount,
    -- Extract the first value from the comma-separated list
    COALESCE(
        (SELECT value 
         FROM STRING_SPLIT(Detail2, ',') 
         WHERE RTRIM(LTRIM(value)) <> '' 
         ORDER BY (SELECT NULL) 
         OFFSET 0 ROWS 
         FETCH FIRST ROW ONLY
        ), 
        Detail2
    ) AS First_Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash];

