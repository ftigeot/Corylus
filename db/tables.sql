-- Corylus - ERP software
-- Copyright (c) 2005-2014 François Tigeot

-- We need to define all tables before checking foreign keys
START TRANSACTION;
SET CONSTRAINTS ALL DEFERRED;

-- Catégories de produits: stockage, cpu, etc...
create table categories (
	id			serial NOT NULL PRIMARY KEY,
	parent_id		integer REFERENCES categories(id),
	name			varchar(64) NOT NULL,
	position		integer,
	description		text
);

-- unification clients / fournisseurs / le reste
create table partners (
	id			serial NOT NULL PRIMARY KEY,
	name			varchar(64) NOT NULL UNIQUE,
	phone			varchar(16),
	fax			varchar(15),
	web			varchar(30),
	created_on		date NOT NULL default now(),
	updated_on		date NOT NULL default now(),
	comment			text,
	billing_address_id	integer,
	is_customer		boolean DEFAULT FALSE,
	is_supplier		boolean DEFAULT FALSE,
-- Partie suppliers
	country_id		integer NOT NULL REFERENCES countries(id),
	CONSTRAINT		suppliers_vat_range CHECK (vat >= 0 and vat <= 100),
-- Partie customers
	code			varchar(12) UNIQUE,
	long_name		varchar(90) UNIQUE,	-- Affichage sur les documents papier
	is_individual		boolean DEFAULT FALSE,
	origin			varchar(30),
	shipping_address_id	integer,
	payment_delay		smallint DEFAULT NULL,
	-- Pas plus de 60 jours pour un délai de paiement client
	CONSTRAINT		customers_payment_delay CHECK (payment_delay > 0 and payment_delay <= 60)
);

create table vat_rates (
	id		serial NOT NULL PRIMARY KEY,
	rate		decimal(3,1) NOT NULL,
	CONSTRAINT	vat_rates_range CHECK (rate >= 0 and rate <= 100)
);

-- Le descriptif de chaque produit
create table products (
	id		serial NOT NULL PRIMARY KEY,
	code		varchar(20),
	name		varchar(45) NOT NULL,
	description	varchar(140) NOT NULL,
	category_id	integer REFERENCES categories(id) NOT NULL,
	public_price	decimal(7,2) NOT NULL,
	vat_rate_id	integer NOT NULL REFERENCES vat_rates(id),
	image_url	varchar(30),
	specs		text,
	salable		boolean DEFAULT FALSE,
	show_price	boolean DEFAULT FALSE,
	created_on	date NOT NULL default now(),
	updated_on	date NOT NULL default now(),
	weight		decimal(5,2),
	obsolete	boolean DEFAULT FALSE,
	comment		text,
	position	integer
);

-- Options pour les produits
create table options (
	id		serial NOT NULL PRIMARY KEY,
	name		varchar(30) NOT NULL,
	description	varchar(60)
);

-- Composants produits
create table components (
	id		serial NOT NULL PRIMARY KEY,
	owner_id	integer NOT NULL REFERENCES products(id) DEFERRABLE,
	product_id	integer NOT NULL REFERENCES products(id) DEFERRABLE,
	position	integer,
	qty		integer NOT NULL CHECK (qty >= 0) DEFAULT 1
);

create table option_values (
	id		serial NOT NULL PRIMARY KEY,
	option_id	integer REFERENCES options(id) DEFERRABLE,
	product_id	integer REFERENCES products(id) DEFAULT NULL,
	name		varchar(140) DEFAULT NULL,
	price		decimal(7,2) DEFAULT NULL,
	default_value	boolean DEFAULT FALSE,
	position	integer
);

-- product_lines: lignes de texte ou d'options produit
-- utilisées pour peupler automatiquement les devis
create table product_lines (
	id		serial NOT NULL PRIMARY KEY,
	product_id	integer NOT NULL REFERENCES products(id) DEFERRABLE,
-- partie options
	option_id	integer REFERENCES options(id),
	max_qty		integer CHECK (max_qty >= 1) DEFAULT NULL,
	position	integer,
-- partie ligne de texte
	description	varchar(140),
	qty		integer CHECK (qty >= 0) DEFAULT NULL
);

-- product_suppliers: fait le lien entre produits et fournisseurs
create table product_suppliers (
	id		serial NOT NULL,	-- ActiveRecord a besoin de ce champ
	product_id	integer REFERENCES products(id) DEFERRABLE,
	supplier_id	integer REFERENCES partners(id) DEFERRABLE,
	ref_fournisseur	varchar(18),
	price		decimal(6,2) NOT NULL,
	created_on	date NOT NULL default now(),
	updated_on	date NOT NULL default now(),
	UNIQUE (product_id, supplier_id)
);

-- related_products: produits associés
create table related_products (
	id		serial NOT NULL,
	relation_id	integer NOT NULL,
	product_id	integer NOT NULL REFERENCES products(id),
	UNIQUE (relation_id, product_id)
);


