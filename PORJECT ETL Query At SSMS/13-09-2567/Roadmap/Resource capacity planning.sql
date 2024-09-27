-- ดึงข้อมูลจากเดือนก่อนหน้า
SELECT 
    [total_people],
    CASE 
        WHEN [total_people] > 3050 THEN 'red'
        WHEN [total_people] BETWEEN 3001 AND 3050 THEN 'yellow'
        WHEN [total_people] < 3000 THEN 'green'
    END AS status_color
FROM 
    [HR].[dbo].[API_EmployeePlan_ActualManPower_INET]
WHERE 
    [date] >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    AND [date] < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
