SELECT Area.area_name AS area_name
FROM [Training].dbo.Area
LEFT JOIN [Training].dbo.restaurants ON Area.area_id = restaurants.area_id
WHERE restaurants.area_id IS NULL;


SELECT * FROM [Training].dbo.Area ;
SELECT * FROM [Training].dbo.restaurants ;