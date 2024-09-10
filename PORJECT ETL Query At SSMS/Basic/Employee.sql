

/*-------------------��� Basic ��� ------------------*/
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
     /*%r% ����ǹ��Сͺ r ��������˹��˹����* r% �����ŷ���鹵� r/*/

	
	
	/*�ѧ��� ����觹��Ф��Ҫ��ͷ�����ѡ����ͧ����á�����á��� ��������ѡ���� � ����������ѡ������ ����յ���ѡ�� �r� ����㹪���*/
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