-- Complex products manufactured locally
create table manufactured_goods (
	id		serial NOT NULL PRIMARY KEY,
	product_id	integer NOT NULL REFERENCES products(id),
	created_on	date NOT NULL default now(),
	serial_number	varchar(13) NOT NULL UNIQUE
);

create table mg_items (
	id		serial NOT NULL PRIMARY KEY,
	owner_id	integer NOT NULL REFERENCES manufactured_goods(id),
	product_id	integer NOT NULL REFERENCES products(id),
	qty		integer NOT NULL CHECK (qty > 0)
);


-- Les humains présents chez les partenaires
create table contacts (
	id		serial NOT NULL PRIMARY KEY,
	partner_id	integer REFERENCES partners(id) DEFERRABLE,
	social_title	char(3),
	firstname	varchar(20),
	lastname	varchar(29),
	service		varchar(43),
	phone		char(16),
	mobile		char(16),
	email		varchar(42),
	mailing_wanted	boolean DEFAULT false
);

-- Les adresses de facturation ou de livraison d'un client
-- si partner_id est nul, alors c'est une adresse
-- appartenant à notre société
create table addresses (
	id		serial NOT NULL PRIMARY KEY,
	partner_id	integer REFERENCES partners(id) DEFERRABLE,
	service		varchar(38),
	addr1		varchar(45) NOT NULL,
	addr2		varchar(50),
	postcode	varchar(8) NOT NULL,
	city		varchar(40) NOT NULL,
	country_id	integer NOT NULL REFERENCES countries(id)
);

-- We can't specify these constraints before the definition of the referenced table
ALTER TABLE partners ADD FOREIGN KEY (billing_address_id) REFERENCES addresses(id) DEFERRABLE;
ALTER TABLE partners ADD FOREIGN KEY (shipping_address_id) REFERENCES addresses(id) DEFERRABLE;

create table users (
	id		serial NOT NULL PRIMARY KEY,
	partner_id	integer REFERENCES partners(id),
	login		varchar(16) NOT NULL UNIQUE,
	name		varchar(50) NOT NULL,
	hashed_password	char(40),
	email		varchar(30) NOT NULL UNIQUE,
	salt		varchar(10),
	created_at	timestamp DEFAULT now(),
	updated_at	timestamp DEFAULT now(),
	perm_invoice_w	boolean DEFAULT FALSE
);

-- Gestion des devis
create table quotations (
	id		serial NOT NULL PRIMARY KEY,
	customer_id	integer NOT NULL REFERENCES partners(id),
	created_on	date NOT NULL default now(),
	updated_on	date NOT NULL default now(),
	shipping	decimal(5,2) default NULL,
	shipping_tr	decimal(3,1) NOT NULL DEFAULT 20.0,
	user_id		integer NOT NULL REFERENCES users(id) DEFERRABLE,
	remark		text
);

create table q_items (
	id		serial NOT NULL PRIMARY KEY,
	quotation_id	integer REFERENCES quotations(id) DEFERRABLE,
	product_id	integer REFERENCES products(id),
	description	varchar(140) NOT NULL,
	qty		integer,
	price		decimal(7,2),
	vat		decimal(3,1) DEFAULT NULL,
	position	smallint,
	CONSTRAINT	qi_qty_positive CHECK (qty >= 0),
	CONSTRAINT	qi_price_positive CHECK (price >= 0)
);

-- Gestion des commandes client
create table orders (
	id		serial NOT NULL PRIMARY KEY,
	quotation_id	integer REFERENCES quotations(id) DEFERRABLE,
	order_num	varchar(16),
	order_date	date NOT NULL,
	order_comment	varchar(46),
	canceled	boolean DEFAULT false
);

-- Gestion des bons de livraison
create table delivery_slips (
	id		serial NOT NULL PRIMARY KEY,
	order_id	integer NOT NULL REFERENCES orders(id) DEFERRABLE,
	address_id	integer NOT NULL REFERENCES addresses(id) DEFERRABLE,
	created_on	date NOT NULL default now(),
	cancelled	boolean NOT NULL DEFAULT false
);

-- Gestion des factures et bons de livraison
create table invoices (
	id		serial NOT NULL PRIMARY KEY,
	public_id	varchar(10) NOT NULL UNIQUE,
	order_id	integer REFERENCES orders(id) DEFERRABLE,
	ds_id		integer REFERENCES delivery_slips(id) UNIQUE,
	address_id	integer NOT NULL REFERENCES addresses(id) DEFERRABLE,
	created_on	date NOT NULL default now(),
	due_date	date DEFAULT NULL,
	paiement_date	date DEFAULT NULL,
	advance		decimal(7,2) DEFAULT NULL,
	shipping	decimal(5,2) default NULL,
	is_credit_note	boolean DEFAULT FALSE
);

