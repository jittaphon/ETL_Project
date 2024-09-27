WITH DataFilter AS (
SELECT 
  SaleDocument
 ,DocDate
 ,NetValue
 ,BeforeTaxValue
 ,TaxValue
 ,CREATED_ON 
FROM [SO].[dbo].[ERP_inv006_JV]   /*DiSTINCT ข้อมูลไม่ซ้ำออกมาก่อน จากนั้นก็ ค่อยนำไปจัด row เพื่อหาว่ามีซ้ำไหม*/
),

SetRow AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY SaleDocument ORDER BY SaleDocument DESC) AS rn FROM DataFilter 
)
SELECT * FROM SetRow WHERE SaleDocument = 'SWC-INV09-20050012'
