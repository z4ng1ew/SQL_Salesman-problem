SELECT 
    'Пример 1: Создание массивов' AS описание;

SELECT ARRAY[1, 2, 3, 4, 5] AS массив_чисел;

SELECT ARRAY['яблоко', 'банан', 'апельсин'] AS массив_фруктов;

SELECT ARRAY['a'] AS один_элемент;

SELECT ARRAY[]::varchar[] AS пустой_массив;

SELECT 
    'Пример 2: Приведение типов' AS описание;

SELECT ARRAY['a', 'b', 'c'] AS без_приведения;

SELECT ARRAY['a', 'b', 'c']::varchar[] AS с_приведением;

SELECT 
    ARRAY['a']::varchar[] AS массив1,
    ARRAY['b']::varchar[] AS массив2,
    ARRAY['a']::varchar[] || ARRAY['b']::varchar[] AS объединение;

SELECT 
    'Пример 3: Склеивание массивов' AS описание;

SELECT 
    ARRAY['a'] || ARRAY['b'] AS результат;

SELECT 
    ARRAY['a','b'] || ARRAY['c'] AS результат;

SELECT 
    ARRAY['a','b'] || ARRAY['c','d'] AS результат;

SELECT 
    ARRAY['a','b','c']::varchar[] AS старый_путь,
    'd' AS новый_город,
    ARRAY['a','b','c']::varchar[] || ARRAY['d']::varchar[] AS новый_путь;

SELECT 
    'Пример 4: Обращение к элементам' AS описание;

SELECT 
    ARRAY['a','b','c','d'] AS массив,
    (ARRAY['a','b','c','d'])[1] AS первый_элемент,
    (ARRAY['a','b','c','d'])[2] AS второй_элемент,
    (ARRAY['a','b','c','d'])[4] AS четвёртый_элемент;

SELECT 
    'Пример 5: Проверка "есть ли элемент в массиве"' AS описание;

SELECT 
    'b' = ANY(ARRAY['a','b','c']) AS элемент_есть;

SELECT 
    'z' = ANY(ARRAY['a','b','c']) AS элемент_есть;

SELECT 
    NOT 'b' = ANY(ARRAY['a','b','c']) AS элемента_нет;

SELECT 
    NOT 'z' = ANY(ARRAY['a','b','c']) AS элемента_нет;

SELECT 
    ARRAY['a','b','c'] AS посещённые_города,
    'd' AS следующий_город,
    NOT 'd' = ANY(ARRAY['a','b','c']) AS можно_посетить;

SELECT 
    ARRAY['a','b','c'] AS посещённые_города,
    'b' AS следующий_город,
    NOT 'b' = ANY(ARRAY['a','b','c']) AS можно_посетить;

SELECT 
    'Пример 6: Полезные функции' AS описание;

SELECT 
    ARRAY['a','b','c','d'] AS массив,
    array_length(ARRAY['a','b','c','d'], 1) AS длина;

SELECT 
    ARRAY['a','b','c'] AS старый,
    array_append(ARRAY['a','b','c'], 'd') AS новый;

SELECT 
    ARRAY['a','b','c','d'] AS массив,
    array_to_string(ARRAY['a','b','c','d'], ',') AS строка;

SELECT 
    ARRAY['a','b','c','d'] AS путь,
    array_to_string(ARRAY['a','b','c','d'] || ARRAY['a'], ',') AS цикл;

SELECT unnest(ARRAY['a','b','c','d']) AS элемент;

SELECT 
    'Пример 7: Аналогии с другими языками' AS описание;

SELECT 
    'Пример 8: Симуляция нашего кода' AS описание;

WITH step0 AS (
    SELECT ARRAY['a']::varchar[] AS visited_cities
),
step1 AS (
    SELECT visited_cities || ARRAY['b']::varchar[] AS visited_cities
    FROM step0
),
step2 AS (
    SELECT visited_cities || ARRAY['c']::varchar[] AS visited_cities
    FROM step1
),
step3 AS (
    SELECT visited_cities || ARRAY['d']::varchar[] AS visited_cities
    FROM step2
)
SELECT 
    s0.visited_cities AS шаг_0_anchor,
    s1.visited_cities AS шаг_1_добавили_b,
    s2.visited_cities AS шаг_2_добавили_c,
    s3.visited_cities AS шаг_3_добавили_d
FROM step0 s0, step1 s1, step2 s2, step3 s3;

SELECT 
    'Пример 9: Можно ли посетить город?' AS описание;

WITH visited AS (
    SELECT ARRAY['a','b','c']::varchar[] AS cities
)
SELECT 
    cities AS посещённые,
    'd' AS проверяемый_город,
    'd' = ANY(cities) AS город_уже_посещён,
    NOT 'd' = ANY(cities) AS можно_посетить
FROM visited
UNION ALL
SELECT 
    cities AS посещённые,
    'b' AS проверяемый_город,
    'b' = ANY(cities) AS город_уже_посещён,
    NOT 'b' = ANY(cities) AS можно_посетить
FROM visited;

SELECT 
    'Пример 10: Преобразование в строку {a,b,c,d,a}' AS описание;

WITH path AS (
    SELECT ARRAY['a','b','c','d']::varchar[] AS visited
)
SELECT 
    visited AS массив_пути,
    visited || ARRAY['a']::varchar[] AS добавили_возврат,
    array_to_string(visited || ARRAY['a']::varchar[], ',') AS склеили_строку,
    '{' || array_to_string(visited || ARRAY['a']::varchar[], ',') || '}' AS финальный_формат
FROM path;

SELECT ARRAY['твой', 'массив', 'здесь'] AS мой_массив;

SELECT ARRAY['a','b'] || ARRAY['?'] AS что_получится;

SELECT 'x' = ANY(ARRAY['a','b','c','x','y']) AS результат;

SELECT array_length(ARRAY[1,2,3,4,5,6,7,8,9,10], 1) AS длина;

DROP TABLE IF EXISTS routes_example;

CREATE TABLE routes_example (
    id INT,
    path varchar[]
);

INSERT INTO routes_example VALUES
(1, ARRAY['a','b','c']),
(2, ARRAY['a','c','b']),
(3, ARRAY['a','d','b','c']);

SELECT * FROM routes_example;

SELECT 
    id,
    path,
    array_length(path, 1) AS длина_пути,
    'b' = ANY(path) AS проходит_через_b
FROM routes_example;

SELECT 
    'ИТОГОВОЕ УПРАЖНЕНИЕ: Понимание нашего кода' AS описание;

WITH RECURSIVE simulation AS (
    SELECT 
        ARRAY['a']::varchar[] AS visited,
        'a'::CHAR(1) AS current,
        0 AS iteration
    
    UNION ALL
    
    SELECT 
        visited || ARRAY['b']::varchar[],
        'b'::CHAR(1),
        iteration + 1
    FROM simulation
    WHERE iteration < 3
)
SELECT 
    iteration AS итерация,
    visited AS посещённые_города,
    current AS текущий_город,
    array_length(visited, 1) AS количество_городов
FROM simulation;