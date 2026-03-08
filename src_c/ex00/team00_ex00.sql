
DROP TABLE IF EXISTS tsp CASCADE;

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



WITH RECURSIVE building_routes AS (

    SELECT
        ARRAY['a']::varchar[]  AS visited_cities,
        'a'::CHAR(1)           AS current_city,
        0                      AS accumulated_cost
    
    UNION ALL
    

    SELECT
        routes.visited_cities || ARRAY[edges.point2]::varchar[],
        edges.point2,
        routes.accumulated_cost + edges.cost
    FROM building_routes AS routes
    JOIN tsp AS edges ON edges.point1 = routes.current_city
    WHERE NOT edges.point2 = ANY(routes.visited_cities)
),



complete_cycles AS (
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
)



SELECT total_cost, tour
FROM complete_cycles
WHERE total_cost = (SELECT MIN(total_cost) FROM complete_cycles)
ORDER BY total_cost, tour;