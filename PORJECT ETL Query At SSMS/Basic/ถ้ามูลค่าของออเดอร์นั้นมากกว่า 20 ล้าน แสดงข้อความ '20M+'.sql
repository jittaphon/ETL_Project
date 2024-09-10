SELECT 
    amount,
    CASE
        WHEN amount > 2000000 THEN '20M+'
        ELSE '<20M'
    END AS type
FROM OrderSS;

SELECT * FROM OrderSS;