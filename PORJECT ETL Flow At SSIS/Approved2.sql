WITH LatestData AS(
SELECT
 *,
 ROW_NUMBER() OVER (PARTITION BY Document_id ORDER BY UpdatedAt DESC) AS rn --rank dense_rank
FROM [TrainingSQL].[dbo].[API_Approved] )
SELECT 
  Business,
  LD.Type,
  [Document_id],
  --Document_status,
  CASE WHEN [Document_status] = 'W'THEN N'เอกสารรอการอนุมัติ'
    WHEN [Document_status] = 'Y' THEN N'เอกสารอนุมัติเรียบร้อย'
    WHEN [Document_status] = 'C' THEN N'เอกสารถูกยกเลิก'
    WHEN [Document_status] = 'R' THEN N'เอกสารถูกปฏิเสธ'
  END AS [Document_status],
  Document_type_name,
  [UpdatedAt],
  [127_Total_advance_payment],
  [130_Using_money],
  [129_Amount_left],
  LDtemp.amount,
  [Total_amount],
  [Department],
  [Doc_type],
  LDtemp.detail
FROM LatestData LD
CROSS APPLY (
    VALUES 
       (LD.Amount1, LD.Detail1_frist),
       (LD.Amount2, LD.Detail2_frist),
       (LD.Amount3, LD.Detail3_frist),
       (LD.Amount4, LD.Detail4_frist),
       (LD.Amount5, LD.Detail5_frist),
       (LD.Amount6, LD.Detail6_frist),
       (LD.Amount7, LD.Detail7_frist),
       (LD.Amount8, LD.Detail8_frist),
       (LD.Amount9, LD.Detail9_frist),
       (LD.Amount10, LD.Detail10_frist)
) AS LDtemp(amount, detail)
WHERE LD.Type IN ('pettycash') AND LDtemp.amount <> 0 /*AND Document_status NOT in ('C','R')*/ AND Business = N'อินเทอร์เน็ตประเทศไทย' AND rn = 1
AND LDtemp.detail IN (N'ค่าใช้จ่าย outsource', N'ค่าเดินทาง/ที่พัก', N'ค่าธรรมเนียมและภาษี', N'ค่ารับรอง', N'ค่าสวัสดิการ', N'อื่นๆ') 
UNION ALL
SELECT  Business,
  LD2.Type,
  [Document_id],
  --Document_status,
  CASE WHEN [Document_status] = 'W'THEN N'เอกสารรอการอนุมัติ'
    WHEN [Document_status] = 'Y' THEN N'เอกสารอนุมัติเรียบร้อย'
    WHEN [Document_status] = 'C' THEN N'เอกสารถูกยกเลิก'
    WHEN [Document_status] = 'R' THEN N'เอกสารถูกปฏิเสธ'
  END AS [Document_status],
  Document_type_name,
  [UpdatedAt],
  [127_Total_advance_payment],
  [130_Using_money],
  [129_Amount_left],
  NULL AS amount,
  [Total_amount],
  [Department],
  [Doc_type],
  NULL AS detail
FROM LatestData LD2
WHERE LD2.Type IN ('allowance', 'advance') AND Business = N'อินเทอร์เน็ตประเทศไทย' AND rn = 1 /*AND Document_status NOT in ('C','R')*/

