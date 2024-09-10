SELECT year,month,sale_amount , rn                 /*Table 1 */
FROM ( SELECT  T.*,  rank() OVER (PARTITION BY year ORDER BY sale_amount ASC) AS rn  FROM [TrainingSQL].dbo.Sales AS T) AS subquery
WHERE rn = 1

SELECT year , SUM(sale_amount) FROM [TrainingSQL].dbo.Sales group by year HAVING SUM(sale_amount) < 20000000    /*Table 2*/


/*-----------------RANK AND JOIN*/
SELECT TMS.year,TMS.month,TMS.sale_amount , TMS.rank                
FROM ( 
      SELECT  T.*,  rank() OVER (PARTITION BY year ORDER BY sale_amount ASC) AS rank  
	  FROM [TrainingSQL].dbo.Sales AS T)
AS TMS
INNER JOIN (
      SELECT year 
	  FROM [TrainingSQL].dbo.Sales 
	  GROUP BY year  
	  HAVING SUM(sale_amount) < 20000000  
) AS  yearly_sales ON  TMS.year = yearly_sales.year 
WHERE rank = 1



/*-----------------RANK AND JOIN*/

SELECT T.year, T.month, T.sale_amount
FROM [TrainingSQL].dbo.Sales AS T /*คำสั้งหลัก*/
WHERE T.sale_amount = (
    SELECT MIN(sale_amount)
    FROM [TrainingSQL].dbo.Sales
    WHERE year = T.year
) AND  
T.year IN (
    SELECT year
    FROM [TrainingSQL].dbo.Sales
    GROUP BY year
    HAVING SUM(sale_amount) < 20000000
);









SELECT T.year, T.month, T.sale_amount
FROM [TrainingSQL].dbo.Sales AS T
WHERE T.sale_amount = (
    SELECT MIN(sale_amount)
    FROM [TrainingSQL].dbo.Sales
    WHERE year = T.year
)
AND T.year IN (
    SELECT year
    FROM [TrainingSQL].dbo.Sales
    GROUP BY year
    HAVING SUM(sale_amount) < 20000000
);



    








/*คำสั่ง SQL ที่คุณใช้จะให้ผลลัพธ์เป็นค่าต่ำสุดของ sale_amount ในแต่ละปีและเดือน โดยใช้ฟังก์ชัน RANK() เพื่อจัดลำดับ sale_amount จากน้อยไปมาก (ORDER BY sale_amount ASC) และเลือกเฉพาะแถวที่มีอันดับ (rn) เท่ากับ 1 ซึ่งเป็นค่าต่ำสุดในแต่ละกลุ่มปีและเดือน.

คำสั่งนี้ทำงานคล้ายกับการใช้ MIN() แต่มีความยืดหยุ่นมากกว่าเพราะคุณสามารถเลือกแถวที่มีอันดับอื่น ๆ ได้ด้วยถ้าต้องการ เช่น อันดับที่ 2 หรือ 3 เป็นต้น*/

/*
หมายความว่า 
1.เราจัดอันดับ(rank())โดย จัดกลุ่ม ตามปี year เเละเรียงข้อมูลในเเต่ละปี ASC น้อยไปมาก / DESC มากไปน้อย เเล้วใส่อันกับให้มัน เเล้ว fitter where เลือกจาก AS rn 
1.1 PARTITION BY year: คำสั่งนี้จะจัดกลุ่มข้อมูลตามปี (year) ซึ่งหมายความว่าข้อมูลจะถูกแบ่งออกเป็นกลุ่มย่อยตามปี
1.2 ORDER BY sale_amount ASC: คำสั่งนี้จะจัดลำดับข้อมูลภายในแต่ละกลุ่มปีตาม sale_amount จากน้อยไปมาก 


ROW_NUMBER(): ใช้เมื่อต้องการหมายเลขลำดับที่ไม่ซ้ำกันสำหรับแต่ละแถว
RANK(): ใช้เมื่อต้องการหมายเลขลำดับที่จัดการกับค่าที่ซ้ำกัน โดยให้หมายเลขลำดับเดียวกันกับแถวที่มีค่าซ้ำกัน

ROW_NUMBER()
ปี 1
800 1
800 2

RANK()
ปี1
800 1
800 1


*/












