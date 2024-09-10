-- ตั้งให้วันเสาร์เป็นวันแรกของสัปดาห์
SET DATEFIRST 6;

-- คำนวณวันที่แรกของสัปดาห์
DECLARE @FirstDayOfWeek DATE;

-- หาวันที่แรกของสัปดาห์จากวันที่ปัจจุบัน
SET @FirstDayOfWeek = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), GETDATE()); /*เอาวันเเรกของสัปดาห์ - วันที่ปัจจุบัน*/
SELECT @FirstDayOfWeek AS FirstDayOfWeek;
-- แสดงชื่อวันแรกของสัปดาห์
SELECT DATENAME(WEEKDAY, @FirstDayOfWeek) AS FirstDayOfWeekName;

SELECT  DATEPART(WEEKDAY, GETDATE())
