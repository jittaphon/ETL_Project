WITH ROWTABLE AS (
SELECT * , ROW_NUMBER() OVER (PARTITION BY [employee_id] ORDER BY [updatedAt] DESC) AS rn
FROM [Quotation].[dbo].[API_Summary_QT_Sale]
),
---------------JOIN AND CLEAN COL ---------------------
JOIN_S_R AS( 
SELECT 
       MAX(CASE WHEN rn = 1 THEN [TeamSale] ELSE NULL END) OVER (PARTITION BY [employee_id]) AS [TeamSale]
	  ,[employee_id]
	  ,[sale_id]
      ,[service_type]
      ,LOWER(REPLACE([Type], ' ', '')) AS [Type]
      ,[DocType]
      ,[customer_name]
      ,[serviceName]
      ,[StatusQT]
      ,[QuatationNo]
      ,[so_no]
      ,[CostSheet]
      ,[verify]
      ,[cvm_id]
      ,[Startdate]
      ,[Enddate]
      ,[ccdate]
      ,[total_revenue]
      ,[Amount]
      ,[FullSaleName]
      ,[FullSaleLastName]
      ,[FullPresaleName]
      ,[customerType]
      ,[customer_status]
      ,[block_customer]
      ,[block_new_customer]
      ,[quality_quotation]
      ,[customerGrade]
      ,[vm]
      ,LOWER(REPLACE([Status], ' ', '')) AS [Status]
      ,[BD_Status]
      ,[Presale_Status]
      ,[customer_id]
      ,[approveDate]
      ,[Performance]
      ,[bidding]
      ,[refer]
      ,[reason]
      ,[DocDateQT]
      ,LOWER(REPLACE([company_type], ' ', '')) AS [company_type]
      ,[DocType_ETL]
      ,[Terminate_remark]
      ,[tax_id]
      ,[business_type]
      ,[partner_account]
      ,[updatedAt]
	  ,[id]
      ,[sale_name]
      ,[start_date]
      ,[target]
      ,[group]
      ,[group2]
      ,[url]
      ,[target_vmi_q]
	   ,[rn]
FROM ROWTABLE SQS 
LEFT JOIN [HR].[dbo].[API_Ranking_Sale_Block_AB] AS SBAB
ON SQS.employee_id = SBAB.sale_id 
),


---------------Filter Logic---------------------
FilterLogic AS (
SELECT * FROM JOIN_S_R WHERE company_type = 'inet'
  AND [Status] IN ('o', 'w')
  AND [Type] IN ('recurring', 'onetime')
)

SELECT 
    employee_id,
   [QuatationNo],
    CASE
        WHEN PPL_QT.[document_id] IS NOT NULL THEN PPL_QT.[Total_Revenue_Quotation]
        WHEN PPL_QTL.[document_id] IS NOT NULL THEN PPL_QTL.[Total_Revenue_Quotation]
        WHEN PPL_Lead.[document_id] IS NOT NULL THEN PPL_Lead.[Total_Revenue_Per_Month]
        ELSE [Amount]
    END AS [Amount],
    PPL_QT.[document_id],
    PPL_QTL.[document_id],
    PPL_Lead.[document_id],
    PPL_QT.[Total_Revenue_Quotation],
    PPL_QTL.[Total_Revenue_Quotation],
    PPL_Lead.Total_Revenue_Per_Month,
	[Amount],
    LOWER(REPLACE(PPL_QT.[SO_Type], ' ', '')) AS [PPL_QT_SO_Type],
    LOWER(REPLACE(PPL_QTL.[SO_Type], ' ', '')) AS [PPL_QTL_SO_Type],
    LOWER(REPLACE(PPL_Lead.[SO_Type], ' ', '')) AS [PPL_Lead_SO_Type],
	LOWER(REPLACE(FL.[Type], ' ', '')) AS [SO_Type]
 
FROM 
    FilterLogic FL
-- Join with PPL_Doc_QT
LEFT JOIN [Quotation].[dbo].[PPL_Doc_QT] PPL_QT 
    ON FL.[QuatationNo] = PPL_QT.[document_id]
-- Join with PPL_Doc_QTLead
LEFT JOIN [Quotation].[dbo].[PPL_Doc_QTLead] PPL_QTL
    ON FL.[QuatationNo] = PPL_QTL.[document_id]
-- Join with API_PPL_Lead_Doc
LEFT JOIN [Lead].[dbo].[API_PPL_Lead_Doc] PPL_Lead
    ON FL.[QuatationNo] = PPL_Lead.[document_id]
--WHERE 
--    LOWER(REPLACE(PPL_QT.[SO_Type], ' ', '')) = 'onetime'
--    OR LOWER(REPLACE(PPL_QTL.[SO_Type], ' ', '')) = 'onetime'
--    OR LOWER(REPLACE(PPL_Lead.[SO_Type], ' ', '')) = 'onetime';



 