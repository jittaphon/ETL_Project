/*----------------------------------------จัด RANK เพื่อหา วันที่ล่าสุดของข้อมูล ----------------------------------------------------*/
WITH LatestData AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY [document_id], [Service_Name] ORDER BY [updatedAt_doc] DESC) AS rn
    FROM [CostSheet].[dbo].[API_PPL_CS_ServiceTable] 
),

/*--------------------------------------- JOIN API_PPL_CS_ServiceTable <> API_SpecVM_CS เนื่องจากเกิด ERROR เลยต้อ
 จัด format ให้เหมือนเพื่อที่จะเชื่อมได้ถูกต้อง ----------------------------------------------------*/
JOIN_SPACE_VM AS (
    SELECT  
        DISTINCT
        CSST.[document_id],
        CSST.[Service_Name],
        CSST.[Unit_Type],
        TRIM(UPPER(CSST.[Group_Service])) AS [TGroup_Service],
        CSST.[FrontCode],
        CSST.[Revenue],
        CSST.[step_now],
        CSST.[updatedAt_doc],
        CASE
            WHEN SVM.[package] = 'addon' THEN 'addon'
            WHEN SVM.[package] = 'package' THEN 'package'
            ELSE 'package'
        END AS [Package],
		TRIM(UPPER(SVM.[type])) AS [type],
        CAST(NULLIF(SVM.[cpu], '') AS DECIMAL(18, 2)) AS [cpu],
        CAST(NULLIF(SVM.[ram], '') AS DECIMAL(18, 2)) AS [ram],
        CAST(NULLIF(SVM.[disk], '') AS DECIMAL(18, 2)) AS [disk],
        CAST(NULLIF(CSST.[Revenue], '') AS DECIMAL(18, 2)) AS [Revenue1],
        CAST(NULLIF(CSST.[Unit], '') AS DECIMAL(18, 2)) AS [Unit]
		/*
		TRY_CAST(SVM.[cpu] AS DECIMAL(18, 2)) AS [cpu], 
	    TRY_CAST(SVM.[ram] AS DECIMAL(18, 2)) AS [ram],
        TRY_CAST(SVM.[disk] AS DECIMAL(18, 2)) AS [disk],
        TRY_CAST(CSST.[Revenue] AS DECIMAL(18, 2)) AS [Revenue1],
        TRY_CAST(CSST.[Unit] AS DECIMAL(18, 2)) AS [Unit] ไม่อยากใช้ 
		*/
    FROM LatestData CSST
    INNER JOIN [CostSheet].[dbo].[API_SpecVM_CS] SVM 
        ON LOWER(REPLACE(CSST.[Service_Name], ' ', '')) = LOWER(REPLACE(SVM.[service_name], ' ', ''))
    WHERE CSST.rn = 1 
),

/*---------------------------------------- จัด logic เงื่อนไขของ ข้อมูล ใน col ----------------------------------------------------*/
CalculatedData AS (
    SELECT  
        [document_id],
        [Service_Name],
        [Unit],
        [Unit_Type],
        [TGroup_Service],
        [FrontCode],
        [Revenue],
        [step_now],
        [updatedAt_doc],
        CASE
            WHEN [Package] = 'addon' THEN 'addon'
            ELSE 'package'
        END AS [Package],
        [type],
		COALESCE(
        CASE
            WHEN [Package] = 'addon' AND [type] = 'CPU' THEN [Unit]
            WHEN [Package] <> 'addon' AND [TGroup_Service] = 'CLOUD-VMWARE' THEN (COALESCE([cpu], 0) + 2) * [Unit]
            WHEN [Package] <> 'addon' AND [TGroup_Service] <> 'CLOUD-VMWARE' THEN COALESCE([cpu], 0) * [Unit]
            ELSE NULL
        END ,0) [CPU],
		COALESCE(
        CASE 
            WHEN [Package] = 'addon' AND [type] = 'RAM' THEN [Unit]
            WHEN [Package] <> 'addon' AND [TGroup_Service] = 'CLOUD-VMWARE' THEN (COALESCE([ram], 0) + 1) * [Unit]
            WHEN [Package] <> 'addon' AND [TGroup_Service] <> 'CLOUD-VMWARE' THEN COALESCE([ram], 0) * [Unit]
            ELSE NULL 
        END ,0)[RAM],
		COALESCE(
        CASE
            WHEN [Package] = 'addon' AND [type] = 'DISK' THEN [Unit]
            WHEN [Package] <> 'addon' AND [TGroup_Service] = 'CLOUD-VMWARE' THEN (COALESCE([disk], 0) + 0.512) * [Unit]
            WHEN [Package] <> 'addon' AND [TGroup_Service] <> 'CLOUD-VMWARE' THEN COALESCE([disk], 0) * [Unit]
            ELSE NULL 
        END ,0)[Disk],
		 COALESCE(
        CASE
            WHEN [Package] = 'addon' AND [type] = 'VM' THEN [Revenue1]
            ELSE NULL 
        END , 0 ) [VM]
    FROM JOIN_SPACE_VM
	--WHERE document_id IN ('CS-202208038033','CS-202210044557') /*ref CS-202306063887*/
	
),

