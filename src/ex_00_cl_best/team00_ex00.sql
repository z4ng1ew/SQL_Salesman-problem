-- ==========================================
-- ИДЕМПОТЕНТНЫЙ СКРИПТ (УЛУЧШЕННАЯ ВЕРСИЯ)
-- Можно запускать многократно
-- ==========================================

-- Удаляем таблицу если она уже существует
DROP TABLE IF EXISTS tsp CASCADE;

-- Создаём таблицу заново
CREATE TABLE tsp (
    point1 CHAR(1),
    point2 CHAR(1),
    cost   INT
);

-- Вставляем данные
INSERT INTO tsp VALUES
('a','b',10), ('b','a',10),
('a','c',15), ('c','a',15),
('a','d',20), ('d','a',20),
('b','c',35), ('c','b',35),
('b','d',25), ('d','b',25),
('c','d',30), ('d','c',30);

-- Основной запрос с массивами
WITH RECURSIVE tour AS (
    SELECT
        ARRAY['a']::varchar[]  AS path,
        'a'::CHAR(1)           AS last_point,
        0                      AS total_cost
    UNION ALL
    SELECT
        tour.path || ARRAY[tsp.point2]::varchar[],
        tsp.point2,
        tour.total_cost + tsp.cost
    FROM tour
    JOIN tsp
      ON tsp.point1 = tour.last_point
    WHERE
        NOT tsp.point2 = ANY(tour.path)
),
finished_tours AS (
    SELECT
        tour.total_cost + tsp.cost AS total_cost,
        tour.path || ARRAY['a']::varchar[] AS tour
    FROM tour
    JOIN tsp
      ON tsp.point1 = tour.last_point
     AND tsp.point2 = 'a'
    WHERE array_length(tour.path, 1) = (
        SELECT COUNT(DISTINCT point1) FROM tsp
    )
)
SELECT total_cost, tour
FROM finished_tours
WHERE total_cost = (SELECT MIN(total_cost) FROM finished_tours)
ORDER BY total_cost, tour;