 /*�µѴ�����ŷ����ҡѹ�͡���������� 1 ���*/


SELECT name, country_name
FROM (
    SELECT customer_name AS name, country_name
    FROM [TrainingSQL].dbo.customer
    WHERE country_name = 'Norway'

    UNION 

    SELECT supplier_name AS name, country_name
    FROM [TrainingSQL].dbo.supplier
    WHERE country_name = 'Norway'
) AS combined;
  
SELECT S.supplier_name ,S.country_name FROM [TrainingSQL].dbo.supplier AS S 
LEFT JOIN [TrainingSQL].dbo.customer AS  C 
ON S.supplier_name = C.customer_name	
GROUP BY S.supplier_name ,S.country_name HAVING S.country_name = 'Norway'

  
SELECT * FROM [TrainingSQL].dbo.supplier AS S 
LEFT JOIN [TrainingSQL].dbo.customer AS  C 
ON S.supplier_name = C.customer_name  	

/*JOIN �ѹ ����ҵ��ҧ��� COL , ROW �������ѹ����ѹ������繵��ҧ��ѡ*/

/*
UNION �����ҵ�͡ѹ���
*/

