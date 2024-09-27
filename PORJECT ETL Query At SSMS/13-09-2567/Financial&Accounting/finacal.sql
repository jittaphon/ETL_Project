SELECT 
   'Financial&Costing' AS [Source],
	UPPER(TRIM([Detail])) AS [Detail], 
    CASE 
        WHEN ISNUMERIC(REPLACE([Number], '%', '')) = 1 
        THEN CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2))  -- แปลงเป็นทศนิยม 2 ตำแหน่ง
        ELSE NULL  -- หรือแสดงข้อความหรือค่าที่คุณต้องการแทน
    END AS [Number_Decimal],
	CASE 
        WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 2.30 
        THEN 'Critical'
        WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 2.00 AND 2.30 
        THEN 'Warning'  
        WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 2.30 
        THEN 'Normal'
		----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 4.30 
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 4.00 AND 4.30 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'IBD/E RATIO NON REIT (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 4.00
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 30.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 30.00 AND 34.00 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'GROSS PROFIT MARGIN (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 34.00
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'EBIT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 20.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'EBIT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 20.00 AND 22.00 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'EBIT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 22.00
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'EBITDA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 40.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'EBITDA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 40.00 AND 48.00 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'EBITDA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 48.00
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'EBT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 6.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'EBT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 6.00 AND 8.00 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'EBT (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 8.00
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'NP (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 7.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'NP (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 7.00 AND 11.00 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'NP (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 11.00
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'ICR (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 1.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'ICR (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 1.00 AND 1.20 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'ICR (เท่า)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 1.20
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'ROA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 6.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'ROA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 6.00 AND 7.10 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'ROA (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 7.10
        THEN 'Normal'
		-----------------------------------------
		WHEN UPPER(TRIM([Detail])) = 'ROE (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) < 8.00
        THEN 'Critical'
		WHEN UPPER(TRIM([Detail])) = 'ROE (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) BETWEEN 8.00 AND 9.20 
        THEN 'Warning'
		WHEN UPPER(TRIM([Detail])) = 'ROE (%)' AND CAST(REPLACE([Number], '%', '') AS DECIMAL(18, 2)) > 9.20
        THEN 'Normal'
    END AS [Status]
FROM [SO].[dbo].[API_finance_ratio];
