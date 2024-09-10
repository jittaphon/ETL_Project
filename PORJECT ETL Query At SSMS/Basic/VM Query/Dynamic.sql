DECLARE @sql NVARCHAR(MAX) = ''; /*สร้างCode Query*/
DECLARE @i INT = 1; /*สร้างตัวแปร i = ตัวนับรอบ*/

WHILE @i <= 10
BEGIN
    SET @sql = @sql + 
    'SELECT 
        Doc_id,
        Date_approve,
        Status_approve,
        Department,
        Amount' + CAST(@i AS NVARCHAR(2)) + ' AS Amount,
        CASE 
            WHEN CHARINDEX('','', Detail' + CAST(@i AS NVARCHAR(2)) + ') > 0 THEN SUBSTRING(Detail' + CAST(@i AS NVARCHAR(2)) + ', 1, CHARINDEX('','', Detail' + CAST(@i AS NVARCHAR(2)) + ') - 1)
            ELSE Detail' + CAST(@i AS NVARCHAR(2)) + '
        END AS First_Detail,
        Doc_Type,
        status,
        Total_Amount,
        ''Detail' + CAST(@i AS NVARCHAR(2)) + ''' AS Detail_Column
    FROM [TrainingSQL].[dbo].[keypettycash]
    UNION ALL
    ';
    SET @i = @i + 1;
END

-- ตัดคำสั่ง UNION ALL ตัวสุดท้ายออก
SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL '));

-- สร้างคำสั่ง SQL สำหรับการจัดกลุ่มและนับจำนวนที่ซ้ำ
DECLARE @finalSql NVARCHAR(MAX);
SET @finalSql = '
    ;WITH CombinedResults AS (
        ' + @sql + '
    )
    SELECT 
     *
    FROM CombinedResults
	WHERE Doc_id = ''PC-256701003485''

';

-- รันคำสั่ง SQL ที่สร้างขึ้น
EXEC sp_executesql @sql;
