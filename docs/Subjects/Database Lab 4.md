# Database Lab 4: Indexes and Views

This lab focused on modifying an existing database creation script, adding indexes for performance optimization, and creating views to provide filtered perspectives on data. The assignment required working with master and sales tables, implementing proper indexing strategies, and using views with subqueries to highlight high-end services.

## Assignment Overview

The lab required students to:
- Take an existing database creation script and modify it for custom tables and columns
- Add an index creation to the script for an attribute in the master table
- Add a view creation to the script that highlights the most expensive elements

## Script Modification

### Environment Setup

The script begins by setting up the database environment:

```sql
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
```

**Key Points:**
- `SET DATEFORMAT ymd` ensures dates are interpreted correctly for the sales record inserts
- The script checks for existing database and drops it if present to allow clean recreation
- `GO` statements are used throughout to separate batches of SQL statements

### Database Creation

```sql
-- Create the co859 database
CREATE DATABASE co859;
GO

-- Make the co859 database the current database
USE co859;
```

## Master Table: media_services

For this lab, I created a master table named `media_services` to represent services offered by the mediaevolved business. The table structure includes:

```sql
CREATE TABLE media_services (
  service_id INT PRIMARY KEY, 
  service_description VARCHAR(25), 
  service_type CHAR(1) CHECK (service_type IN ('E', 'F', 'G')), 
  flat_fee MONEY,
  sales_ytd MONEY); 
```

**Table Design:**
- **service_id**: Primary key uniquely identifying each service
- **service_description**: Brief description of the service (25 characters)
- **service_type**: Single character code ('E', 'F', or 'G') with CHECK constraint
- **flat_fee**: The base price for the service
- **sales_ytd**: Year-to-date sales for tracking performance

**Business Context:**
The mediaevolved business offers various media-related services including photography, video production, branding, website building, and content creation.

## Sales Table

The sales table tracks individual sales transactions:

```sql
CREATE TABLE sales (
	sales_id INT PRIMARY KEY, 
	sales_date DATE, 
	amount MONEY, 
	service_id INT FOREIGN KEY REFERENCES media_services(service_id));
GO
```

**Table Design:**
- **sales_id**: Primary key for each sale
- **sales_date**: Date when the sale occurred
- **amount**: The sale amount
- **service_id**: Foreign key linking to the media_services table

**Relationship:**
The sales table has a one-to-many relationship with media_services, where one service can have many sales records.

## Loading the Master Table

The master table was populated with 5 service records:

```sql
INSERT INTO media_services VALUES(100, '1 hour photo', 'E', 200, 1750);
INSERT INTO media_services VALUES(200, 'branding session', 'G', 300, 600);
INSERT INTO media_services VALUES(300, 'video', 'F', 150, 3000);
INSERT INTO media_services VALUES(400, 'website building', 'E', 500, 1500);
INSERT INTO media_services VALUES(500, 'content creation', 'G', 300, 600);
```

**Service Breakdown:**
- Service 100: 1 hour photo (Type E) - $200 flat fee, $1,750 YTD sales
- Service 200: Branding session (Type G) - $300 flat fee, $600 YTD sales
- Service 300: Video (Type F) - $150 flat fee, $3,000 YTD sales
- Service 400: Website building (Type E) - $500 flat fee, $1,500 YTD sales
- Service 500: Content creation (Type G) - $300 flat fee, $600 YTD sales

## Loading the Sales Table

The sales table was populated with 15 sales records spanning from May to September 2022:

```sql
INSERT INTO sales VALUES(1, '2022-05-04', 500, 400);    
INSERT INTO sales VALUES(2, '2022-04-09', 300, 500); 
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
```

**Sales Analysis:**
- Sales range from $150 to $900
- Most sales occurred in May-July 2022
- Service 300 (video) appears frequently in high-value sales
- Service 400 (website building) also has multiple sales entries

## Creating an Index

Indexes improve query performance by allowing the DBMS to find data faster without scanning every row. Since the master table is a services table, I created an index on the `service_description` column, which would be commonly used for searching and filtering services.

```sql
-- Creating an Index
CREATE INDEX IX_media_services_service_description
ON media_services (service_description);
GO
```

**Index Details:**
- **Naming Convention**: `IX_media_services_service_description` follows the pattern `IX_table_name_column_name`
- **Purpose**: Speeds up queries that filter or search by service description
- **Considerations**: Since service descriptions are likely unique, this index will help with both exact matches and pattern searches

**When Indexes Help:**
- Queries filtering by service description: `WHERE service_description = 'video'`
- Pattern matching: `WHERE service_description LIKE 'website%'`
- Sorting operations: `ORDER BY service_description`

