SELECT DISTINCT
       [erp_code]
      ,[sale_emp_id]
      ,[sale_name]
      ,[team_sale]
  FROM [SO].[dbo].[API_CVM_V3_AllContact] WHERE [erp_code] <> '' AND erp_code = 'C05-0001' 
