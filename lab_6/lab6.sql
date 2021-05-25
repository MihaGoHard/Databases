USE lw_6;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL sql_mode='';
SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/production.csv'  
INTO TABLE production
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM `order`;

#1. Добавить внешние ключи.

ALTER TABLE `dealer` 
ADD INDEX `company_idx` (`id_company` ASC) VISIBLE;
ALTER TABLE `dealer` 
ADD CONSTRAINT `company`
  FOREIGN KEY (`id_company`)
  REFERENCES `company` (`id_company`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
  
ALTER TABLE `order` 
ADD INDEX `production_idx` (`id_production` ASC) VISIBLE;
ALTER TABLE `order` 
ADD CONSTRAINT `production`
  FOREIGN KEY (`id_production`)
  REFERENCES `production` (`id_production`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;  
  
ALTER TABLE `order` 
ADD INDEX `dealer_idx` (`id_dealer` ASC) VISIBLE;
ALTER TABLE `order` 
ADD CONSTRAINT `dealer`
  FOREIGN KEY (`id_dealer`)
  REFERENCES `dealer` (`id_dealer`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;  
  
ALTER TABLE `order` 
ADD INDEX `pharmacy_idx` (`id_pharmacy` ASC) VISIBLE;
ALTER TABLE `order` 
ADD CONSTRAINT `pharmacy`
  FOREIGN KEY (`id_pharmacy`)
  REFERENCES `pharmacy` (`id_pharmacy`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;  
  
ALTER TABLE `production` 
ADD CONSTRAINT `company_production`
  FOREIGN KEY (`id_company`)
  REFERENCES `company` (`id_company`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

#2 Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с
#  указанием названий аптек, дат, объема заказов.

SELECT medicine.name AS medicine, company.name AS company, `order`.date, `order`.quantity, pharmacy.name AS pharmacy
FROM `order`
INNER JOIN pharmacy
	ON `order`.id_pharmacy = pharmacy.id_pharmacy
INNER JOIN production
	ON `order`.id_production = production.id_production
INNER JOIN company
	ON production.id_company = company.id_company
INNER JOIN medicine
	ON production.id_medicine = medicine.id_medicine
WHERE medicine.name = 'Кордеон' AND company.name = 'Аргус';    

#3 Дать список лекарств компании “Фарма”, на которые не были сделаны заказы
#  до 25 января.
#  если никогда не продавался, то не выведем лекарство

SELECT medicine.name AS medicine#, company.name AS company, `order`.date
FROM medicine
WHERE medicine.id_medicine NOT IN 
	(SELECT medicine.id_medicine 
	FROM medicine
	INNER JOIN production
		ON production.id_medicine = medicine.id_medicine
	INNER JOIN `order`
		ON `order`.id_production = production.id_production)
OR medicine.id_medicine IN
	(SELECT medicine.id_medicine 
	FROM medicine
	INNER JOIN production
		ON production.id_medicine = medicine.id_medicine
	INNER JOIN company
		ON production.id_company = company.id_company
	INNER JOIN `order`
		ON `order`.id_production = production.id_production	
	WHERE company.name = 'Фарма' AND `order`.date >= '2019-01-25');   

#4 Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
#  оформила не менее 120 заказов.

SELECT MIN(pharmacy.rating), MAX(pharmacy.rating), company.name
FROM pharmacy
INNER JOIN `order`
	ON `order`.id_pharmacy = pharmacy.id_pharmacy
INNER JOIN production
	ON `order`.id_production = production.id_production
INNER JOIN company	
	ON production.id_company = company.id_company
GROUP BY company.name
HAVING COUNT(*) >= 120;
    
#5 Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
#  Если у дилера нет заказов, в названии аптеки проставить NULL.

SELECT dealer.name AS dealer, pharmacy.name AS pharmacy, company.name AS company
FROM company
INNER JOIN dealer
	ON dealer.id_company = company.id_company
LEFT JOIN `order`
	ON `order`.id_dealer = dealer.id_dealer
LEFT JOIN pharmacy
	ON 	`order`.id_pharmacy = pharmacy.id_pharmacy
WHERE company.name = 'AstraZeneca';
    
#6 Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
#  длительность лечения не более 7 дней.

UPDATE lw_6.production
SET price = price * 0.8
WHERE id_production IN
	(SELECT id_production
	FROM medicine
    INNER JOIN production
    ON production.id_medicine = medicine.id_medicine
    WHERE cure_duration <= 7 AND price > 3000);
    
#7 Добавить необходимые индексы. 

CREATE INDEX IX_production_id_company ON lw_6.production 
(
	id_company 
);

CREATE INDEX IX_production_id_medicine ON lw_6.production 
(
	id_medicine 
);

CREATE INDEX IX_production_price ON lw_6.production 
(
	price 
);


CREATE INDEX IX_order_id_production ON lw_6.order 
(
	id_production 
);

CREATE INDEX IX_order_id_dealer ON lw_6.order 
(
	id_dealer 
);

CREATE INDEX IX_order_id_pharmacy ON lw_6.order 
(
	id_pharmacy 
);

CREATE INDEX IX_order_date ON lw_6.order 
(
	`date` 
);


CREATE INDEX IX_medicine_cure_duration ON lw_6.medicine 
(
	cure_duration 
);

CREATE INDEX IX_dealer_id_company ON lw_6.dealer
(
	id_company 
);
