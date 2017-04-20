-- Corylus - ERP software
-- Copyright (c) 2005-2017 François Tigeot

-- List of countries

START TRANSACTION;

CREATE TABLE countries (
	id		serial NOT NULL PRIMARY KEY,
	name		varchar(30) NOT NULL
);

INSERT INTO countries(id,name) VALUES(1,'Belgium');
INSERT INTO countries(id,name) VALUES(2,'France');
INSERT INTO countries(id,name) VALUES(3,'Germany');
INSERT INTO countries(id,name) VALUES(4,'Hong-Kong');
INSERT INTO countries(id,name) VALUES(5,'Israel');
INSERT INTO countries(id,name) VALUES(6,'Korea');
INSERT INTO countries(id,name) VALUES(7,'Luxemburg');
INSERT INTO countries(id,name) VALUES(8,'Switzerland');
INSERT INTO countries(id,name) VALUES(9,'Togo');
INSERT INTO countries(id,name) VALUES(10,'USA');
INSERT INTO countries(id,name) VALUES(11,'United Kingdom');
INSERT INTO countries(id,name) VALUES(12,'The Netherlands');
INSERT INTO countries(id,name) VALUES(13,'Singapore');
INSERT INTO countries(id,name) VALUES(14,'China');
INSERT INTO countries(id,name) VALUES(15,'Austria');
INSERT INTO countries(id,name) VALUES(16,'Finland');

COMMIT;
