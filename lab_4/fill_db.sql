USE lw_4;
SHOW TABLES;

INSERT office 
	(id_office, name, address, work_number, phone_number)
VALUES    
	(1, 'main', 'gogol st. 12', 8, 500),
    (23, 'middle', 'pushkin st. 20', 78, 1500), 
    (114, 'angle', 'shishkin st. 32', 110, 900), 
    (45, 'north', 'lermontov st. 11', 23, 200), 
    (76, 'sourth', 'tolstoy st. 9', 2, 10); 
    
    
INSERT installer 
	(id_installer, name, birth_date, gender, profession)
VALUES    
	(13049, 'Mishan', '2000-01-01', 'mail', 'installer'),
    (2084, 'Oleg', '1998-12-02', 'mail', 'hr'),
    (30005, 'Maria', '2001-07-07', 'femail', 'programmer'),
    (8766, 'Dmitriy', '2002-06-04', 'mail', 'programmer'),
    (7126, 'Svetlana', '1999-02-11', 'femail', 'installer');   
    
INSERT programm 
	(id_programm, company, release_date, save_key)
VALUES    
	(12321, 'amazon', '2019-03-03', '987-8273'),
    (12843, 'yandex', '2021-02-01', '54-2373'),
    (123137, 'google', '2019-02-09', '122-54454'),
    (6565321, 'mail', '2018-01-01', '122-242'),
    (123421, 'jet brains', '2020-10-10', '8786-256');

INSERT computer 
VALUES
	(901, 1, 'apple', '2017-06-01', 'full', 1000),
    (12, 23, 'samsung', '2020-10-02', 'full', 1100),
    (30, 114, 'yandex', '2018-10-07', 'full', 750),
    (310, 45, 'acer', '2020-07-04', 'full', 1800),
    (2910, 76, 'lenovo', '2020-02-11', 'full', 900);
    
INSERT installed_programm
	(id_computer, id_installer, id_programm, company, installed_date, user_name, save_key)
VALUES
	(901, 13049, 12321, 'google', '2017-01-01', 'Peter', '900-100'),
    (12, 2084, 123421, 'amazon', '2020-12-02', 'Mishan', '1400-120'),
    (30, 30005, 6565321, 'yandex', '2018-07-07', 'Oleg', '300-1710'),
    (310, 8766, 12843, 'jet brains', '2020-07-04', 'Maria', '876-1800'),
    (2910, 7126, 123137, 'mail', '2020-02-11', 'Svetlana', '232-1900');
 


INSERT office(name) SELECT (company) FROM computer;
    
DELETE FROM office WHERE id_office > 0;
DELETE FROM computer WHERE id_computer > 0; 
DELETE FROM installed_programm WHERE id_installed_programm > 0;
DELETE FROM programm WHERE id_programm > 0; 
DELETE FROM installer WHERE id_installer > 0;    

SELECT * FROM computer;
SELECT * FROM installed_programm;
SELECT * FROM office;  
SELECT * FROM programm; 
SELECT * FROM installer;    