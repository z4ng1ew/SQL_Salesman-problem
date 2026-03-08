CREATE TABLE tsp (
    point1 CHAR(1),
    point2 CHAR(1),
    cost   INT
);

INSERT INTO tsp VALUES
('a','b',10), ('b','a',10),
('a','c',15), ('c','a',15),
('a','d',20), ('d','a',20),
('b','c',35), ('c','b',35),
('b','d',25), ('d','b',25),
('c','d',30), ('d','c',30);

WITH RECURSIVE tour AS (
    SELECT
        'a'::TEXT       AS path,
        'a'::CHAR(1)    AS last_point,
        0               AS total_cost,
        1               AS visited
    UNION ALL
    SELECT
        tour.path || ',' || tsp.point2,
        tsp.point2,
        tour.total_cost + tsp.cost,
        tour.visited + 1
    FROM tour
    JOIN tsp
      ON tsp.point1 = tour.last_point
    WHERE
        tsp.point2 NOT IN (
            SELECT unnest(string_to_array(tour.path, ','))
        )
),
finished_tours AS (
    SELECT
        tour.total_cost + tsp.cost AS total_cost,
        '{' || tour.path || ',a}'  AS tour
    FROM tour
    JOIN tsp
      ON tsp.point1 = tour.last_point
     AND tsp.point2 = 'a'
    WHERE tour.visited = (
        SELECT COUNT(DISTINCT point1) FROM tsp
    )
)
SELECT total_cost, tour
FROM finished_tours
WHERE total_cost = (SELECT MIN(total_cost) FROM finished_tours)
ORDER BY total_cost, tour;


