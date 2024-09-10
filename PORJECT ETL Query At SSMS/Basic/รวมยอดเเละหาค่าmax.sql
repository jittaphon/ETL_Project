
SELECT date, total_product
FROM (
    SELECT date, SUM(number_of_product) AS total_product  /*��  sub ��������ʹ������������º��º���*/
    FROM ProductLine
    GROUP BY date
) AS subquery
WHERE total_product = (
    SELECT MAX(total_product)         /*�� where sub ���������͹䢷���ͧ��ä���٧�ش */
    FROM (
        SELECT SUM(number_of_product) AS total_product
        FROM ProductLine
        GROUP BY date
    ) AS max_of_number_product
);


SELECT date, SUM(number_of_product) AS total_product
FROM ProductLine
GROUP BY date
HAVING SUM(number_of_product) = (
    SELECT MAX(total_product)
    FROM (
        SELECT SUM(number_of_product) AS total_product
        FROM ProductLine
        GROUP BY date
    ) AS max_of_number_product
);



SELECT COUNT(*), date , SUM(number_of_product) FROM ProductLine
GROUP BY date
