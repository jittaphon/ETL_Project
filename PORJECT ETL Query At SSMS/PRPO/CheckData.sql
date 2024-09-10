SELECT *
  FROM [PR].[dbo].[API_PRPO_FlowStepPR] 
  WHERE document_id = 'PR02-2024080340'

 SELECT COUNT(*),
      [document_id]
  FROM [PR].[dbo].[API_PRPO_FlowStepPR] GROUP BY [document_id] HAVING COUNT(*) > 1
