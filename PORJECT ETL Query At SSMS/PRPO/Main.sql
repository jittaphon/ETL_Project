-----------------------------FlowStepPR-------------------------------------------------------
WITH GroupDataFPR AS (
SELECT [document_id] ,[status],[index],[approver_first_name_th]
  FROM [PR].[dbo].[API_PRPO_FlowStepPR] 
  GROUP BY [document_id], [status],[index],[approver_first_name_th]
  --HAVING [document_id] = 'PR06-2024072440'
),
GroupDataHPR AS (
SELECT 
       [created_at],
	   [owner_full_name_th],
       [document_id],
	   [total_price],
       [document_status]
  FROM [PR].[dbo].[API_PRPO_HeaderPR] GROUP BY 
       [created_at],
	   [owner_full_name_th],
       [document_id],
	   [total_price],
       [document_status]

),
-------------------------------Change status-----------------------------------------------------
StatusChange AS (
    SELECT 
        HPR.[created_at],
        HPR.[owner_full_name_th],
        HPR.[document_id],
        HPR.[total_price],
        CASE
            WHEN HPR.document_status = 'Y' THEN 'Complete'
            WHEN HPR.document_status = 'C' THEN 'Cancel'
            WHEN HPR.document_status = 'W' THEN 'OnProcess'
            WHEN HPR.document_status = 'R' THEN 'Reject'
        END AS document_status,
        CASE
		    WHEN FPR.[status] <> 'C' AND HPR.document_status = 'C' THEN 'Cancel'
            WHEN FPR.[status] = 'Y' THEN 'Complete'
            WHEN FPR.[status] = 'C' THEN 'Cancel'
            WHEN FPR.[status] = 'W' THEN 'OnProcess'
            WHEN FPR.[status] = 'R' THEN 'Reject'
            ELSE FPR.[status]
        END AS [status],
        FPR.[index],
        FPR.[approver_first_name_th]
    FROM GroupDataHPR AS HPR
    LEFT JOIN GroupDataFPR AS FPR ON HPR.document_id = FPR.document_id
),
RANKDATA AS (
SELECT  [created_at],
        [owner_full_name_th],
        [document_id],
        [total_price],
        document_status,
        [status],
		CASE 
		WHEN document_status = 'OnProcess' Then CAST([index]+1 AS VARCHAR)
		WHEN document_status = 'Complete' THEN 'Complete'
		WHEN document_status = 'Cancel' THEN 'Cancel'
		WHEN document_status = 'Reject' THEN 'Reject' 
		END AS ลำดับเอกสาร , 
       ROW_NUMBER() OVER (
           PARTITION BY [document_id] , [status]
           ORDER BY 
               CASE 
                   WHEN [status] = 'Cancel' THEN [index] 
               END ASC,
			   CASE 
                   WHEN [status] = 'Reject' THEN [index] 
               END ASC,
			     CASE 
                   WHEN [status] = 'OnProcess' THEN [index] 
               END ASC,
               CASE 
                   WHEN [status] = 'Complete' THEN [index] 
               END DESC
       ) AS rn  
FROM StatusChange
)
--SELECT * FROM RANKDATA WHERE document_id = 'PR06-2024051965'
SELECT  * From RANKDATA WHERE document_status = [status] AND rn  = 1 







   
 
 

