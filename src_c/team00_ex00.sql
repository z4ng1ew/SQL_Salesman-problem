-- ==========================================
-- TEAM00 Exercise 00: Classical TSP
-- Идемпотентный скрипт
-- ==========================================

-- Удаляем таблицу если существует
DROP TABLE IF EXISTS tsp CASCADE;

-- Создаём таблицу графа
CREATE TABLE tsp (
    point1 CHAR(1),
    point2 CHAR(1),
    cost   INT
);

-- Заполняем данными (все рёбра двусторонние)
INSERT INTO tsp VALUES
-- A ↔ B = 10
('a','b',10), ('b','a',10),
-- A ↔ C = 15  
('a','c',15), ('c','a',15),
-- A ↔ D = 20
('a','d',20), ('d','a',20),
-- B ↔ C = 35
('b','c',35), ('c','b',35),
-- B ↔ D = 25
('b','d',25), ('d','b',25),
-- C ↔ D = 30
('c','d',30), ('d','c',30);

-- Рекурсивный запрос для поиска туров
WITH RECURSIVE tour AS (
    -- База рекурсии: начинаем с города 'a'
    SELECT
        ARRAY['a']::varchar[]  AS path,
        'a'::CHAR(1)           AS last_point,
        0                      AS total_cost
    
    UNION ALL
    
    -- Рекурсивный шаг: добавляем непосещённые города
    SELECT
        tour.path || ARRAY[tsp.point2]::varchar[],
        tsp.point2,
        tour.total_cost + tsp.cost
    FROM tour
    JOIN tsp ON tsp.point1 = tour.last_point
    WHERE NOT tsp.point2 = ANY(tour.path)
),
finished_tours AS (
    -- Завершаем туры возвратом в 'a'
    SELECT
        tour.total_cost + tsp.cost AS total_cost,
        tour.path || ARRAY['a']::varchar[] AS tour
    FROM tour
    JOIN tsp ON tsp.point1 = tour.last_point 
            AND tsp.point2 = 'a'
    WHERE array_length(tour.path, 1) = (
        SELECT COUNT(DISTINCT point1) FROM tsp
    )
)
-- Выбираем только туры с минимальной стоимостью
SELECT total_cost, tour
FROM finished_tours
WHERE total_cost = (SELECT MIN(total_cost) FROM finished_tours)
ORDER BY total_cost, tour;