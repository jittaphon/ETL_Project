-- �� INNER JOIN �����ʴ��Ƿ���ա�èѺ���㹷���ͧ���ҧ
SELECT  
    S.staff_id,
    S.staff_name, 
    M.manager_name

FROM  [Training].dbo.Staff AS S INNER JOIN  [Training].dbo.Manager AS M ON  S.manager_id = M.manager_id;

-- �� LEFT JOIN �Ѻ���͹� WHERE ���͡�ͧ�Ƿ������ա�èѺ���
SELECT 
    S.staff_id,
    S.staff_name, 
    M.manager_name
FROM  [Training].dbo.Staff AS S LEFT JOIN  [Training].dbo.Manager AS M ON  S.manager_id = M.manager_id
WHERE  M.manager_id IS NOT NULL;

/*�����ҡ�٤�� NUll �������ǹ�� LEFT

