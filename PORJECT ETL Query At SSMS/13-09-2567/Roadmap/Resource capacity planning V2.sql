SELECT
      COUNT(DISTINCT employeeId_All) AS Total_People
  FROM [HR].[dbo].[dm_EmployeeRatio] WHERE sec_dep_line IS NOT NULL
