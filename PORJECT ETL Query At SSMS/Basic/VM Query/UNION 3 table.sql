DECLARE @sql NVARCHAR(MAX) = ''; /* สร้าง Code Query */
DECLARE @i INT = 1; /* สร้างตัวแปร i = ตัวนับรอบ */

-- Loop เพื่อสร้าง Query สำหรับตารางแรก [keypettycash]
WHILE @i <= 10
BEGIN
    SET @sql = @sql + 
    'SELECT 
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        CAST(Amount' + CAST(@i AS NVARCHAR(2)) + ' AS NVARCHAR(50)) AS Amount,
        CASE 
            WHEN CHARINDEX('','', Detail' + CAST(@i AS NVARCHAR(2)) + ') > 0 THEN SUBSTRING(Detail' + CAST(@i AS NVARCHAR(2)) + ', 1, CHARINDEX('','', Detail' + CAST(@i AS NVARCHAR(2)) + ') - 1)
            ELSE Detail' + CAST(@i AS NVARCHAR(2)) + '
        END AS First_Detail,
        ''Detail' + CAST(@i AS NVARCHAR(2)) + ''' AS Detail_Column,
        Doc_Type,
        Status,
        Total_Amount,
        NULL AS [130_Using_Money],
        NULL AS [129_Amount_Left],
        NULL AS [Total_Allowance],
		''pettycash'' AS TableName


    FROM [TrainingSQL].[dbo].[keypettycash]
    UNION ALL
    ';
    SET @i = @i + 1;
END

-- ตัดคำสั่ง UNION ALL ตัวสุดท้ายออก
SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL'));

-- รวม Query จากตาราง [KeyAdvance]
SET @sql = @sql + '
UNION ALL
SELECT 
    Doc_id,
    doc_accept AS Date_approve,
    doc_status AS Status_approve,
    [8_Department],
    NULL AS Amount,
    NULL AS First_Detail,
    NULL AS Detail_Column,
    [13_Doc_Type] AS Doc_Type,
    NULL AS Status,
    [15_Total_Amount] AS Total_Amount,
    [130_Using_Money],
    [129_Amount_Left],
    NULL AS [Total_Allowance],
		''KeyAdvance'' AS TableName
 
FROM [TrainingSQL].[dbo].[KeyAdvance]
';

-- รวม Query จากตาราง [Allowance]
SET @sql = @sql + '
UNION ALL
SELECT 
    Doc_id,
    [Date_approve] AS Date_approve,
    [Status_approve] AS Status_approve,
    NULL AS Department,
    NULL AS Amount,
    NULL AS First_Detail,
    NULL AS Detail_Column,
    NULL AS Doc_Type,
    NULL AS Status,
    NULL AS Total_Amount,
    NULL AS [130_Using_Money],
    NULL AS [129_Amount_Left],
    [Total_Allowance],
	 ''Allowance'' AS TableName
 
FROM [TrainingSQL].[dbo].[Allowance]
';

DECLARE @finalSql NVARCHAR(MAX);
SET @finalSql = '
    ;WITH CombinedResults AS (
        ' + @sql + '
    )
    SELECT 
       *
    FROM CombinedResults 
	WHERE Doc_id = ''PC-256705004623''
';
EXEC sp_executesql @finalSql;