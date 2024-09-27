
SELECT DISTINCT
       SO_JV.[sonumber]
      ,SO_JV.[sodate]
	  ,SO_JV.[Sorgcode] AS [company_code]
	  ,SO_JV.[soldcode] As [customer_id]
	  ,SO_JV.[soldname] AS [customer_name]
	  ,CS_JV.[TaxID] 
	  ,CS_JV.[PaymentTermCode]
	  ,SO_JV.[pCS26] AS [QuotationNo]
	  ,SO_JV.[SDPropertySO06]
	  ,SO_JV.[SORemark]
	  ,SO_JV.[ContractStartDate]
	  ,SO_JV.[ContractEndDate],
	   ISNULL(SO_JV.[TotalContractAmount], 0.00) AS [TotalContractAmount]
	  ,SO_JV.[SOWebStatus]
	  ,SO_JV.[sostatus]
	  ,SO_JV.[SORefer]
	  ,SO_JV.[SCNumber]
      ,SO_JV.[SCStatus]
      ,SO_JV.[SVNumber]
      ,SO_JV.[SVStatus]
      ,SO_JV.[PeriodStartDate]
      ,SO_JV.[PeriodEndDate],
	   ISNULL(SO_JV.[PeriodAmount], 0.00) AS [PeriodAmount]
      ,SO_JV.[PeriodStatus]
      ,SO_JV.[billingnumber]
      ,SO_JV.[BLSCDocNo]
      ,SO_JV.[GetCN]
      ,SO_JV.[INCSCDocNo]
      ,SO_JV.[REVSCDocNo]
      ,SO_JV.[INCSCDocDate]
      ,SO_JV.[SDPropertyCS28]
	   ,SO_JV.[pCS21] AS [SaleFactor]
       ,SO_JV.[pCS22] AS [intINET]
       ,SO_JV.[pCS23] AS [intJV]
       ,SO_JV.[pCS24] AS [ExternalFactor]
       ,SO_JV.[SOType]
	   ,SO_JV.[CustomerType]
       ,SO_JV.[pCS30]
       ,SO_JV.[pSC01]
	   ,SO_JV.[SDPropertySC02]
	   ,IN_JV.[SaleDocument] AS [invoicenumber]
	   ,IN_JV.[DocDate] AS [invoice_date]
	   ,ISNULL(IN_JV.[NetValue],0.00) AS [invoice_netvalue]
	   ,ISNULL(IN_JV.[BeforeTaxValue],0.00) AS [invoice_BeforeTaxValue]
	   ,ISNULL(IN_JV.[TaxValue],0.00) AS [invoice_Taxvalue]
	   ,IN_JV.[CREATED_ON] AS [invoice_CreatedDate]
	   ,SO_JV.[INVSCDocNo]
       ,SO_JV.[INVSCDocDate],
	   ISNULL(SO_JV.[INVSCDocAmount], 0.00) AS [INVSCDocAmount]
	   ,CM_JV.[CREATED_ON] AS [receipt_CreatedDate]
	   ,SO_JV.[CREATED_ON]
	   ,SO_JV.[UPDATED_ON]
  FROM [SO].[dbo].[API_ERP_SO_JV] As SO_JV 
  LEFT JOIN (SELECT DISTINCT [TaxID] , [PaymentTermCode],[CustomerCode],[CompanyCode] FROM [SO].[dbo].[ERP_Master_Customer_JV] ) AS CS_JV 
  ON SO_JV.soldcode = CS_JV.[CustomerCode] AND SO_JV.[Sorgcode] = CS_JV.[CompanyCode] 
  -------------------------------------------
  LEFT JOIN (SELECT DISTINCT [SaleDocument] ,[DocDate] ,[NetValue],[BeforeTaxValue],[TaxValue],[CREATED_ON]  FROM [SO].[dbo].[ERP_inv006_JV]) AS  IN_JV 
  ON SO_JV.[BLSCDocNo] = IN_JV.SaleDocument 
  -------------------------------------------
  LEFT JOIN (SELECT DISTINCT [IncomingDoc] , [CREATED_ON] , [UPDATED_ON] FROM [SO].[dbo].[ERP_IncomingList_JV]) CM_JV 
  ON SO_JV.[INCSCDocNo] = CM_JV.[IncomingDoc] 