-- Accounting charges
create table charges (
	id		serial NOT NULL PRIMARY KEY,
	created_on	date NOT NULL default now(),
	supplier_id	integer NOT NULL REFERENCES partners(id),
	amount		decimal(5,2) NOT NULL
);

create table ds_items (
	id			serial NOT NULL PRIMARY KEY,
	delivery_slip_id	integer NOT NULL REFERENCES delivery_slips(id),
	q_item_id		integer NOT NULL REFERENCES q_items(id) DEFERRABLE,
	qty			integer NOT NULL DEFAULT 1,
	CONSTRAINT		positive_qty CHECK (qty > 0),
	CONSTRAINT		dsi_unique_qitem_line UNIQUE (q_item_id, delivery_slip_id)
);

-- Gestion des commandes fournisseur
create table supplier_orders (
	id			serial NOT NULL PRIMARY KEY,
	supplier_id		integer NOT NULL REFERENCES partners(id) DEFERRABLE,
	shipping_address_id	integer NOT NULL REFERENCES addresses(id),
	created_on		date NOT NULL default now(),
	shipping		decimal(5,2) default NULL,
	shipping_tr		decimal(3,1) NOT NULL DEFAULT 20.0,
	remark			text
);

create table so_items (
	id			serial NOT NULL PRIMARY KEY,
	supplier_order_id	integer REFERENCES supplier_orders(id) DEFERRABLE,
	ref			varchar(18),
	product_id		integer REFERENCES products(id),
	description		varchar(140) NOT NULL,
	qty			integer,
	price			decimal(7,2),
	vat			decimal(3,1) DEFAULT NULL,
	position		smallint,
	CONSTRAINT		positive_qty CHECK (qty > 0),
	CONSTRAINT		positive_price CHECK (price > 0),
	CONSTRAINT		unique_product_line UNIQUE (product_id, supplier_order_id)
);

-- Historique clients et fournisseurs
create table events (
	id			serial NOT NULL PRIMARY KEY,
	partner_id		integer,
	created_on		date NOT NULL default now(),
	blah			text
);

-- Gestion des stocks
create table locations (
	id			serial NOT NULL PRIMARY KEY,
	name			varchar(40) NOT NULL,
	created_on		date NOT NULL default now()
);

create table receptions (
	id			serial NOT NULL PRIMARY KEY,
	supplier_id		integer NOT NULL REFERENCES partners(id) DEFERRABLE,
	supplier_order_id	integer REFERENCES supplier_orders(id),
	location_id		integer NOT NULL REFERENCES locations(id) DEFERRABLE,
	created_on		date NOT NULL default now(),
	comment			text
);

create type reception_status AS enum ('ok','canceled');

create table reception_items (
	id		serial NOT NULL PRIMARY KEY,
	reception_id	integer NOT NULL REFERENCES receptions(id) DEFERRABLE,
	product_id	integer REFERENCES products(id),
	description	varchar(140),
	qty		integer NOT NULL CHECK (qty > 0) DEFAULT 1,
	status		reception_status NOT NULL DEFAULT 'ok',
	serials		text
);

create table stocks (
	id		serial NOT NULL PRIMARY KEY,
	location_id	integer NOT NULL REFERENCES locations(id),
	product_id	integer NOT NULL REFERENCES products(id),
	qty		integer NOT NULL,
	CONSTRAINT	stocks_product_line_uk UNIQUE (product_id, location_id)
);


-- Expense reports management
create table expense_reports (
	id		serial NOT NULL PRIMARY KEY,
	created_on	date NOT NULL default now(),
	user_id		integer REFERENCES users(id),
	paid_on		date
);

create table er_items (
	id		serial NOT NULL PRIMARY KEY,
	er_id		integer NOT NULL REFERENCES expense_reports(id),
	expense_date	date NOT NULL,
	description	varchar(40) NOT NULL,
	vendor		varchar(30) NOT NULL,
	payment_type	varchar(15) NOT NULL,
	amount		decimal(5,2) NOT NULL,
	vat		decimal(4,2) NOT NULL DEFAULT 0.0
);


-- Interventions
-- Used to regroup many small jobs on a global invoice
create table interventions (
	id		serial NOT NULL PRIMARY KEY,
	created_at	timestamp(0) NOT NULL default now(),
	ended_at	timestamp(0) NOT NULL default now(),
	customer_id	integer NOT NULL REFERENCES partners(id),
	summary		varchar(40) NOT NULL,
	description	text,
	-- eventual travel distance in km
	travel		integer,
	-- has an invoice been emitted ?
	charged		boolean DEFAULT FALSE
);

-- global application settings
create table settings (
	id		serial NOT NULL PRIMARY KEY,
	name		varchar(20) NOT NULL UNIQUE,
	value		text
);

COMMIT;
