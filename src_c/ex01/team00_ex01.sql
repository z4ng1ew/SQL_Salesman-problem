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
    JOIN tsp ON tsp.point1 = tour.last_point
    WHERE NOT tsp.point2 = ANY(tour.path)
),
finished_tours AS (
    SELECT
        tour.total_cost + tsp.cost AS total_cost,
        '{' || array_to_string(tour.path || ARRAY['a']::varchar[], ',') || '}' AS tour
    FROM tour
    JOIN tsp 
      ON tsp.point1 = tour.last_point 
     AND tsp.point2 = 'a'
    WHERE array_length(tour.path, 1) = (
        SELECT COUNT(DISTINCT point1) FROM tsp
    )
),
filtered AS (
    SELECT total_cost, tour
    FROM finished_tours
    WHERE total_cost = (SELECT MIN(total_cost) FROM finished_tours)
       OR total_cost = (SELECT MAX(total_cost) FROM finished_tours)
)
SELECT total_cost, tour
FROM filtered
ORDER BY total_cost, tour;