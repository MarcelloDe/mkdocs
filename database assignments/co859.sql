/*******************************************************
Script: co859.sql
Author: Brian Minaji
Date: July 2022
Description: Create co859 Database objects for Dr. Darla
********************************************************/

-- Setting NOCOUNT ON suppresses completion messages for each INSERT
SET NOCOUNT ON

-- Set date format to year, month, day
SET DATEFORMAT ymd;

-- Make the master database the current database
USE master

-- If database co859 exists, drop it
IF EXISTS (SELECT * FROM sysdatabases WHERE name = 'co859')
BEGIN
  ALTER DATABASE co859 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE co859;
END
GO

-- Create the co859 database
CREATE DATABASE co859;
GO

-- Make the co859 database the current database
USE co859;

-- Create dental_services table
CREATE TABLE dental_services (
  service_id INT PRIMARY KEY, 
  service_description VARCHAR(30), 
  service_type CHAR(1) CHECK (service_type IN ('C', 'E', 'F')), 
  hourly_rate MONEY,
  sales_ytd MONEY); 

-- Create sales table
CREATE TABLE sales (
	sales_id INT PRIMARY KEY, 
	sales_date DATE, 
	amount MONEY, 
	service_id INT FOREIGN KEY REFERENCES dental_services(service_id));
GO

-- Insert dental_services records
INSERT INTO dental_services VALUES(100, 'Extraction', 'E', 100, 300);
INSERT INTO dental_services VALUES(200, 'Cleaning - Upper', 'C', 75, 300);
INSERT INTO dental_services VALUES(300, 'Cleaning - Lower', 'C', 75, 225);
INSERT INTO dental_services VALUES(400, 'Filling', 'F', 85, 700);
INSERT INTO dental_services VALUES(500, 'Root Canal', 'F', 150, 575);

-- Insert sales records
INSERT INTO sales VALUES(1, '2022-7-6', 75, 100);    -- Month and day don't have to be 2 digits
INSERT INTO sales VALUES(2, '2022-07-08', 100, 200); -- But they typically are
INSERT INTO sales VALUES(3, '2022-07-11', 500, 400);
INSERT INTO sales VALUES(4, '2022-07-15', 150, 100);
INSERT INTO sales VALUES(5, '2022-07-21', 100, 300);
INSERT INTO sales VALUES(6, '2022-07-28', 75, 100);
INSERT INTO sales VALUES(7, '2022-08-02', 125, 500);
INSERT INTO sales VALUES(8, '2022-08-05', 300, 500);
INSERT INTO sales VALUES(9, '2022-08-10', 125, 200);
INSERT INTO sales VALUES(10, '2022-08-18', 50, 300);
INSERT INTO sales VALUES(11, '2022-08-24', 85, 400);
INSERT INTO sales VALUES(12, '2022-08-30', 115, 400);
INSERT INTO sales VALUES(13, '2022-09-03', 75, 200);
INSERT INTO sales VALUES(14, '2022-09-07', 150, 500);
INSERT INTO sales VALUES(15, '2022-09-09', 75, 300);
GO

-- Verify inserts
CREATE TABLE verify (
  table_name varchar(30), 
  actual INT, 
  expected INT);
GO

INSERT INTO verify VALUES('dental_services', (SELECT COUNT(*) FROM dental_services), 5);
INSERT INTO verify VALUES('sales', (SELECT COUNT(*) FROM sales), 15);
PRINT 'Verification';
SELECT table_name, actual, expected, expected - actual discrepancy FROM verify;
DROP TABLE verify;
GO