-- �������ѹ��������ѹ�á�ͧ�ѻ����
SET DATEFIRST 6;

-- �ӹǳ�ѹ����á�ͧ�ѻ����
DECLARE @FirstDayOfWeek DATE;

-- ���ѹ����á�ͧ�ѻ����ҡ�ѹ���Ѩ�غѹ
SET @FirstDayOfWeek = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE()); /*����ѹ��á�ͧ�ѻ���� - �ѹ���Ѩ�غѹ*/
SELECT @FirstDayOfWeek AS FirstDayOfWeek;
-- �ʴ������ѹ�á�ͧ�ѻ����
SELECT DATENAME(WEEKDAY, @FirstDayOfWeek) AS FirstDayOfWeekName;

SELECT  DATEPART(WEEKDAY, GETDATE())
