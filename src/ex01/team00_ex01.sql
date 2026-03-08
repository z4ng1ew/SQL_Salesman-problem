WITH RECURSIVE paths AS (
    SELECT
        point2, cost,
        ARRAY[point1, point2]::varchar[] AS tour,
        cost AS total_cost
    FROM tsp WHERE point1 = 'a'

    UNION ALL

    SELECT
        t.point2, t.cost,
        p.tour || ARRAY[t.point2]::varchar[],
        p.total_cost + t.cost
    FROM paths p
    JOIN tsp t
      ON p.point2 = t.point1
    WHERE
        NOT t.point2 = ANY(p.tour)
        AND array_length(p.tour, 1) < (
            SELECT COUNT(DISTINCT point1) FROM tsp
        )
),
full_tours AS (
    SELECT
        p.total_cost + t.cost AS total_cost,
        p.tour || ARRAY['a']::varchar[] AS tour
    FROM paths p
    JOIN tsp t ON p.point2 = t.point1
    WHERE t.point2 = 'a'
        AND array_length(p.tour, 1) = (
            SELECT COUNT(DISTINCT point1) FROM tsp)),
filtered AS (
    SELECT *
    FROM full_tours
    WHERE total_cost = (SELECT MIN(total_cost) FROM full_tours)
       OR total_cost = (SELECT MAX(total_cost) FROM full_tours)
)
SELECT
    total_cost,tour
FROM filtered
ORDER BY total_cost, tour;
