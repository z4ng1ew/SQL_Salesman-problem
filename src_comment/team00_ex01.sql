-- ==========================================
-- ЗАДАЧА КОММИВОЯЖЁРА - OPPOSITE TSP
-- Вывод MIN и MAX маршрутов
-- ==========================================

WITH RECURSIVE building_routes AS (
    -- База рекурсии: начинаем путь с города 'a'
    SELECT
        ARRAY['a']::varchar[]  AS visited_cities,
        'a'::CHAR(1)           AS current_city,
        0                      AS accumulated_cost
    
    UNION ALL
    
    -- Рекурсивный шаг: добавляем непосещённые города
    SELECT
        routes.visited_cities || ARRAY[edges.point2]::varchar[],
        edges.point2,
        routes.accumulated_cost + edges.cost
    FROM building_routes AS routes
    JOIN tsp AS edges ON edges.point1 = routes.current_city
    WHERE NOT edges.point2 = ANY(routes.visited_cities)
),

complete_cycles AS (
    -- Завершаем маршруты возвратом в начальную точку 'a'
    SELECT
        routes.accumulated_cost + return_edge.cost AS total_cost,
        '{' || array_to_string(routes.visited_cities || ARRAY['a']::varchar[], ',') || '}' AS tour
    FROM building_routes AS routes
    JOIN tsp AS return_edge 
      ON return_edge.point1 = routes.current_city 
     AND return_edge.point2 = 'a'
    WHERE array_length(routes.visited_cities, 1) = (
        SELECT COUNT(DISTINCT point1) FROM tsp
    )
),

min_and_max_routes AS (
    -- Отбираем маршруты с минимальной и максимальной стоимостью
    SELECT total_cost, tour
    FROM complete_cycles
    WHERE total_cost = (SELECT MIN(total_cost) FROM complete_cycles)
       OR total_cost = (SELECT MAX(total_cost) FROM complete_cycles)
)

SELECT total_cost, tour
FROM min_and_max_routes
ORDER BY total_cost, tour;