/*---------------------------------------- จัดเสร็จเเล้ว ทำ COL คำนวนณ ----------------------------------------------------*/

/*---------------------------------------- จัดเสร็จเเล้ว ทำ COL คำนวนณ ทะเงหมด สุดท้าย ----------------------------------------------------*/
CalculatedDataFinal AS (
    SELECT 
        CDF.[document_id],[VM],
        SUM([CPU]) AS [real_cpu],
        SUM([RAM]) AS [real_ram],
        SUM([Disk]) AS [real_disk],
        SUM([CPU])/2.0 AS convert_cpu,
        SUM([RAM])/4.0 AS convert_ram,
        SUM([Disk])/300.0 AS convert_disk,
        ((SUM([CPU])/2.0 + SUM([RAM])/4.0 + SUM([Disk])/300.0) / 3.0) + (SUM([VM])/2800.0) AS avg_convert_spec,
        NULL AS avg_convert_spec_change,
        ECR.[cs_ref_no]
    FROM 
        CalculatedData AS CDF 
    LEFT JOIN [CostSheet].[dbo].[ETL_CS_RefSO] AS ECR 
    ON CDF.document_id =  ECR.cs_number 
    GROUP BY CDF.[document_id], ECR.[cs_ref_no] ,[VM]
	--HAVING CDF.[document_id] IN ('CS-202208038033','CS-202210044557', 'CS-202306063887')
 
),


/*----------------------------------------  ----------------------------------------------------*/
 JOIN_QT_TABLE AS (
    SELECT 
	    DISTINCT
        CD1.document_id AS cs_number,
        QT.document_id AS qt_number,
        CD1.[real_cpu],
        CD1.[real_ram],
        CD1.[real_disk],
        CD1.[VM],
        CD1.convert_cpu,
        CD1.convert_ram,
        CD1.convert_disk,
        CD1.avg_convert_spec,
        (CD1.avg_convert_spec - COALESCE(CD2.avg_convert_spec, 0)) AS avg_convert_spec_change,
        COALESCE(CD1.[cs_ref_no], '') AS cs_ref_no
		
    FROM 
        CalculatedDataFinal AS CD1 
    LEFT JOIN 
        CalculatedDataFinal AS CD2 
    ON CD1.[cs_ref_no] = CD2.[document_id] 
    LEFT JOIN 
        [Quotation].[dbo].[PPL_Doc_QT] AS QT 
    ON SUBSTRING(CD1.document_id, 4, LEN(CD1.document_id) - 3) = SUBSTRING(QT.document_id, 4, LEN(QT.document_id) - 3)
--	WHERE CD1.document_id IN ('CS-202106000278')
  
)

SELECT * FROM JOIN_QT_TABLE 
WHERE cs_number IN ('CS-202208038033','CS-202210044557', 'CS-202306063887')
ORDER BY cs_number
  
--SELECT  document_id,
--        qt_number,
--		real_cpu,
--		real_ram,
--		real_disk,
--		VM,
--		convert_cpu,
--		convert_ram,
--		convert_disk,
--		avg_convert_spec,
--		avg_convert_spec_change,
--		String_AGG(cs_ref_no,',') AS cs_ref_no /*รวมข้อมูลในคอลัมน์เข้าด้วยกัน*/
--		FROM JOIN_QT_TABLE 
--		GROUP BY 
--		document_id,
--		qt_number,
--		real_cpu,
--		real_ram,
--		real_disk,
--		VM,
--		convert_cpu,
--		convert_ram,
--		convert_disk,
--		avg_convert_spec,
--		avg_convert_spec_change
