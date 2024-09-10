-- ใช้ INNER JOIN เพื่อแสดงแถวที่มีการจับคู่ในทั้งสองตาราง
SELECT  
    S.staff_id,
    S.staff_name, 
    M.manager_name

FROM  [Training].dbo.Staff AS S INNER JOIN  [Training].dbo.Manager AS M ON  S.manager_id = M.manager_id;

-- ใช้ LEFT JOIN กับเงื่อนไข WHERE เพื่อกรองแถวที่ไม่มีการจับคู่
SELECT 
    S.staff_id,
    S.staff_name, 
    M.manager_name
FROM  [Training].dbo.Staff AS S LEFT JOIN  [Training].dbo.Manager AS M ON  S.manager_id = M.manager_id
WHERE  M.manager_id IS NOT NULL;

/*ถ้าอยากดูค่า NUll ด้วยใช้ตัวนี้ LEFT

