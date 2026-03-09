# 🔍 ДЕТАЛЬНЫЙ РАЗБОР `ARRAY[edges.point2]::varchar[]`

---

## 📖 РАЗБОР ПО ЧАСТЯМ

```sql
ARRAY[edges.point2]::varchar[]
  │      │     │      │   │
  │      │     │      │   └─── Тип: массив varchar
  │      │     │      └─────── Приведение типа
  │      │     └────────────── Одиночное значение (город)
  │      └──────────────────── Берём из таблицы edges
  └─────────────────────────── Оборачиваем в массив
```

---

## 🎯 ЧТО ЭТО ДЕЛАЕТ?

### Пошагово:

```sql
edges.point2           -- Шаг 1: Берём один город (например, 'b')
       │
       ↓
ARRAY[edges.point2]    -- Шаг 2: Заворачиваем в массив ['b']
       │
       ↓
::varchar[]            -- Шаг 3: Указываем тип "массив varchar"
```

---

## 🔢 ШАГ 1: `edges.point2` — Одиночное значение

### Что это:

```sql
edges.point2
  │      │
  │      └─── Колонка point2 (куда ведёт ребро)
  │
  └────────── Из таблицы edges (алиас для tsp)
```

### Примеры значений:

```sql
-- Когда edges указывает на ребро a→b:
edges.point2 = 'b'     ← одиночный символ

-- Когда edges указывает на ребро a→c:
edges.point2 = 'c'     ← одиночный символ

-- Когда edges указывает на ребро b→d:
edges.point2 = 'd'     ← одиночный символ
```

**Важно:** `edges.point2` — это НЕ массив! Это ОДНО значение типа CHAR(1).

---

## 📦 ШАГ 2: `ARRAY[edges.point2]` — Заворачивание в массив

### Что делает `ARRAY[...]`?

```sql
ARRAY[значение]
  │      │
  │      └─── Берёт значение
  │
  └────────── И создаёт массив с ОДНИМ элементом

Примеры:
ARRAY['b']     → {b}      (массив с одним элементом)
ARRAY[5]       → {5}      (массив с одним числом)
ARRAY['hello'] → {hello}  (массив с одной строкой)
```

### В нашем случае:

```sql
-- Если edges.point2 = 'b':
ARRAY[edges.point2]
ARRAY['b']           → {b}

-- Если edges.point2 = 'c':
ARRAY[edges.point2]
ARRAY['c']           → {c}

-- Если edges.point2 = 'd':
ARRAY[edges.point2]
ARRAY['d']           → {d}
```

---

## ❓ ЗАЧЕМ ЗАВОРАЧИВАТЬ В МАССИВ?

### Для операции конкатенации `||`!

```sql
routes.visited_cities || ARRAY[edges.point2]::varchar[]
        ↑                        ↑
     массив                   массив

Оператор || работает: массив + массив
```

### Почему не так:

```sql
-- ❌ НЕПРАВИЛЬНО:
routes.visited_cities || edges.point2
        ↑                    ↑
     массив             одиночное значение

PostgreSQL не знает, как склеить массив с одиночным значением!
```

### Правильно так:

```sql
-- ✅ ПРАВИЛЬНО:
routes.visited_cities || ARRAY[edges.point2]::varchar[]
        ↑                           ↓
     {a,b,c}                       {d}
        ↓                           ↓
              {a,b,c,d}  ← результат!
```

---

## 💡 НАГЛЯДНЫЕ ПРИМЕРЫ

### Пример 1: Добавление 'b' к {a}

```sql
-- Шаг 1: edges.point2 = 'b' (одиночное значение)
edges.point2
    ↓
   'b'

-- Шаг 2: Заворачиваем в массив
ARRAY[edges.point2]
ARRAY['b']
    ↓
   {b}

-- Шаг 3: Конкатенация
routes.visited_cities || ARRAY[edges.point2]::varchar[]
        {a}            ||        {b}
               ↓
            {a,b}
```

### Пример 2: Добавление 'c' к {a,b}

```sql
-- Текущее состояние
routes.visited_cities = {a,b}
edges.point2 = 'c'

-- Заворачиваем 'c' в массив
ARRAY['c'] = {c}

-- Конкатенация
{a,b} || {c} = {a,b,c}
```

### Пример 3: Добавление 'd' к {a,b,c}

```sql
-- Текущее состояние
routes.visited_cities = {a,b,c}
edges.point2 = 'd'

-- Заворачиваем 'd' в массив
ARRAY['d'] = {d}

-- Конкатенация
{a,b,c} || {d} = {a,b,c,d}
```

---

## 🔬 ДЕТАЛЬНЫЙ ПРИМЕР ИЗ КОДА

