USE master
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'SWP391_WarehouseManagements')
BEGIN
	DROP DATABASE SWP391_WarehouseManagements
END
CREATE DATABASE SWP391_WarehouseManagements;

USE SWP391_WarehouseManagements
GO

CREATE TABLE Roles
(
	role_id INT IDENTITY(1,1) PRIMARY KEY,
	role_name VARCHAR(255) NOT NULL UNIQUE,
	description VARCHAR(1000) NULL
)

CREATE TABLE Features
(
	feature_id INT IDENTITY(1,1) PRIMARY KEY,
	feature_name VARCHAR(100) NOT NULL UNIQUE,
	description VARCHAR(1000) NULL
)

CREATE TABLE Feature_role
(
	role_id INT REFERENCES Roles(role_id),
	feature_id INT REFERENCES Features(feature_id),
	PRIMARY KEY(role_id, feature_id),
)

CREATE TABLE Users
(
	user_id INT IDENTITY(1,1) PRIMARY KEY,
	email VARCHAR(255) NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
	fullname VARCHAR(255) NOT NULL,
	phone VARCHAR(20) NOT NULL,
	address VARCHAR(255) NOT NULL,
	sec_address VARCHAR(255) NULL,
	role_id INT NULL REFERENCES Roles(role_id),
	is_actived BIT DEFAULT 0,
	is_deleted BIT DEFAULT 0,
)

CREATE TABLE Positions
(
	position_id INT IDENTITY(1,1) PRIMARY KEY,
	position_name VARCHAR(100) NOT NULL,
	description VARCHAR(1000) NULL,
)

CREATE TABLE Employees
(
	employee_id INT IDENTITY(1,1) PRIMARY KEY,
	user_id INT NOT NULL REFERENCES Users(user_id),
	employee_code VARCHAR(50) NOT NULL UNIQUE,
	fullname VARCHAR(255) NOT NULL,
	phone VARCHAR(20) NOT NULL,
	hire_date DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	position_id INT NOT NULL REFERENCES Positions(position_id),
	bank_account VARCHAR(100) NULL,
	is_activated BIT DEFAULT 1
)

CREATE TABLE Product_specs
(
	spec_id INT IDENTITY(1,1) PRIMARY KEY,
	cpu VARCHAR(255) NOT NULL,
	memory VARCHAR(255) NOT NULL,
	storage VARCHAR(255) NOT NULL,
	battery_capacity INT NOT NULL,
	color VARCHAR(50) NOT NULL
)

CREATE TABLE Brands
(
	brand_id INT IDENTITY(1,1) PRIMARY KEY,
	brand_name VARCHAR(100) NOT NULL UNIQUE,
)

CREATE TABLE Product_types
(
	type_id INT IDENTITY(1,1) PRIMARY KEY,
	type_name VARCHAR(100) NOT NULL UNIQUE,
)

CREATE TABLE Products
(
	product_id INT IDENTITY(1,1) PRIMARY KEY,
	product_name VARCHAR(255) NOT NULL,
	brand_id INT NOT NULL REFERENCES Brands(brand_id),
	spec_id INT NOT NULL REFERENCES Product_specs(spec_id),
	type_id INT NOT NULL REFERENCES Product_types(type_id),
	description VARCHAR(1000) NULL,
	created_at DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE)
)

CREATE TABLE Product_units
(
	unit_id	INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT NOT NULL REFERENCES Products(product_id),
	status VARCHAR(50) NOT NULL,
	warranty_end_date DATETIME NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE)
)

CREATE TABLE Product_images
(
	image_id INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT NOT NULL REFERENCES Products(product_id),
	image_url VARCHAR(500) NOT NULL,
	alt_text VARCHAR(255) NULL
)

CREATE TABLE Warehouse_locations
(
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	code VARCHAR(255) NOT NULL UNIQUE,
	area VARCHAR(50) NOT NULL,
	aisle VARCHAR(50) NOT NULL,
	slot VARCHAR(50) NOT NULL,
	max_capacity INT NOT NULL,
	current_capacity INT NOT NULL,
	description VARCHAR(1000) NULL
)

CREATE TABLE Inventory_records
(
	inventory_id INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT NOT NULL REFERENCES Products(product_id),
	location_id INT NOT NULL REFERENCES Warehouse_locations(location_id),
	qty INT NOT NULL,
	last_updated DATETIME
)

CREATE TABLE Suppliers
(
	supplier_id INT IDENTITY(1,1) PRIMARY KEY,
	supplier_name VARCHAR(100) NOT NULL,
	address VARCHAR(255) NOT NULL,
	phone VARCHAR(20) NOT NULL,
	email VARCHAR(255) NOT NULL,
	representative VARCHAR(255) NOT NULL,
	payment_method VARCHAR(100) NOT NULL,
	note VARCHAR(1000) NULL,
)

CREATE TABLE Purchase_orders
(
	po_id INT IDENTITY(1,1) PRIMARY KEY,
	po_code VARCHAR(100) NOT NULL UNIQUE,
	supplier_id INT NOT NULL REFERENCES Suppliers(supplier_id),
	created_by INT NOT NULL REFERENCES Employees(employee_id),
	created_at DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	status VARCHAR(50) CHECK(status IN ('ACTIVE', 'INACTIVE', 'ONBOARDING'))NOT NULL ,
	total_amount INT NOT NULL,
)

