SELECT *
FROM [TrainingSQL].dbo.PRESIDENT   
WHERE YRS_SERV = (
    SELECT MIN(YRS_SERV)                        /*Return ROW �����*/
    FROM [TrainingSQL].dbo.PRESIDENT            /*���຺����ش ���� MIN ������� sub query ����������Ѻ * �����*/
); 

SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY YRS_SERV ASC) AS Rank
    FROM [TrainingSQL].dbo.PRESIDENT
) AS RankedPresidents  


/*�ͧ�� WITH = subquery �຺��¡ file */
WITH MinYears AS (
    SELECT MIN(YRS_SERV) AS min_yrs_serv
    FROM [TrainingSQL].dbo.PRESIDENT
)

SELECT *
FROM [TrainingSQL].dbo.PRESIDENT
WHERE YRS_SERV = (SELECT min_yrs_serv FROM MinYears)




/*aggregate function  ��ͧ��á���������� (GROUP BY) ���͡����� SUBQUERY */

