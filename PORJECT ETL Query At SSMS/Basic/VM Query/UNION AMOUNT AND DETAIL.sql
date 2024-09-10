
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


-- Combine all the data into a single result set and then count occurrences
SELECT
    Doc_id,
    COUNT(*) AS Count,
    MIN(Date_approve) AS Min_Date_approve,  -- Example of additional aggregation
    MAX(Date_approve) AS Max_Date_approve
FROM (
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
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount2 AS Amount,
        Detail2 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount3 AS Amount,
        Detail3 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    -- Repeat for the remaining columns (up to Amount10, Detail10)
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount4 AS Amount,
        Detail4 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount5 AS Amount,
        Detail5 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount6 AS Amount,
        Detail6 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount7 AS Amount,
        Detail7 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount8 AS Amount,
        Detail8 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount9 AS Amount,
        Detail9 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
    
    UNION ALL
    
    SELECT
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount10 AS Amount,
        Detail10 AS Detail,
        Doc_Type,
        status,
        Total_Amount
    FROM [TrainingSQL].[dbo].[keypettycash]
) AS CombinedData
GROUP BY Doc_id
ORDER BY Count DESC;


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
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount2 AS Amount,
    Detail2 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount3 AS Amount,
    Detail3 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount4 AS Amount,
    Detail4 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount5 AS Amount,
    Detail5 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount6 AS Amount,
    Detail6 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount7 AS Amount,
    Detail7 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount8 AS Amount,
    Detail8 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount9 AS Amount,
    Detail9 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash]
UNION ALL
SELECT
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount10 AS Amount,
    Detail10 AS Detail,
    Doc_Type,
    status,
    Total_Amount
FROM [TrainingSQL].[dbo].[keypettycash];