CREATE TABLE Purchase_order_lines
(
	po_line_id INT IDENTITY(1,1) PRIMARY KEY,
	po_id INT NOT NULL REFERENCES Purchase_orders(po_id),
	product_id INT NOT NULL REFERENCES Products(product_id),
	unit_price FLOAT NOT NULL,
	qty INT NOT NULL,
	line_amount FLOAT NOT NULL,
	total_amount INT NOT NULL,
)

CREATE TABLE Inbound_inventory
(
	inbound_id INT IDENTITY(1,1) PRIMARY KEY,
	inbound_code VARCHAR(100) UNIQUE,
	supplier_id INT NOT NULL REFERENCES Suppliers(supplier_id),
	po_id INT NULL REFERENCES Purchase_orders(po_id),
	received_by INT NOT NULL REFERENCES Employees(employee_id),
	received_at DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	note VARCHAR(1000) NULL,
)

CREATE TABLE Outbound_inventory
(
	outbound_id INT IDENTITY(1,1) PRIMARY KEY,
	outbound_code VARCHAR(100) UNIQUE,
	customer_name VARCHAR(255),
	created_by INT NOT NULL REFERENCES Employees(employee_id),
	created_at DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	note VARCHAR(1000) NULL,
)

CREATE TABLE Inventory_transactions
(
	tx_id INT IDENTITY(1,1) PRIMARY KEY,
	tx_type VARCHAR(25) CHECK(tx_type IN('Inbound', 'Outbound', 'Moving', 'Destroy')),
	product_id INT NOT NULL REFERENCES Products(product_id),
	unit_id INT NOT NULL REFERENCES Product_units(unit_id),
	qty INT NOT NULL,
	from_location INT NULL REFERENCES Warehouse_locations(location_id),
	to_location INT NULL REFERENCES Warehouse_locations(location_id),
	ref_code VARCHAR(100) NOT NULL,
	related_inbound_id INT NULL REFERENCES Inbound_inventory(inbound_id),
	related_outbound_id INT NULL REFERENCES Outbound_inventory(outbound_id),
	employee_id INT NOT NULL REFERENCES Employees(employee_id),
	txdate DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	note VARCHAR(1000) NULL
)

CREATE TABLE Inbound_lines
(
	inbound_line_id INT IDENTITY(1,1) PRIMARY KEY,
	inbound_id INT NOT NULL REFERENCES Inbound_inventory(inbound_id),
	product_id INT NOT NULL REFERENCES Products(product_id),
	unit_id INT NOT NULL REFERENCES Product_units(unit_id),
	qty INT NOT NULL,
	unit_price FLOAT NOT NULL,
)

CREATE TABLE Outbound_lines
(
	outbound_line_id INT IDENTITY(1,1) PRIMARY KEY,
	outbound_id INT NOT NULL REFERENCES Inbound_inventory(inbound_id),
	product_id INT NOT NULL REFERENCES Products(product_id),
	unit_id INT NOT NULL REFERENCES Product_units(unit_id),
	qty INT NOT NULL,
	unit_price FLOAT NOT NULL,
)

CREATE TABLE Quality_controls
(
	qc_id INT IDENTITY(1,1) PRIMARY KEY,
	unit_id INT NULL REFERENCES Product_units(unit_id),
	inbound_line_id INT NULL REFERENCES Inbound_lines(inbound_line_id),
	inspector_id INT NOT NULL REFERENCES Employees(employee_id),
	qc_date DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	state VARCHAR(50) NOT NULL,
	error VARCHAR(255) NULL,
	remarks VARCHAR(255) NULL,
)

CREATE TABLE Shifts
(
	shift_id INT IDENTITY(1,1) PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	start_time DATETIME NOT NULL,
	end_time DATETIME NOT NULL,
	note VARCHAR(1000) NULL
)

CREATE TABLE Shift_assignments
(
	assign_id INT IDENTITY(1,1) PRIMARY KEY,
	shift_id INT NOT NULL REFERENCES Shifts(shift_id),
	employee_id INT NOT NULL REFERENCES Employees(employee_id),
	assign_date DATETIME NOT NULL,
	location_id INT REFERENCES Warehouse_locations(location_id),
	role_in_shift VARCHAR(100) NOT NULL,
)

CREATE TABLE Attendances
(
	attendance_id INT IDENTITY(1,1) PRIMARY KEY,
	assign_id INT NOT NULL REFERENCES Shift_assignments(assign_id),
	employee_id INT NOT NULL REFERENCES Employees(employee_id),
	check_in DATETIME NOT NULL,
	check_out DATETIME NOT NULL,
	hours_worked FLOAT NOT NULL,
	note VARCHAR(1000) NULL,
)

CREATE TABLE Payrolls
(
	payroll_id INT IDENTITY(1,1) PRIMARY KEY,
	employee_id INT NOT NULL REFERENCES Employees(employee_id),
	period_start DATETIME NOT NULL,
	period_end DATETIME NOT NULL,
	gross_amount FLOAT NOT NULL,
	net_amount FLOAT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CAST(GETDATE() AS DATE)
)

CREATE TABLE Salary_components
(
	comp_id INT IDENTITY(1,1) PRIMARY KEY,
	payroll_id INT NOT NULL REFERENCES Payrolls(payroll_id),
	comp_type VARCHAR(50) NOT NULL,
	amount FLOAT NOT NULL,
)