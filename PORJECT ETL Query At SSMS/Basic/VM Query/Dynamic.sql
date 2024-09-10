DECLARE @sql NVARCHAR(MAX) = ''; /*���ҧCode Query*/
DECLARE @i INT = 1; /*���ҧ����� i = ��ǹѺ�ͺ*/

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

-- �Ѵ����� UNION ALL ����ش�����͡
SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL '));

-- ���ҧ����� SQL ����Ѻ��èѴ�������йѺ�ӹǹ�����
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

-- �ѹ����� SQL ������ҧ���
EXEC sp_executesql @sql;