### Контекст:

```sql
SELECT
    routes.visited_cities || ARRAY[edges.point2]::varchar[],
    edges.point2,
    routes.accumulated_cost + edges.cost
FROM building_routes AS routes
JOIN tsp AS edges ON edges.point1 = routes.current_city
WHERE NOT edges.point2 = ANY(routes.visited_cities)
```

### Что происходит на итерации 1:

```
1. routes.visited_cities = {a}
   routes.current_city = 'a'

2. JOIN находит рёбра из 'a':
   edges: {point1: 'a', point2: 'b', cost: 10}

3. edges.point2 = 'b' (ОДИНОЧНОЕ значение!)

4. ARRAY[edges.point2] = ARRAY['b'] = {b}

5. Конкатенация:
   {a} || {b} = {a,b}

6. Новая строка:
   visited_cities = {a,b}
   current_city = 'b'
   accumulated_cost = 10
```

---

## 🎨 ВИЗУАЛИЗАЦИЯ

```
edges.point2 = 'b'
     ↓
    'b'  ← ЭТО ОДИНОЧНЫЙ СИМВОЛ (CHAR(1))
     ↓
ARRAY['b']  ← ЗАВОРАЧИВАЕМ В МАССИВ
     ↓
    {b}  ← ТЕПЕРЬ ЭТО МАССИВ С ОДНИМ ЭЛЕМЕНТОМ
     ↓
{a} || {b}  ← СКЛЕИВАЕМ ДВА МАССИВА
     ↓
   {a,b}  ← РЕЗУЛЬТАТ: РАСШИРЕННЫЙ МАССИВ
```

---

## 🔄 АЛЬТЕРНАТИВНЫЕ СПОСОБЫ (НЕ ИСПОЛЬЗУЮТСЯ)

### Способ 1: array_append (тоже работает)

```sql
-- Вместо:
routes.visited_cities || ARRAY[edges.point2]::varchar[]

-- Можно:
array_append(routes.visited_cities, edges.point2)

-- Результат одинаковый:
array_append({a,b}, 'c') → {a,b,c}
```

### Способ 2: Конкатенация с одиночным значением (работает в PostgreSQL)

```sql
-- В PostgreSQL можно так:
routes.visited_cities || edges.point2

-- PostgreSQL автоматически преобразует 'b' в {b}
-- Но ARRAY[...] более явно и понятно!
```

### Почему используем ARRAY[...]:

```
✅ Явная типизация
✅ Понятно, что происходит
✅ Работает везде одинаково
✅ Легче читать код
```

---

## 🧪 ИНТЕРАКТИВНЫЕ ПРИМЕРЫ

```sql
-- Попробуй в PostgreSQL:

-- Пример 1: Создание одноэлементного массива
SELECT ARRAY['b']::varchar[] AS single_element;
-- Результат: {b}

-- Пример 2: Конкатенация массивов
SELECT 
    ARRAY['a']::varchar[] AS массив1,
    ARRAY['b']::varchar[] AS массив2,
    ARRAY['a']::varchar[] || ARRAY['b']::varchar[] AS результат;
-- Результат:
--  массив1 | массив2 | результат
-- ---------+---------+-----------
--  {a}     | {b}     | {a,b}

-- Пример 3: Пошаговое добавление
WITH step1 AS (
    SELECT ARRAY['a']::varchar[] AS path
),
step2 AS (
    SELECT path || ARRAY['b']::varchar[] AS path FROM step1
),
step3 AS (
    SELECT path || ARRAY['c']::varchar[] AS path FROM step2
)
SELECT * FROM step1
UNION ALL SELECT * FROM step2
UNION ALL SELECT * FROM step3;
-- Результат:
--  path
-- --------
--  {a}
--  {a,b}
--  {a,b,c}

-- Пример 4: Из переменной
SELECT 
    'b'::CHAR(1) AS одиночное_значение,
    ARRAY['b'::CHAR(1)]::varchar[] AS в_массиве,
    ARRAY['a']::varchar[] || ARRAY['b'::CHAR(1)]::varchar[] AS склейка;
-- Результат:
--  одиночное_значение | в_массиве | склейка
-- --------------------+-----------+---------
--  b                  | {b}       | {a,b}
```

---

## 💻 АНАЛОГИЯ С ДРУГИМИ ЯЗЫКАМИ

### В JavaScript:

```javascript
// SQL: ARRAY[edges.point2]

// Одиночное значение
const point2 = 'b';

// Заворачиваем в массив
const wrappedInArray = [point2];  // ['b']

// Конкатенация
const visitedCities = ['a'];
const newPath = visitedCities.concat(wrappedInArray);
// или:
const newPath = [...visitedCities, point2];

console.log(newPath);  // ['a', 'b']
```

