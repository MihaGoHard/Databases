USE lw_5;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL sql_mode='';
SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/room_in_booking.csv'  
INTO TABLE room_in_booking
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# 1. Добавить внешние ключи

ALTER TABLE booking
  ADD FOREIGN KEY (id_client) REFERENCES client (id_client);

ALTER TABLE room_in_booking
  ADD FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

ALTER TABLE room_in_booking
  ADD FOREIGN KEY (id_room) REFERENCES room (id_room);

ALTER TABLE room
  ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room
  ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);
 
 
# 2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах
# категории “Люкс” на 1 апреля 2019г.

SELECT client.name, client.phone  
	FROM client
INNER JOIN booking 
	ON booking.id_client = client.id_client 
INNER JOIN room_in_booking 
	ON room_in_booking.id_booking = booking.id_booking 
INNER JOIN room 
	ON room.id_room = room_in_booking.id_room
INNER JOIN room_category
	ON room_category.id_room_category = room.id_room_category
INNER JOIN hotel
	ON room.id_hotel = hotel.id_hotel  
	WHERE checking_date <= '2019-04-01'
		AND checkout_date >= '2019-04-01'
		AND room_category.name = 'Люкс'
		AND hotel.name = 'Космос';


# 3. Дать список свободных номеров всех гостиниц на 22 апреля.

SELECT * 
FROM room
WHERE room.id_room NOT IN
	(SELECT room.id_room     
	FROM room
	INNER JOIN hotel
		ON room.id_hotel = hotel.id_hotel
	INNER JOIN room_in_booking
		ON room.id_room = room_in_booking.id_room
    WHERE room_in_booking.checking_date <= '2019-04-22'
		AND room_in_booking.checkout_date > '2019-04-22');


# 4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров

SELECT room_category.name, number_of_residents
FROM room_category
INNER JOIN
	(SELECT room_category.id_room_category , COUNT(*) AS 'number_of_residents'
	FROM room_category
	INNER JOIN room
		ON room_category.id_room_category = room.id_room_category
	INNER JOIN hotel 
		ON hotel.id_hotel = room.id_hotel
	INNER JOIN room_in_booking
		ON room.id_room = room_in_booking.id_room
	WHERE (room_in_booking.checking_date <= '2019-03-23'
		AND room_in_booking.checkout_date > '2019-03-23' 
    AND hotel.name = 'Космос')
	GROUP BY room_category.id_room_category) AS t
ON room_category.id_room_category = t.id_room_category;


# 5. Дать список последних проживавших клиентов по всем комнатам гостиницы
# “Космос”, выехавшим в апреле с указанием даты выезда. 

SELECT number, name, checkout_date
FROM
	(SELECT room.number, client.name, room_in_booking.checkout_date, 
		ROW_NUMBER() OVER (PARTITION BY room.id_room ORDER BY room_in_booking.checkout_date desc) r_n
	FROM hotel
	INNER JOIN room
		ON hotel.id_hotel = room.id_hotel
	INNER JOIN room_in_booking  
		ON room_in_booking.id_room = room.id_room
	INNER JOIN booking
		ON room_in_booking.id_booking = booking.id_booking
	INNER JOIN client
		ON booking.id_client = client.id_client
	WHERE (hotel.name = 'Космос'
		AND room_in_booking.checkout_date >= '2019-04-01'
		AND room_in_booking.checkout_date < '2019-05-01')
	ORDER BY room.number, room_in_booking.checkout_date desc) AS sorted
	WHERE r_n = '1';


# 6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
# комнат категории “Бизнес”, которые заселились 10 мая.

UPDATE lw_5.room_in_booking
SET lw_5.room_in_booking.checkout_date = DATE_ADD(lw_5.room_in_booking.checkout_date, INTERVAL 2 DAY)
WHERE lw_5.room_in_booking.id_room_in_booking IN
(SELECT id_room_in_booking
FROM(
	SELECT room_in_booking.id_room_in_booking
	FROM room_category
	INNER JOIN room
		ON room.id_room_category = room_category.id_room_category 
	INNER JOIN hotel 
		ON hotel.id_hotel = room.id_hotel
	INNER JOIN room_in_booking
		ON room.id_room = room_in_booking.id_room
	WHERE hotel.name = 'Космос' 
		AND room_category.name = 'Бизнес'
		AND room_in_booking.checking_date = '2019-05-10') AS t
);
 
# 7. Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
# может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
# заселиться нескольким клиентам в один номер. Записи в таблице
# room_in_booking с id_room_in_booking = 5 и 2154 являются примером
# неправильного состояния, которые необходимо найти. Результирующий кортеж
# выборки должен содержать информацию о двух конфликтующих номерах.

SELECT t_1.id_room, t_1.id_room_in_booking, t_2.id_room_in_booking
FROM room_in_booking AS t_1
INNER JOIN room_in_booking AS t_2
ON t_1.id_room = t_2.id_room AND t_1.id_room_in_booking != t_2.id_room_in_booking
WHERE t_2.checking_date >= t_1.checking_date AND t_2.checking_date < t_1.checkout_date
ORDER BY t_1.id_room_in_booking;

# 8. Создать бронирование в транзакции.

START TRANSACTION;
	INSERT INTO lw_5.booking (id_client, id_booking, booking_date)
    VALUES (82, 4444, '2021-03-02');
    
    INSERT INTO lw_5.room_in_booking (id_room_in_booking, id_booking, id_room, checking_date, checkout_date)
    VALUES (4444, 4444, 5, '2021-06-01', '2021-06-15');
COMMIT;
ROLLBACK;


# 9. Добавить необходимые индексы для всех таблиц

CREATE INDEX IX_booking_id_client ON lw_5.booking
(
	id_client 
);


CREATE INDEX IX_room_in_booking_id_booking ON lw_5.room_in_booking
(
	id_booking 
);

CREATE INDEX IX_room_in_booking_id_room ON lw_5.room_in_booking
(
	id_room 
);

CREATE INDEX IX_room_id_hotel ON lw_5.room
(
	id_hotel 
);

CREATE INDEX IX_room_id_room_category ON lw_5.room
(
	id_room_category
);



SELECT CURRENT_DATE();
SELECT * FROM booking;
SELECT * FROM client;
SELECT * FROM hotel;
SELECT * FROM room_category;
SELECT * FROM room;
SELECT * FROM room_in_booking; 
