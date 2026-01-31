/*******************************************************
Script: lab4.txt
Author: Marcello De Filippis
Date: October 11 2022
Description: Create lab4 Database objects for mediaevolved
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


-- Lab 7 Trigger Statements

-- Let's create a practice 'test' table to use

/*SELECT sales_id, sales_date, amount, service_id INTO TestSales
FROM sales;


--Create a practice LOG table
CREATE TABLE SalesLogs(
	salesID nchar(5),
	status varchar(30)
	);

--Can we create a LOG every time something is added to the sales table?
--we create a trigger on the TestSales table when we insert into the table

CREATE TRIGGER TestSales_INSERT ON TestSales
	AFTER INSERT  -- It's going to run after INSERT
AS --Below here is where all the code goes
BEGIN
 SET NOCOUNT ON;--we are setting nocount because we want it running without people know it's running (running in the background) so we don't want to say that rows were affected
   DECLARE @SalesID nchar(5)-- Then we are declaring the Sales ID
   SELECT @SalesID = INSERTED.sales_id-- THen we are saying the salesID EQUALS the sales ID that was inserted. Take it and then throw it into the @customerID variable
   FROM INSERTED

   INSERT INTO SalesLogs
   VALUES (@SalesID, 'Inserted')
END 

--Now if you look in the programmability folder you will see the trigger you created.


--VERY IMPORTANT: AFTER RUNNING THESE STATEMNETS ABOVE THAT CREATE TABLES AND TRIGGERS SHE THEN COMMENTS THEM OUT

--NOW let's actually insert something into TestSales

INSERT INTO TestSales (sales_id,sales_date, amount, service_id) VALUES (16, '2022-10-29', 100, 400)*/

--What we inserted it should be added into our LOG table



-- Next Let's do the same thing but for DELETES and UPDATES

/*CREATE TRIGGER TestSales_DELETE ON TestSales
	AFTER DELETE  -- It's going to run after INSERT
AS --Below here is where all the code goes
BEGIN

 SET NOCOUNT ON;--we are setting nocount because we want it running without people know it's running (running in the background) so we don't want to say that rows were affected
   DECLARE @SalesID nchar(5)-- Then we are declaring the Sales ID
   SELECT @SalesID = DELETED.sales_id-- THen we are saying the salesID EQUALS the sales ID that was inserted. Take it and then throw it into the @customerID variable
   FROM DELETED

   INSERT INTO SalesLogs
   VALUES (@SalesID, 'Deleted')
END

--Now let's delete a few customers from the test customer table

DELETE FROM TestSales WHERE sales_id = 16; 


 SELECT * FROM SalesLogs




 --Finally, let's UPDATE! But let's change the message a bit so we can actually specify what was updated
 CREATE TRIGGER TestSales_UPDATE ON TestSales
	AFTER UPDATE -- It's going to run after INSERT
AS --Below here is where all the code goes
BEGIN
 SET NOCOUNT ON;--we are setting nocount because we want it running without people know it's running (running in the background) so we don't want to say that rows were affected
   DECLARE @SalesID nchar(5)
   DECLARE @Action varchar(50)--SPECIFICALLY FOR UPDATE: we delcare a SECOND variable called 'action'
   
   SELECT @SalesID = INSERTED.sales_id-- THen we are saying the salesID EQUALS the sales ID that was inserted. Take it and then throw it into the @customerID variable
   FROM INSERTED --You might ask: why are we using INSERTED? Because UPDATE and INSERTED both use the same 'INSERTED' data

   IF UPDATE (sales_id)--If sales_id was updated: what should the action be?
		SET @Action = 'Updated ID' --set the action variabled to 'updated ID'

	IF UPDATE (sales_date) -- if sales_date is updated what to set the 'action' variable to?
		SET @Action = 'Updated Date'

	If UPDATE(amount)
		SET @Action = 'Updated Amount'

   INSERT INTO SalesLogs
   VALUES (@SalesID, @ACtion)
END  */




-- =====================================================================

-- MY ATTEMPT

--TRIAL NUMBER ONE

CREATE TRIGGER mediaservices_salesYtd_INSERT ON TestSales
	AFTER INSERT  -- It's going to run after INSERT
AS --Below here is where all the code goes
BEGIN
 SET NOCOUNT ON;--we are setting nocount because we want it running without people know it's running (running in the background) so we don't want to say that rows were affected
   DECLARE @new_total -- Then we are declaring the Sales ID
   SELECT @new_total = INSERTED.amount-- THen we are saying the salesID EQUALS the sales ID that was inserted. Take it and then throw it into the @customerID variable
   FROM INSERTED
   UPDATE media_services
   SET sales_ytd =  @new_total + sales_ytd 
END 

--^ this one updated ALL the sales_ytd totals with the new 'amount' instead of just the one with the same 'service_id'

-- TRIAL NUMBER TWO
CREATE TRIGGER new_total_update
	ON TestSales
	AFTER INSERT
AS
	SET @new_total = (SELECT amount FROM INSERTED)
	UPDATE media_services
	SET sales_ytd = sales_ytd + 
		SELECT inserted 
		WHERE media_servces.service_id IN (SELECT amount FROM inserted); 




		-- =========================== DUDE HELPED ME==================


CREATE TRIGGER mediaservices_salesytd_insert
   ON  TestSales
   AFTER INSERT
AS
BEGIN
     UPDATE media_services
     SET sales_ytd = sales_ytd + (SELECT amount FROM inserted)
     WHERE media_services.service_id = (SELECT service_id FROM inserted);
END

CREATE TRIGGER mediaservices_salesytd_delete
   ON  TestSales
   AFTER INSERT
AS
BEGIN
     UPDATE media_services
     SET sales_ytd = sales_ytd - (SELECT amount FROM inserted)
     WHERE media_services.service_id = (SELECT service_id FROM inserted);
END

CREATE TRIGGER mediaservices_salesytd_update
   ON  TestSales
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

UPDATE TestSales 
SET amount = 5000000
WHERE sales_id = 20;

INSERT INTO TestSales( sales_id, amount, service_id)
VALUES (23, 9000, 100);

