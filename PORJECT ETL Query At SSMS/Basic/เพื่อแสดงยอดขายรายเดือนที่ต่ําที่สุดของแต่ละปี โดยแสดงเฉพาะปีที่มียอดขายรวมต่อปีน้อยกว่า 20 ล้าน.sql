SELECT year,month,sale_amount , rn                 /*Table 1 */
FROM ( SELECT  T.*,  rank() OVER (PARTITION BY year ORDER BY sale_amount ASC) AS rn  FROM [TrainingSQL].dbo.Sales AS T) AS subquery
WHERE rn = 1

SELECT year , SUM(sale_amount) FROM [TrainingSQL].dbo.Sales group by year HAVING SUM(sale_amount) < 20000000    /*Table 2*/


/*-----------------RANK AND JOIN*/
SELECT TMS.year,TMS.month,TMS.sale_amount , TMS.rank                
FROM ( 
      SELECT  T.*,  rank() OVER (PARTITION BY year ORDER BY sale_amount ASC) AS rank  
	  FROM [TrainingSQL].dbo.Sales AS T)
AS TMS
INNER JOIN (
      SELECT year 
	  FROM [TrainingSQL].dbo.Sales 
	  GROUP BY year  
	  HAVING SUM(sale_amount) < 20000000  
) AS  yearly_sales ON  TMS.year = yearly_sales.year 
WHERE rank = 1



/*-----------------RANK AND JOIN*/

SELECT T.year, T.month, T.sale_amount
FROM [TrainingSQL].dbo.Sales AS T /*�������ѡ*/
WHERE T.sale_amount = (
    SELECT MIN(sale_amount)
    FROM [TrainingSQL].dbo.Sales
    WHERE year = T.year
) AND  
T.year IN (
    SELECT year
    FROM [TrainingSQL].dbo.Sales
    GROUP BY year
    HAVING SUM(sale_amount) < 20000000
);









SELECT T.year, T.month, T.sale_amount
FROM [TrainingSQL].dbo.Sales AS T
WHERE T.sale_amount = (
    SELECT MIN(sale_amount)
    FROM [TrainingSQL].dbo.Sales
    WHERE year = T.year
)
AND T.year IN (
    SELECT year
    FROM [TrainingSQL].dbo.Sales
    GROUP BY year
    HAVING SUM(sale_amount) < 20000000
);



    








/*����� SQL ���س��������Ѿ���繤�ҵ���ش�ͧ sale_amount ����л������͹ ����ѧ��ѹ RANK() ���ͨѴ�ӴѺ sale_amount �ҡ������ҡ (ORDER BY sale_amount ASC) ������͡੾���Ƿ�����ѹ�Ѻ (rn) ��ҡѺ 1 ����繤�ҵ���ش����С�����������͹.

����觹��ӧҹ����¡Ѻ����� MIN() ���դ����״�����ҡ�������Фس����ö���͡�Ƿ�����ѹ�Ѻ��� � ����¶�ҵ�ͧ��� �� �ѹ�Ѻ��� 2 ���� 3 �繵�*/

/*
���¤������ 
1.��ҨѴ�ѹ�Ѻ(rank())�� �Ѵ����� ����� year �������§�����������л� ASC ������ҡ / DESC �ҡ仹��� ���������ѹ�Ѻ����ѹ ����� fitter where ���͡�ҡ AS rn 
1.1 PARTITION BY year: ����觹��ШѴ����������ŵ���� (year) ������¤�����Ң����Ũж١���͡�繡�������µ����
1.2 ORDER BY sale_amount ASC: ����觹��ШѴ�ӴѺ�������������С�����յ�� sale_amount �ҡ������ҡ 


ROW_NUMBER(): ������͵�ͧ��������Ţ�ӴѺ�������ӡѹ����Ѻ������
RANK(): ������͵�ͧ��������Ţ�ӴѺ���Ѵ��áѺ��ҷ���ӡѹ ����������Ţ�ӴѺ���ǡѹ�Ѻ�Ƿ���դ�ҫ�ӡѹ

ROW_NUMBER()
�� 1
800 1
800 2

RANK()
��1
800 1
800 1


*/












