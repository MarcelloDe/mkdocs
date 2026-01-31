/*******************************************************
I, Marcello De Filippis, student number 000823174, certify that this material is my original work. No other person's work has been used without due acknowledgment and I have not made my work available to anyone else.
Script: lab7.txt
Author: Marcello De Filippis
Date: November 29 2022
Description: Create Triggers INSERT UPDATE DELETE
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

-- Create service description table
CREATE TABLE media_services (
  service_id INT PRIMARY KEY, 
  service_description VARCHAR(25), 
  service_type CHAR(1) CHECK (service_type IN ('E', 'F', 'G')), 
  flat_fee MONEY,
  sales_ytd MONEY); 

-- Create sales table
CREATE TABLE sales (
	sales_id INT PRIMARY KEY, 
	sales_date DATE, 
	amount MONEY, 
	service_id INT FOREIGN KEY REFERENCES media_services(service_id));
GO

-- Insert service description 
INSERT INTO media_services VALUES(100, '1 hour photo', 'E', 200, 1750);
INSERT INTO media_services VALUES(200, 'branding session', 'G', 300, 600);
INSERT INTO media_services VALUES(300, 'video', 'F', 150, 3000);
INSERT INTO media_services VALUES(400, 'website building', 'E', 500, 1500);
INSERT INTO media_services VALUES(500, 'content creation', 'G', 300, 600);

-- Insert sales records
INSERT INTO sales VALUES(1, '2022-05-04', 500, 400);    -- Month and day don't have to be 2 digits
INSERT INTO sales VALUES(2, '2022-04-09', 300, 500); -- But they typically are
INSERT INTO sales VALUES(3, '2022-05-25', 900, 300);
INSERT INTO sales VALUES(4, '2022-05-20', 200, 100);
INSERT INTO sales VALUES(5, '2022-05-30', 500, 400);
INSERT INTO sales VALUES(6, '2022-06-14', 600, 300);
INSERT INTO sales VALUES(7, '2022-06-18', 600, 100);
INSERT INTO sales VALUES(8, '2022-07-01', 300, 200);
INSERT INTO sales VALUES(9, '2022-07-12', 900, 300);
INSERT INTO sales VALUES(10, '2022-07-22', 800, 100);
INSERT INTO sales VALUES(11, '2022-08-03', 300, 500);
INSERT INTO sales VALUES(12, '2022-08-16', 500, 400);
INSERT INTO sales VALUES(13, '2022-09-09', 600, 300);
INSERT INTO sales VALUES(14, '2022-09-10', 150, 100);
INSERT INTO sales VALUES(15, '2022-09-19', 300, 200);
GO

-- Creating an Index
CREATE INDEX IX_media_services_service_description
ON media_services (service_description);
GO


-- Creating a View 
CREATE VIEW high_end_media_services
AS
SELECT service_id, SUBSTRING(service_description, 1, 15) AS description_, sales_ytd
FROM media_services
WHERE flat_fee > (SELECT AVG(flat_fee)
 FROM media_services);
GO 

-- Verify inserts
CREATE TABLE verify (  
  table_name varchar(30), 
  actual INT, 
  expected INT);
GO

INSERT INTO verify VALUES('media_services', (SELECT COUNT(*) FROM media_services), 5);
INSERT INTO verify VALUES('sales', (SELECT COUNT(*) FROM sales), 15);
PRINT 'Verification';
SELECT table_name, actual, expected, expected - actual discrepancy FROM verify;
DROP TABLE verify;
GO

-- Lab 7 Triggers

CREATE TRIGGER media_services_salesytd_insert
   ON  sales
   AFTER INSERT
AS
BEGIN
     UPDATE media_services
     SET sales_ytd = sales_ytd + (SELECT amount FROM inserted)
     WHERE media_services.service_id = (SELECT service_id FROM inserted);
END
GO

CREATE TRIGGER mediaservices_salesytd_delete
   ON  sales
   AFTER INSERT
AS
BEGIN
     UPDATE media_services
     SET sales_ytd = sales_ytd - (SELECT amount FROM inserted)
     WHERE media_services.service_id = (SELECT service_id FROM inserted);
END
GO

CREATE TRIGGER media_services_salesytd_update
   ON  sales
   AFTER UPDATE
AS
    DECLARE @old_sales_ytd MONEY;
    DECLARE @new_sales_ytd MONEY;
    
BEGIN
    SET @old_sales_ytd = (SELECT amount FROM deleted)
    SET @new_sales_ytd = (SELECT amount FROM inserted)
    IF @new_sales_ytd <= 0
            ROLLBACK TRANSACTION;
    UPDATE media_services
    SET sales_ytd = sales_ytd + (@new_sales_ytd - @old_sales_ytd)
    WHERE media_services.service_id = (SELECT service_id FROM inserted);
END
GO




-- Verification
PRINT 'Verify triggers'


PRINT 'Master Table Before Changes'
--SELECT all rows and columns from the master table
SELECT * FROM media_services

--INSERT a row into the sales table (ensure transaction amount is not zero, pick a large or unusual amount)
INSERT INTO sales( sales_id, amount, service_id)
VALUES (16, 200, 100);

PRINT 'After INSERT'
--SELECT all rows and columns from the master table
SELECT * FROM media_services;

--DELETE the row that just got inserted in the sales table
DELETE FROM sales WHERE sales_id = 16;

PRINT 'After DELETE'


--SELECT all rows and columns from the master table
SELECT * FROM media_services;

--UPDATE the transaction amount in one row in the sales table (ensure transaction amount is not zero, pick a large or unusual amount, this will make it stand out in the output)
UPDATE sales
SET amount = 200
WHERE sales_id = 4;


PRINT 'After UPDATE'
--SELECT all rows and columns from the master table
SELECT * FROM media_services;


