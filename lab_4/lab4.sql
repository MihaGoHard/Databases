#3.1 INSERT
#a. Без указания списка полей
INSERT programm 
VALUES    
	(12123, 'roofos', '2001-03-03', '987r-8273');

#b. С указанием списка полей    
INSERT programm 
	(id_programm, company, release_date, save_key)
VALUES    
	(7676, 'amazon', '2020-03-03', '111-323'); 

#c. С чтением значения из другой таблицы    
INSERT programm(company) SELECT (company) FROM computer;



#3.2. DELETE
#a. Всех записей
DELETE FROM programm 
WHERE id_programm > 0;

#b. По условию
DELETE FROM programm 
WHERE company = 'amazon';



#3.3. UPDATE
#a. Всех записей
UPDATE programm 
SET company = 'yandex';

#b. По условию обновляя один атрибут
UPDATE programm 
SET company = 'google' 
WHERE release_date = '2019-02-09';

#c. По условию обновляя несколько атрибутов
UPDATE programm 
SET company = 'yandex', release_date = '2021-02-01' 
WHERE save_key = '122-54454';


#3.4. SELECT
#a. С набором извлекаемых атрибутов 
SELECT company, release_date 
FROM programm;

#b. Со всеми атрибутами
SELECT * 
FROM programm;

#c. С условием по атрибуту
SELECT save_key, release_date 
FROM programm 
WHERE company = 'google';



#3.5. SELECT ORDER BY + TOP (LIMIT)
#a. С сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT * 
FROM programm ORDER BY release_date ASC;

#b. С сортировкой по убыванию DESC
SELECT * 
FROM programm ORDER BY release_date DESC;

#c. С сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT * 
FROM programm ORDER BY release_date, company ASC LIMIT 4;

#d. С сортировкой по первому атрибуту, из списка извлекаемых
SELECT company, release_date 
FROM programm ORDER BY 1 ASC;



#3.6. Работа с датами
#a. WHERE по дате
SELECT * 
FROM programm 
WHERE release_date = '2020-10-10';

#b. WHERE дата в диапазоне
SELECT * 
FROM programm 
WHERE release_date >= '2018-01-01' AND release_date <= '2020-10-10';

#c. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
SELECT YEAR((SELECT release_date FROM programm WHERE company = 'amazon'));



#3.7. Функции агрегации
#a. Посчитать количество записей в таблице
SELECT COUNT(*) AS rows_number FROM programm;

#b. Посчитать количество уникальных записей в таблице
SELECT COUNT(*) AS unique_rows_number 
FROM (SELECT * FROM programm GROUP BY company) AS grouped;

#c. Вывести уникальные значения столбца
SELECT company AS unique_company FROM programm GROUP BY company;

#d. Найти максимальное значение столбца
SELECT MAX(release_date) FROM programm;

#e. Найти минимальное значение столбца
SELECT MIN(release_date) FROM programm;

#f. Написать запрос COUNT() + GROUP BY
SELECT company, COUNT(*) FROM programm GROUP BY company; 



#3.8 3.8. SELECT GROUP BY + HAVING
#a. Написать 3 разных запроса с использованием GROUP BY + HAVING. Для
#каждого запроса написать комментарий с пояснением, какую информацию
#извлекает запрос. Запрос должен быть осмысленным, т.е. находить информацию,
#которую можно использовать.

SELECT company 
FROM programm 
GROUP BY release_date 
HAVING release_date < '2020-01-01'; # нахождение уникальных имен компаний сделавших релиз ранее указанной даты  

SELECT company, release_date 
FROM programm 
GROUP BY company 
HAVING company != 'google'; # нахождение дат релизов всех компаний кроме google

SELECT id_programm 
FROM programm 
GROUP BY save_key 
HAVING LENGTH(save_key) > 8; # получение id программ с ключом, длинной больше 8 символов


