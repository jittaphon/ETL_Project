SELECT * FROM MOCK1
SELECT * FROM MOCK2

SELECT 
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    COALESCE(NULL,'ไม่ระบุ')AS Amount_Left,
    NULL AS CITY,
    Status,
    NULL AS Postcal,
    Detail1 AS Phone,
    'MOCK1' AS Source_Table  -- คอลัมน์ที่ระบุแหล่งที่มาของข้อมูล
FROM 
    MOCK1

UNION ALL

SELECT 
    Doc_id,
    Date_approve,
    Status_approve,
    Department,
    Amount_Left,
    CITY,
    Status,
    Postcal,
    PHONE,
    'MOCK2' AS Source_Table  -- คอลัมน์ที่ระบุแหล่งที่มาของข้อมูล
FROM 
    MOCK2;
