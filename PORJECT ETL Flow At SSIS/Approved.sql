-- ��С�ȵ��������Ѻ SQL Ẻ䴹��ԡ
DECLARE @sql NVARCHAR(MAX) = ''; 
DECLARE @i INT = 1;

-- �ѹ�Ѻ 2 ���ҧ SQL Ẻ䴹��ԡ����Ѻ���� Amount ��� Detail ��� loop
WHILE @i <= 10
BEGIN
    SET @sql = @sql + 
    'SELECT 
        [Business],
        [Type],
        [Doc_type],
        [Document_id],
        CASE [Document_status]
            WHEN ''W'' THEN ''�͡�����͹��ѵ�''
            WHEN ''Y'' THEN ''�͡����͹��ѵ����º���������''
            WHEN ''C'' THEN ''�͡��ö١¡��ԡ''
            WHEN ''R'' THEN ''�͡��ö١����ʸ''
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
-- ź UNION ALL ����ش����
SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL '));


-- �ѹ�Ѻ 1 ���� CTE ����Ѻ��èѴ�ӴѺ������㹵��ҧ��͹
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
WHERE Business = ''�Թ�����絻������'' 
    AND Type IN (''pettycash'') 
    AND Amount <> ''0.00''  
    AND Detail IN (''�������� outsource'', ''����Թ�ҧ/���ѡ'', ''��Ҹ��������������'', ''����Ѻ�ͧ'', ''������ʴԡ��'', ''����'')



';

-- �ѹ�Ѻ 3 ���� UNION ���ҧ �������� Type advance and allowance ���� prettycash ���稵͹��� loop ������
SET @sql = @sql+ '
	UNION ALL 
	SELECT
	[Business],
        [Type],
        [Doc_type],
        [Document_id],
        CASE [Document_status]
            WHEN ''W'' THEN ''�͡�����͹��ѵ�''
            WHEN ''Y'' THEN ''�͡����͹��ѵ����º���������''
            WHEN ''C'' THEN ''�͡��ö١¡��ԡ''
            WHEN ''R'' THEN ''�͡��ö١����ʸ''
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
		WHERE LatestData.Type IN (''allowance'', ''advance'') AND Business = ''�Թ�����絻������'' AND rn = 1 
';





-- �����ż� SQL ������ҧ���
INSERT INTO [TrainingSQL].[dbo].[API_Approved_Result2]
EXEC sp_executesql @sql;


