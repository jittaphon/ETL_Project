/*SELECT 
 S2.staff_id AS staff_ID,
 S2.staff_name AS staff_name, 
 S1.staff_id AS manager_ID,
 S1.staff_name AS manager_name
FROM [Training].[dbo].Staff AS S1, [Training].[dbo].Staff as S2
WHERE S1.staff_id = S2.manager_id*/


/*SELECT 
 S2.staff_id as staff_ID,
 S2.staff_name as staff_name, 
 S1.staff_id as manager_ID,
 S1.staff_name as manager_name
FROM [Training].[dbo].Staff AS S1 
INNER JOIN [Training].[dbo].Staff AS S2 
ON S1.staff_id = S2.manager_id*/


SELECT 
    S2.staff_id AS employee_id,          /*เเนวคิด S1 = พนักงาน S2 = หัวหน้า*/
    S2.staff_name AS employee_name,
    S1.staff_id AS manager_id,
    S1.staff_name AS manager_name
FROM [Training].[dbo].Staff AS Ss1
INNER JOIN [Training].[dbo].Staff AS S2
ON S2.manager_id = S1.staff_id;

SELECT * FROM [Training].[dbo].Staff







