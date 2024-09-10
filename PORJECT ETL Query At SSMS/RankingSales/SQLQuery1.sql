SELECT 
      [document_id],
	  COUNT(*)
  FROM [PR].[dbo].[API_PRPO_HeaderPR]  GROUP BY [document_id] HAVING COUNT(*) > 1


SELECT 
   DISTINCT *
  FROM [PR].[dbo].[API_PRPO_HeaderPR] WHERE document_id = 'PR06-2024051925'
