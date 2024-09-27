WITH check_in_status_count AS (
    SELECT COUNT(*) AS count_check_in_status
    FROM [SO].[dbo].[API_visit_clc_aug]
    WHERE check_in_status = 'เข้าพบแล้ว'
),
cvm_id_count AS (
    SELECT COUNT(*) AS count_cvm_id 
    FROM [SO].[dbo].[API_visit_clc_aug]
    WHERE check_in_status = 'เข้าพบแล้ว' AND cvm_id <> '[]'
)
SELECT 
    c.count_cvm_id,
    s.count_check_in_status,
    (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 AS percentage_cvm_id,
    CASE 
        WHEN (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 < 80 THEN 'Red'
        WHEN (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 BETWEEN 80 AND 89 THEN 'Yellow'
        WHEN (CAST(c.count_cvm_id AS FLOAT) / s.count_check_in_status) * 100 >= 90 THEN 'Green'
    END AS status_color
FROM cvm_id_count c, check_in_status_count s;
