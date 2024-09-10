-- ประกาศตัวแปรสำหรับ SQL แบบไดนามิก
DECLARE @sql NVARCHAR(MAX) = ''; 
DECLARE @i INT = 1;

-- อันดับ 2 สร้าง SQL แบบไดนามิกสำหรับแต่ละ Amount และ Detail นำไป loop
WHILE @i <= 10
BEGIN
    SET @sql = @sql + 
    'SELECT 
        [Business],
        [Type],
        [Doc_type],
        [Document_id],
        CASE [Document_status]
            WHEN ''W'' THEN ''เอกสารรออนุมัติ''
            WHEN ''Y'' THEN ''เอกสารรอนุมัติเรียบร้อยเเล้ว''
            WHEN ''C'' THEN ''เอกสารถูกยกเลิก''
            WHEN ''R'' THEN ''เอกสารถูกปฎิเสธ''
            ELSE [Document_status]
        END AS [Document_status],
        [Document_type_name],
        [Department],
        [130_Using_money],
        [129_Amount_left],
        [31_Total_allowance],
        CAST(Amount' + CAST(@i AS NVARCHAR(2)) + ' AS NVARCHAR(50)) AS Amount,
        CAST(Detail' + CAST(@i AS NVARCHAR(2)) + '_frist AS NVARCHAR(50)) AS Detail,
        CAST(''Detail' + CAST(@i AS NVARCHAR(2)) + ''' AS NVARCHAR(50)) AS Detail_Column,
        [Total_amount],
        [CreatedAt],
        [UpdatedAt]
    FROM LatestData
    WHERE rn = 1
    UNION ALL ';
    SET @i = @i + 1;
END
-- ลบ UNION ALL ตัวสุดท้าย
SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL '));


-- อันดับ 1 เพิ่ม CTE สำหรับการจัดลำดับข้อมูลในตารางก่อน
SET @sql = '
;WITH LatestData AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY Document_id ORDER BY UpdatedAt DESC) AS rn
    FROM [TrainingSQL].[dbo].[API_Approved]
)
SELECT * FROM (
    ' + @sql + '
) AS FinalResultsTable
WHERE Business = ''อินเทอร์เน็ตประเทศไทย'' 
    AND Type IN (''pettycash'') 
    AND Amount <> ''0.00''  
    AND Detail IN (''ค่าใช้จ่าย outsource'', ''ค่าเดินทาง/ที่พัก'', ''ค่าธรรมเนียมและภาษี'', ''ค่ารับรอง'', ''ค่าสวัสดิการ'', ''อื่นๆ'')



';

-- อันดับ 3 เพิ่ม UNION ตาราง ที่มีเเต่ Type advance and allowance เพราะ prettycash เสร็จตอนที่ loop ไปเเล้ว
SET @sql = @sql+ '
	UNION ALL 
	SELECT
	[Business],
        [Type],
        [Doc_type],
        [Document_id],
        CASE [Document_status]
            WHEN ''W'' THEN ''เอกสารรออนุมัติ''
            WHEN ''Y'' THEN ''เอกสารรอนุมัติเรียบร้อยเเล้ว''
            WHEN ''C'' THEN ''เอกสารถูกยกเลิก''
            WHEN ''R'' THEN ''เอกสารถูกปฎิเสธ''
            ELSE [Document_status]
        END AS [Document_status],
        [Document_type_name],
        [Department],
        [130_Using_money],
        [129_Amount_left],
        [31_Total_allowance],
        NULL AS Amount,
        NULL AS Detail,
        NULL AS Detail_Column,
        [Total_amount],
        [CreatedAt],
        [UpdatedAt]
		FROM LatestData 
		WHERE LatestData.Type IN (''allowance'', ''advance'') AND Business = ''อินเทอร์เน็ตประเทศไทย'' AND rn = 1 
';





-- ประมวลผล SQL ที่สร้างขึ้น
INSERT INTO [TrainingSQL].[dbo].[API_Approved_Result2]
EXEC sp_executesql @sql;


