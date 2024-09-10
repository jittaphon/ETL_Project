DECLARE @sql NVARCHAR(MAX) = ''; /* ���ҧ Code Query */
DECLARE @i INT = 1; /* ���ҧ����� i = ��ǹѺ�ͺ */

-- Loop �������ҧ Query ����Ѻ���ҧ�á [keypettycash]
WHILE @i <= 10
BEGIN
    SET @sql = @sql + 
    'SELECT 
        [Business],
        [Type],
        [Document_id],
        CASE [Document_status]
            WHEN ''W'' THEN ''�͡�����͹��ѵ�''
            WHEN ''Y'' THEN ''�͡����͹��ѵ����º���������''
            WHEN ''C'' THEN ''�͡��ö١¡��ԡ''
            WHEN ''R'' THEN ''�͡��ö١����ʸ''
            ELSE [Document_status]
        END AS [Document_status],
        [Document_type_name],
        [UpdatedAt],
        [130_Using_money],
        [129_Amount_left],
        [31_Total_allowance],
        CAST(Amount' + CAST(@i AS NVARCHAR(2)) + ' AS NVARCHAR(50)) AS Amount,
        CAST(Detail' + CAST(@i AS NVARCHAR(2)) + '_frist AS NVARCHAR(50)) AS Detail,
        ''Detail' + CAST(@i AS NVARCHAR(2)) + ''' AS Detail_Column,
        [Total_amount],
        [Department],
        [Doc_type],
        [Status]
    FROM [TrainingSQL].[dbo].[API_Approved]
    UNION ALL
    ';
    SET @i = @i + 1;
END

-- �Ѵ����� UNION ALL ����ش�����͡
SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL'));

DECLARE @finalSql NVARCHAR(MAX);
SET @finalSql = '
    ;WITH CombinedResults AS (
        ' + @sql + '
    )
    SELECT 
       *
    FROM CombinedResults 
    WHERE Document_id = ''PCOEM-256602000027''
';

EXEC sp_executesql @sql;
