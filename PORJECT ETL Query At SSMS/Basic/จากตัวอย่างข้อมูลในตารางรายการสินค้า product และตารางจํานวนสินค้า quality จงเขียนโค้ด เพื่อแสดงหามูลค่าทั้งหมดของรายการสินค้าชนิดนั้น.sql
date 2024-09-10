/*INSERT INTO Products (pr_id, pr_name, price, qt_id) VALUES
('PR-2028001', 'แชมพู ตรารียูเนียน', 200.75, 'QT-2034'),
('PR-2346056', 'ยาสีฟัน ตราคอลมานะ', 150.50, 'qT-0058'),
('PR-2230619', 'น้ําเปล่า ตรานรสิงห์', 7.00, 'Qt-3046'),
('PR-0251273', 'ยาแก้ไอ ตราเสือสิบตัว', 23.25, 'qt-1269');*/


/*INSERT INTO Quality (qt_id,quality) VALUES 
('QT-0058',3),
('QT-2034',2),
('QT-1269',1),
('QT-5058',4),
('QT-3046',1)*/

SELECT
P.pr_id,
P.pr_name, 
UPPER(P.qt_id) AS qt_id, 
cast(P.price*Q.quality as decimal(11, 2)) AS total_price /*แปลงเป็นชนิด decimal(11, 2) คือ Length 11, แสดงทศนิยม 2 */
FROM [TrainingSQL].dbo.Product AS P 
LEFT JOIN 
[TrainingSQL].dbo.Quality AS Q 
ON UPPER(P.qt_id) = Q.qt_id

SELECT * FROM Product
SELECT * FROM Quality
