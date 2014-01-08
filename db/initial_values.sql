-- Corylus - ERP software
-- Copyright (c) 2005-2014 François Tigeot

-- initial database content

START TRANSACTION;

INSERT INTO users (id,login,name,hashed_password,email,partner_id,perm_invoice_w)
VALUES (1,'admin','Bob Administrator','d033e22ae348aeb5660fc2140aec35850c4da997','bob@example.com',NULL,true);

INSERT INTO settings(name,value) VALUES ('company_name','Votre société');
INSERT INTO settings(name,value) VALUES ('contact_email','contact@example.com');
INSERT INTO addresses(addr1,postcode,city,country_id) VALUES ('12 rue de Paris',91400,'Orsay',2);
INSERT INTO settings(name,value) VALUES ('shipping_address_id', 1);
INSERT INTO settings(name,value) VALUES ('billing_address_id', 1);
INSERT INTO settings(name,value) VALUES ('bic', 'BNPAFRPPMEE');
INSERT INTO settings(name,value) VALUES ('iban', 'FR76 1234 5678 9101 1121 3141 516');

-- VAT rates for France in 2014
-- The first line is for special non-taxable items (stamps come to mind)
INSERT INTO vat_rates(rate) VALUES (0.0);
INSERT INTO vat_rates(rate) VALUES (2.1);
INSERT INTO vat_rates(rate) VALUES (5.5);
INSERT INTO vat_rates(rate) VALUES (10.0);
INSERT INTO vat_rates(rate) VALUES (20.0);
INSERT INTO settings(name,value) VALUES ('default_vat_rate_id',
	(SELECT id from vat_rates where rate = 20.0)
);

COMMIT;