### В Python:

```python
# SQL: ARRAY[edges.point2]

# Одиночное значение
point2 = 'b'

# Заворачиваем в список
wrapped_in_list = [point2]  # ['b']

# Конкатенация
visited_cities = ['a']
new_path = visited_cities + wrapped_in_list

print(new_path)  # ['a', 'b']
```

### В C:

```c
// SQL: ARRAY[edges.point2]

// Одиночное значение
char point2 = 'b';

// Добавление в массив (вручную)
char visited_cities[10] = {'a'};
int length = 1;
visited_cities[length++] = point2;  // теперь {'a', 'b'}
```

---

## 📊 СРАВНИТЕЛЬНАЯ ТАБЛИЦА

| Выражение | Тип | Значение | Описание |
|-----------|-----|----------|----------|
| `edges.point2` | CHAR(1) | 'b' | Одиночный символ |
| `ARRAY[edges.point2]` | массив | {b} | Массив с одним элементом |
| `ARRAY['b']` | массив | {b} | То же самое |
| `{a} || {b}` | массив | {a,b} | Результат конкатенации |

---

## 🎯 КЛЮЧЕВЫЕ МОМЕНТЫ

### 1️⃣ `edges.point2` — это ОДНО значение

```sql
edges.point2 = 'b'  ← НЕ массив!
```

### 2️⃣ `ARRAY[...]` заворачивает в массив

```sql
ARRAY['b'] = {b}  ← МАССИВ с одним элементом
```

### 3️⃣ Нужно для конкатенации с `||`

```sql
{a} || {b} = {a,b}  ← Массив + Массив
```

### 4️⃣ `::varchar[]` — явная типизация

```sql
ARRAY[edges.point2]::varchar[]  ← Говорим PostgreSQL: "это массив varchar"
```

---

## 🔍 ПОШАГОВАЯ ВИЗУАЛИЗАЦИЯ

```
Итерация рекурсии:

┌──────────────────────────────────────────┐
│ Текущее состояние:                       │
│ routes.visited_cities = {a}              │
│ routes.current_city = 'a'                │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│ JOIN с tsp находит ребро:                │
│ edges.point1 = 'a'                       │
│ edges.point2 = 'b'  ← ОДИНОЧНОЕ!        │
│ edges.cost = 10                          │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│ Заворачиваем point2 в массив:            │
│ ARRAY[edges.point2]                      │
│ ARRAY['b']                               │
│ {b}  ← МАССИВ!                           │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│ Конкатенация:                            │
│ {a} || {b} = {a,b}                       │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│ Новая строка:                            │
│ visited_cities = {a,b}                   │
│ current_city = 'b'                       │
│ accumulated_cost = 10                    │
└──────────────────────────────────────────┘
```

---

## 🏆 ИТОГОВАЯ СХЕМА

```
edges.point2              ← Одиночное значение
     ↓
    'b'                   ← CHAR(1)
     ↓
ARRAY['b']                ← Заворачиваем в массив
     ↓
    {b}                   ← Массив с одним элементом
     ↓
::varchar[]               ← Приведение типа
     ↓
ARRAY['b']::varchar[]     ← Финальный массив
     ↓
{a} || {b}                ← Склеиваем с существующим
     ↓
   {a,b}                  ← Расширенный путь!
```

---

## ✅ ПРОВЕРЬ СЕБЯ

### Вопрос 1: Что такое `edges.point2`?

**Ответ:** Одиночное значение типа CHAR(1) (один город)

---

### Вопрос 2: Что делает `ARRAY[edges.point2]`?

**Ответ:** Заворачивает одиночное значение в массив с одним элементом

---

### Вопрос 3: Зачем заворачивать в массив?

**Ответ:** Для конкатенации с оператором || (массив + массив)

---

### Вопрос 4: Чему равно `ARRAY['b']`?

**Ответ:** `{b}` (массив с одним элементом)

---

## 📝 ПРОСТОЕ ОБЪЯСНЕНИЕ

```
edges.point2 = 'b'        ← У нас есть город 'b'
ARRAY['b'] = {b}          ← Кладём его в коробку (массив)
{a} || {b} = {a,b}        ← Склеиваем две коробки

Зачем коробка?
Потому что оператор || работает только: коробка + коробка
Нельзя склеить: коробка + отдельный предмет
```

---

**Теперь ты полностью понимаешь, как "новый город заворачивается в массив"!** 🎯

**Кратко:** `edges.point2` — это один город ('b'), `ARRAY[edges.point2]` заворачивает его в массив ({b}), чтобы можно было склеить с другим массивом оператором ||.