**Trade-offs:**
- Indexes speed up SELECT queries
- Indexes slightly slow down INSERT, UPDATE, and DELETE operations (index must be maintained)
- Indexes consume additional storage space

## Creating a View

Views provide a virtual table that presents data in a specific, filtered format. The assignment required creating a view named `high_end_<master>` that highlights the most expensive services.

```sql
-- Creating a View 
CREATE VIEW high_end_media_services
AS
SELECT service_id, SUBSTRING(service_description, 1, 15) AS description_, sales_ytd
FROM media_services
WHERE flat_fee > (SELECT AVG(flat_fee)
 FROM media_services);
GO 
```

**View Components:**

1. **View Name**: `high_end_media_services` - follows the naming convention `high_end_<master>`

2. **SUBSTRING Function**: 
   - `SUBSTRING(service_description, 1, 15) AS description_`
   - Extracts the first 15 characters of the service description
   - Column alias `description_` is required when using functions in views

3. **Nested Subquery**:
   - `WHERE flat_fee > (SELECT AVG(flat_fee) FROM media_services)`
   - Filters to show only services where the flat fee is greater than the average flat fee
   - The subquery calculates the average flat fee across all services

**View Results:**
Based on the data:
- Average flat fee: (200 + 300 + 150 + 500 + 300) / 5 = $290
- Services with flat_fee > $290: Service 200 ($300), Service 400 ($500), Service 500 ($300)
- The view would display these high-end services with truncated descriptions and their YTD sales

**Using the View:**
```sql
-- Query the view like a regular table
SELECT * FROM high_end_media_services;

-- Expected output:
-- service_id | description_    | sales_ytd
-- 200        | branding sessio | 600.00
-- 400        | website buildin | 1500.00
-- 500        | content creatio | 600.00
```

**Benefits of This View:**
- Simplifies complex queries for end users
- Provides a consistent way to identify premium services
- Automatically updates when underlying data changes
- Hides implementation details (the subquery logic)

## Verification

The script includes verification code to ensure all inserts were successful:

```sql
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
```

**Verification Process:**
1. Creates a temporary verification table
2. Compares actual record counts with expected counts
3. Displays any discrepancies
4. Cleans up by dropping the verification table

**Expected Results:**
- media_services: 5 records (actual = expected)
- sales: 15 records (actual = expected)
- Discrepancy should be 0 for both tables

## Key Learning Outcomes

### Indexes
- **Purpose**: Improve query performance on frequently searched columns
- **Best Practices**: 
  - Create indexes on columns used in WHERE clauses
  - Use descriptive naming conventions
  - Consider the trade-off between read and write performance

### Views
- **Purpose**: Provide simplified, filtered access to data
- **Features**:
  - Can use functions like SUBSTRING with column aliases
  - Can include subqueries for complex filtering
  - Automatically reflect changes in underlying tables
- **Use Cases**: 
  - Simplifying complex queries
  - Providing security (hiding sensitive columns)
  - Presenting data in user-friendly formats

### Subqueries
- **Nested Subqueries**: Used in WHERE clauses to filter based on calculated values
- **Aggregate Functions**: AVG() calculates average values for comparison
- **Correlation**: The subquery can reference the outer query's table

## Complete Script Structure

The complete lab script follows this structure:

1. **Header Comments**: Author, date, description
2. **Environment Setup**: Date format, database selection
3. **Database Management**: Drop existing, create new
4. **Table Creation**: Master table (media_services) and sales table
5. **Data Loading**: INSERT statements for both tables
6. **Performance Optimization**: CREATE INDEX statement
7. **Data Presentation**: CREATE VIEW statement
8. **Verification**: Record count verification
9. **Cleanup**: Drop temporary verification table

## Business Application

This lab demonstrates real-world database administration tasks:

- **Database Scripting**: Creating reusable scripts for database setup
- **Performance Tuning**: Adding indexes to optimize common queries
- **Data Presentation**: Creating views for business users to access filtered data
- **Data Quality**: Implementing verification checks to ensure data integrity

The `high_end_media_services` view could be used by:
- Sales teams to identify premium service offerings
- Management to analyze high-value service performance
- Marketing teams to promote premium services
- Reporting systems to generate executive summaries

## Conclusion

Lab 4 successfully demonstrated:
- ✅ Modification of database creation scripts
- ✅ Proper table design with constraints and relationships
- ✅ Data loading with INSERT statements
- ✅ Index creation for performance optimization
- ✅ View creation with subqueries and string functions
- ✅ Verification of data integrity

This lab provided hands-on experience with essential database administration tasks that are commonly performed in real-world database management scenarios.
