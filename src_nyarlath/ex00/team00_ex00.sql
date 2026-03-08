-- ==========================================
-- ИДЕМПОТЕНТНЫЙ СКРИПТ NYARLATH
-- Можно запускать многократно
-- ==========================================

-- Удаляем VIEW в правильном порядке
DROP VIEW IF EXISTS v_done_tour CASCADE;
DROP VIEW IF EXISTS v_tour CASCADE;

-- Удаляем таблицы (сначала с FK, потом главную)
DROP TABLE IF EXISTS nodes CASCADE;
DROP TABLE IF EXISTS cities CASCADE;

-- Создаём таблицу городов
CREATE TABLE cities (
    id bigint primary key,
    name varchar not null
);

INSERT INTO cities VALUES
(1, 'a'),
(2, 'b'),
(3, 'c'),
(4, 'd');

-- Создаём таблицу рёбер
CREATE TABLE nodes (
    id bigint primary key,
    point1 bigint not null,
    point2 bigint not null,
    constraint fk_order_point1 foreign key (point1) references cities(id),
    constraint fk_order_point2 foreign key (point2) references cities(id),
    cost numeric not null default 1
);

INSERT INTO nodes VALUES
(1, 1, 2, 10),
(2, 2, 1, 10),
(3, 2, 3, 35),
(4, 3, 2, 35),
(5, 3, 4, 30),
(6, 4, 3, 30),
(7, 1, 3, 15),
(8, 3, 1, 15),
(9, 1, 4, 20),
(10, 4, 1, 20),
(11, 2, 4, 25),
(12, 4, 2, 25);

-- Создаём VIEW для всех туров
CREATE VIEW v_tour AS (
    WITH RECURSIVE tour AS (
        SELECT CONCAT(c1.name, ', ', c2.name) AS name_tour,
            point1,
            point2,
            cost,
            cost AS summ,
            1 AS iter
        FROM nodes
            JOIN cities AS c1 ON nodes.point1 = c1.id
            JOIN cities AS c2 ON nodes.point2 = c2.id
        WHERE point1 = 1
        UNION ALL
        SELECT CONCAT(tour.name_tour, ', ', cities.name) AS name_tour,
            nodes.point1,
            nodes.point2,
            nodes.cost,
            tour.summ + nodes.cost AS summ,
            iter + 1
        FROM nodes
            JOIN tour ON nodes.point1 = tour.point2
            JOIN cities ON nodes.point2 = cities.id
        WHERE name_tour NOT LIKE '%' || cities.name || '%'
    )
    SELECT *
    FROM tour
);

-- Создаём VIEW для завершённых туров
CREATE VIEW v_done_tour AS (
    SELECT v_tour.summ + ns.cost AS total_cost,
        CONCAT('{', v_tour.name_tour, ', ', cities.name, '}') AS tour
    FROM v_tour
        JOIN (
            SELECT *
            FROM nodes
            WHERE point1 = 1
        ) AS ns ON v_tour.point2 = ns.point2
        JOIN cities ON ns.point1 = cities.id
    WHERE LENGTH (name_tour) = 10
);

-- Основной запрос
SELECT *
FROM v_done_tour
WHERE total_cost = (
        SELECT MIN(total_cost)
        FROM v_done_tour
    )
ORDER BY 1, 2;