SELECT *
FROM [TrainingSQL].dbo.PRESIDENT   
WHERE YRS_SERV = (
    SELECT MIN(YRS_SERV)                        /*Return ROW มาให้*/
    FROM [TrainingSQL].dbo.PRESIDENT            /*หาเเบบต่ำสุด โดยใช้ MIN เเละใช้ใน sub query เพราะใช้รวมกับ * ไม่ได้*/
); 

SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY YRS_SERV ASC) AS Rank
    FROM [TrainingSQL].dbo.PRESIDENT
) AS RankedPresidents  


/*ลองใช้ WITH = subquery เเบบเเยก file */
WITH MinYears AS (
    SELECT MIN(YRS_SERV) AS min_yrs_serv
    FROM [TrainingSQL].dbo.PRESIDENT
)

SELECT *
FROM [TrainingSQL].dbo.PRESIDENT
WHERE YRS_SERV = (SELECT min_yrs_serv FROM MinYears)




/*aggregate function  ต้องการการรวมกลุ่ม (GROUP BY) หรือการใช้ใน SUBQUERY */

