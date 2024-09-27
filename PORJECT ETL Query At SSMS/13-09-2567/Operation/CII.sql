SELECT 
   CASE
	    WHEN UPPER(TRIM([parameter])) IN( 'SLA') THEN 'Operation-CII-Availability'
	    WHEN UPPER(TRIM([parameter])) IN( 'RESPONSE TIME','SUCCESS STATUS') THEN 'Operation-CII-Performance'
		WHEN UPPER(TRIM([parameter])) IN( 'MTTN','MTTR') THEN 'Operation-CII-Compliance'
		ELSE 'Operation-CII-Security'
   END AS [Source],
	UPPER(TRIM([parameter])) AS [parameter], 
    CASE 
        WHEN ISNUMERIC(REPLACE([health_score], '%', '')) = 1 
        THEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2))  -- แปลงเป็นทศนิยม 2 ตำแหน่ง
        ELSE NULL  -- หรือแสดงข้อความหรือค่าที่คุณต้องการแทน
    END AS [Health_Score],
	CASE 
        WHEN UPPER(TRIM([parameter])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 0 AND 99 
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 99 AND 99.9 
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'SLA' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 99.9 AND 100  
		THEN 'Green'  
		--------------------------
		WHEN UPPER(TRIM([parameter])) = 'RESPONSE TIME' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) > 5
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'RESPONSE TIME' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 1 AND 5
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'RESPONSE TIME' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 1 
		THEN 'Green'  
		-----------------------------------
		WHEN UPPER(TRIM([parameter])) = 'SUCCESS STATUS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 80
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'SUCCESS STATUS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 80 AND 94
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'SUCCESS STATUS' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100 
		THEN 'Green'  
		----------------------------------
		WHEN UPPER(TRIM([parameter])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 80
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 80 AND 94
        THEN 'Yellow'  
        WHEN UPPER(TRIM([parameter])) = 'MTTN' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100 
		THEN 'Green'  
		--------------------------------------
		WHEN UPPER(TRIM([parameter])) = 'MTTR' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 95
        THEN 'Red'
        WHEN UPPER(TRIM([parameter])) = 'MTTR' AND CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 95 AND 100 
		THEN 'Green'  
		---------------------------------------
	    WHEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) < 50
        THEN 'Red'
        WHEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 50 AND 79
        THEN 'Yellow'  
        WHEN CAST(REPLACE([health_score], '%', '') AS DECIMAL(18, 2)) BETWEEN 80 AND 100 
		THEN 'Green'  
	END AS [status],
	CONVERT(NVARCHAR(10), FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyy-MM')) AS period_month,
	GETDATE() AS update_at_etl
FROM [Parameter].[dbo].[API_HealthCheckParameter_Operation_Cii]
