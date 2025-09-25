USE master
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'SWP391_WarehouseManagements')
BEGIN
	DROP DATABASE SWP391_WarehouseManagements
END
CREATE DATABASE SWP391_WarehouseManagements;

USE SWP391_WarehouseManagements
GO

CREATE TABLE dbo.Roles
(
	role_id INT IDENTITY(1,1) PRIMARY KEY,
	role_name VARCHAR(255) NOT NULL,
)

CREATE TABLE dbo.Features
(
	feature_id INT IDENTITY(1,1) PRIMARY KEY,
	feature_name VARCHAR(255) NOT NULL,
	description VARCHAR(1000) NULL,
)

CREATE TABLE dbo.Users
(
	user_id BIGINT IDENTITY(1, 1) PRIMARY KEY,
	fullname VARCHAR(255) NOT NULL,
	password_hash VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	address VARCHAR(255) NOT NULL,
	second_address VARCHAR(255) NULL,
	user_picture VARCHAR(255) NULL,
	is_active BIT NOT NULL DEFAULT(1),
	is_deleted BIT NOT NULL DEFAULT(0),
	role_id INT NOT NULL,
	FOREIGN KEY(role_id) REFERENCES dbo.Roles(role_id)
)

CREATE TABLE dbo.Feature_Role
(
	role_id INT,
	feature_id INT,
	CONSTRAINT PK_feature_role PRIMARY KEY(role_id, feature_id),
	FOREIGN KEY(feature_id) REFERENCES dbo.Features(feature_id),
	FOREIGN KEY(role_id) REFERENCES dbo.Roles(role_id)
)

CREATE TABLE dbo.Bonus
(
	bonus_id INT IDENTITY(1,1) PRIMARY KEY,
	bonus_name INT NOT NULL
)

CREATE TABLE dbo.Employees
(
	employee_id VARCHAR(255) PRIMARY KEY,
	user_id BIGINT NOT NULL,
	is_active BIT NOT NULL DEFAULT(1),
	FOREIGN KEY(user_id) REFERENCES dbo.Users
)

CREATE TABLE dbo.Salary
(
	employee_id VARCHAR(255) PRIMARY KEY,
	static_salary INT NOT NULL,
	start_time DATETIME NOT NULL,
	end_time DATETIME NOT NULL,
	bonus_id INT NOT NULL,
	description VARCHAR(1000) NULL,

	FOREIGN KEY(bonus_id) REFERENCES dbo.Bonus(bonus_id),
	FOREIGN KEY(employee_id) REFERENCES dbo.Employees(employee_id)
)

CREATE TABLE dbo.Work_schedule
(
	time_id INT IDENTITY(1,1) PRIMARY KEY,
	employee_id VARCHAR(255) NOT NULL,
	start_time DATETIME NOT NULL,
	end_time DATETIME NOT NULL,
	updater VARCHAR(255) NOT NULL,
	day_update DATETIME2 NOT NULL,
	place_id INT NOT NULL,

	FOREIGN KEY(employee_id) REFERENCES dbo.Employees(employee_id),
)

CREATE TABLE dbo.Products
(
	product_id BIGINT IDENTITY(1,1) PRIMARY KEY,
	product_name VARCHAR(255) NOT NULL,
	brand_id INT NOT NULL,
	amount INT NOT NULL,
	price INT NOT NULL,
	status VARCHAR(255) NOT NULL,
)

CREATE TABLE dbo.Product_Amount
(
	product_id BIGINT PRIMARY KEY,
	amount INT NOT NULL,
	actural INT NOT NULL,
	description VARCHAR(1000) NULL,
	check_date DATETIME,
	employee_id VARCHAR(255),

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id),
	FOREIGN KEY(employee_id) REFERENCES dbo.Employees(employee_id),
)

CREATE TABLE dbo.Product_Spec
(
	product_id BIGINT PRIMARY KEY,
	color VARCHAR(255) NOT NULL,
	memory INT NOT NULL,
	size INT NOT NULL,
	battery_capacity INT NOT NULL,
	CPU VARCHAR(255) NOT NULL,

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id),
)

CREATE TABLE dbo.Brand
(
	brand_id INT IDENTITY(1,1) PRIMARY KEY,
	brand_name VARCHAR(255) NOT NULL,
	product_id BIGINT NOT NULL,

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id)
)

CREATE TABLE dbo.Product_Image
(
	product_id BIGINT NOT NULL,
	imageURL varchar(255) NULL,

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id)
)

CREATE TABLE dbo.Type_of_product
(
	type_id INT IDENTITY(1,1) PRIMARY KEY,
	type_name VARCHAR(255) NOT NULL,
	product_id BIGINT NOT NULL,

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id)
)

CREATE TABLE dbo.Quality_control
(
	product_id BIGINT PRIMARY KEY,
	state VARCHAR(255) NOT NULL,
	error VARCHAR(1000) NOT NULL,
	check_date DATETIME NOT NULL,
	check_result VARCHAR(1000) NOT NULL,
	warranty VARCHAR(255) NOT NULL,

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id)
)

CREATE TABLE dbo.Inventory
(
	inventory_id VARCHAR(255) PRIMARY KEY,
	stage_id VARCHAR(255) NOT NULL,
	product_id BIGINT NOT NULL,
	amount INT NOT NULL,
	inbound_date DATETIME NOT NULL,
	check_date DATETIME NOT NULL,

	FOREIGN KEY(product_id) REFERENCES dbo.Products(product_id)
)

CREATE TABLE dbo.Supplier
(
	supplier_id INT IDENTITY(1,1) PRIMARY KEY,
	supplier_name VARCHAR(255) NOT NULL,
	address VARCHAR(255) NOT NULL,
	phone_number VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL,
	represent VARCHAR(255) NOT NULL,
	status VARCHAR(255) NOT NULL,
	type_id INT NOT NULL,
	payment_method VARCHAR(255) NOT NULL,
)

CREATE TABLE dbo.Inbound_INV
(
	inbound_code BIGINT IDENTITY(1,1) PRIMARY KEY,
	inbound_date DATETIME NOT NULL,
	supplier_id INT NOT NULL,
	product_id BIGINT NOT NULL,
	product_name VARCHAR(255) NOT NULL,
	employee_id VARCHAR(255) NOT NULL,
	type_id INT NOT NULL,
	amount INT NOT NULL,
	price FLOAT NOT NULL,
	COST FLOAT NOT NULL,

	FOREIGN KEY(employee_id) REFERENCES dbo.Employees(employee_id),
	FOREIGN KEY(supplier_id) REFERENCES dbo.Supplier(supplier_id),
)

CREATE TABLE dbo.Outbound_INV
(
	outbound_code BIGINT IDENTITY(1,1) PRIMARY KEY,
	outbound_date DATETIME NOT NULL,
	customer_name VARCHAR(255) NOT NULL,
	product_id BIGINT NOT NULL,
	product_name VARCHAR(255) NOT NULL,
	employee_id VARCHAR(255) NOT NULL,
	type_id INT NOT NULL,
	amount INT NOT NULL,
	price FLOAT NOT NULL,
	COST FLOAT NOT NULL,

	FOREIGN KEY(employee_id) REFERENCES dbo.Employees(employee_id)
)

