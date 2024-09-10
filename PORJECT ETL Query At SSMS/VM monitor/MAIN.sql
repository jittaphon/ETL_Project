SELECT DISTINCT QuatationNo AS qt_number
, updatedAt
, CAST('2024-09-01' AS DATETIME) AS updated_at_etl
/*GETDATE()*/ 
FROM [Quotation].[dbo].[API_Summary_QT_Sale]
where updatedAt between '2024-01-01' and '2024-09-01' 
--order by updatedAt desc
--93844