SELECT 
	    CASE 
        WHEN UPPER(TRIM([catagories])) IN ('SLA','BACKUP') THEN 'Operation-Infrastructure-Availability'
	    WHEN UPPER(TRIM([catagories])) IN ('CAPACITY STRETCH CLUSTER','RESOURCE PLANNING','CAPACITY DC-DR CLUSTER') THEN 'Operation-Infrastructure-Performance'
		WHEN UPPER(TRIM([catagories])) IN ('MTTN','MTTR','CUSTOMER SATISFACTION') THEN 'Operation-Infrastructure-Compliance'
		WHEN UPPER(TRIM([catagories])) IN ('2FA','ANTIVIURS') THEN 'Operation-Infrastructure-Security'
		END AS [Source] ,
	    CASE 
        WHEN UPPER(TRIM([catagories])) IN ( 'CAPACITY DC-DR CLUSTER' ,'CAPACITY STRETCH CLUSTER' )
        THEN CONCAT(UPPER(TRIM([catagories])), ' ', UPPER(TRIM([detail])))
        ELSE UPPER(TRIM([catagories]))
        END AS [Parameter]

      ,CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) AS [health_score]
	  ,
    	CASE 
        WHEN UPPER(TRIM([catagories])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 95.95 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 99.5 AND 100  
		THEN 'Green'  
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'BACKUP' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 100 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'BACKUP' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) = 100
		THEN 'Green' 
			----------------------------
		WHEN UPPER(TRIM([catagories])) = 'RESOURCE PLANNING' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) <= 10000
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'RESOURCE PLANNING' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) > 10000
		THEN 'Green' 

		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'CPU' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 45 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'CPU' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 45
		THEN 'Green' 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'RAM' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 45 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'RAM' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 45
		THEN 'Green' 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'DISK' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 70 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'DISK' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 50
		THEN 'Green' 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CAPACITY DC-DR CLUSTER' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 70 
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'CAPACITY DC-DR CLUSTER' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) <= 50
		THEN 'Green'

		WHEN UPPER(TRIM([catagories])) = 'CAPACITY STRETCH CLUSTER' AND UPPER(TRIM([detail])) = 'CPU' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 51 AND 69
        THEN 'Yellow'
        
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'MTTN' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 80
        THEN 'Red'
		WHEN UPPER(TRIM([catagories])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  BETWEEN 80 AND 94
		THEN 'Yellow' 
        WHEN UPPER(TRIM([catagories])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100
		THEN 'Green' 
		 
		----------------------------
		WHEN UPPER(TRIM([catagories])) = 'MTTR' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 95
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'MTTR' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100
		THEN 'Green' 
			----------------------------
		WHEN UPPER(TRIM([catagories])) = 'CUSTOMER SATISFACTION' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  BETWEEN 0 AND 79
        THEN 'Red'
		WHEN UPPER(TRIM([catagories])) = 'CUSTOMER SATISFACTION' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  BETWEEN 80 AND 94
		THEN 'Yellow' 
        WHEN UPPER(TRIM([catagories])) = 'CUSTOMER SATISFACTION' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100
		THEN 'Green'
				----------------------------
		WHEN UPPER(TRIM([catagories])) = '2FA' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  < 100
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = '2FA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) >= 100
		THEN 'Green' 
					----------------------------
		WHEN UPPER(TRIM([catagories])) = 'ANTIVIURS' AND  CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  < 95
        THEN 'Red'
        WHEN UPPER(TRIM([catagories])) = 'ANTIVIURS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) > 95
		THEN 'Green' 
	END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
  FROM [Parameter].[dbo].[API_HealthCheckParameter_Operation_Infrastructure]
  WHERE health_score IS NOT NULL
