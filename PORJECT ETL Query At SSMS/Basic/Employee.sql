

/*-------------------ถ้า Basic เลย ------------------*/
SELECT 
    patient_id, 
    CONCAT(first_name, ' ', last_name) AS full_name, 
    gender, 
    birth_date, 
    city, 
    province_id, 
    allergies, 
    height, 
    weight
FROM 
       [TrainingSQL].dbo.patients
WHERE 
      /*first_name LIKE '__r%'*/
      SUBSTRING(first_name, 3, 1) = 'r' 
     /*%r% มีส่วนประกอบ r อยู่ตามเเหน่งไหนก็ได้* r% ข้อมูลที่ขึ้นต้น r/*/

	
	
	/*ดังนั้น คำสั่งนี้จะค้นหาชื่อที่มีอักขระสองตัวแรกเป็นอะไรก็ได้ ตามด้วยอักขระใด ๆ หรือไม่มีอักขระเลย และมีตัวอักษร ‘r’ อยู่ในชื่อ*/
    /*AND gender = 'F' 
    AND MONTH(birth_date) IN (2, 5, 12)  
    AND weight BETWEEN 60 AND 80  
    AND patient_id % 2 = 0 
    AND city = 'Kingston';  */
/*--------------------------------------------*/


SELECT 
    patient_id, 
    CONCAT(first_name, ' ', last_name) AS full_name, 
    gender, 
    birth_date, 
    city, 
    province_id, 
    allergies, 
    height, 
    weight
FROM 
    [TrainingSQL].dbo.patients
