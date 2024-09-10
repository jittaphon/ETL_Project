SELECT c.country_name, AVG(p.height) AS mean_height
FROM [TrainingSQL].dbo.player p
LEFT JOIN [TrainingSQL].dbo.country c ON p.country_id = c.country_id
GROUP BY c.country_name;

SELECT *
FROM [TrainingSQL].dbo.player p
LEFT JOIN [TrainingSQL].dbo.country c ON p.country_id = c.country_id


WITH MaxTotalHeight AS (          /*ทำ WITH เเล้ว ทั้งหมดจะกลายเป็น Table */
    SELECT 
        MAX(total_height) AS max_total_height               /*Col ที่ต้องการ*/
    FROM (                                                  /* Table ที่อยากดึง*/
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
LEFT JOIN [TrainingSQL].dbo.country AS c ON p.country_id = c.country_id  /*เเค่บอกว่าอยาก Filtter อะไรเฉยๆ มักจำทำงานร่วมกับคำสั่งในกลุ่ม Aggregate Function คือ SUM, AVG, COUNT, MIN และ MAX*/
GROUP BY c.country_name
HAVING SUM(p.height) = (        /*ตัวที่จะเอามา Havig*/
SELECT max_total_height FROM MaxTotalHeight)




