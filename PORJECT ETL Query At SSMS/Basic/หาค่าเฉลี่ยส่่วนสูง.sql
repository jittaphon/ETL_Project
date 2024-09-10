SELECT c.country_name, AVG(p.height) AS mean_height
FROM [TrainingSQL].dbo.player p
LEFT JOIN [TrainingSQL].dbo.country c ON p.country_id = c.country_id
GROUP BY c.country_name;

SELECT *
FROM [TrainingSQL].dbo.player p
LEFT JOIN [TrainingSQL].dbo.country c ON p.country_id = c.country_id


WITH MaxTotalHeight AS (          /*�� WITH ����� �������С����� Table */
    SELECT 
        MAX(total_height) AS max_total_height               /*Col ����ͧ���*/
    FROM (                                                  /* Table �����ҡ�֧*/
        SELECT 
            SUM(p.height) AS total_height
        FROM 
            [TrainingSQL].dbo.player AS p
        LEFT JOIN 
            [TrainingSQL].dbo.country AS c 
        ON 
            p.country_id = c.country_id
        GROUP BY 
            c.country_name
    ) AS subquery
)

SELECT c.country_name , SUM(height) AS total_height
FROM [TrainingSQL].dbo.player AS p
LEFT JOIN [TrainingSQL].dbo.country AS c ON p.country_id = c.country_id  /*���͡�����ҡ Filtter ������� �ѡ�ӷӧҹ�����Ѻ�����㹡���� Aggregate Function ��� SUM, AVG, COUNT, MIN ��� MAX*/
GROUP BY c.country_name
HAVING SUM(p.height) = (        /*��Ƿ�������� Havig*/
SELECT max_total_height FROM MaxTotalHeight)




