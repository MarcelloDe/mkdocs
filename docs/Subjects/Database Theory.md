# Database Theory

Database Theory provides a comprehensive foundation in understanding how databases work, from fundamental concepts to advanced topics like normalization, transactions, and concurrency control. This course covers both theoretical principles and practical SQL application using SQL Server Management Studio (SSMS).

A database is a shared collection of logically related data designed to meet the information needs of multiple users. Understanding database theory is essential for anyone working with data, whether you're a developer, data analyst, or database administrator.

## Week 1: Introduction to Databases

### What is a Database?

A **database** is a shared collection of logically related data designed to meet the information needs of multiple users. It organizes data hierarchically from the smallest component to complete records:

- **Characters**: The smallest unit (letters, numbers, symbols)
- **Fields (Columns)**: A single piece of information (e.g., "FirstName", "Email")
- **Records (Rows)**: A complete set of related fields (e.g., one customer's information)
- **Tables**: Collections of records with the same structure
- **Database**: A collection of related tables

### Database Management System (DBMS)

A DBMS is software that manages databases, providing:
- Data storage and retrieval
- Data security and access control
- Data integrity enforcement
- Concurrent access management
- Backup and recovery

### SQL Server Management Studio (SSMS)

**SQL Server Management Studio (SSMS)** is the primary tool used in this course. It serves as the interface to interact with the database service, allowing you to:

- Write and execute SQL queries
- Design and modify database structures
- Manage database objects (tables, views, stored procedures)
- Monitor database performance
- Configure security settings

### Example: Basic Database Structure

Consider a simple customer database:

```
Customers Table:
┌────────────┬───────────────┬──────────────┬─────────────┐
│ CustomerID │ FirstName     │ LastName     │ Email       │
├────────────┼───────────────┼──────────────┼─────────────┤
│ 1          │ John          │ Smith        │ john@email  │
│ 2          │ Jane          │ Doe          │ jane@email  │
│ 3          │ Bob           │ Johnson      │ bob@email   │
└────────────┴───────────────┴──────────────┴─────────────┘
```

In this example:
- **Character**: 'J', 'o', 'h', 'n'
- **Field**: FirstName, LastName, Email
- **Record**: One complete row (e.g., CustomerID=1, FirstName='John', LastName='Smith', Email='john@email')
- **Table**: The entire Customers table

## Week 2: Data Dictionary, Tables, Keys, and Constraints

### Data Dictionary

A **data dictionary** (also called a system catalog or metadata) defines the structure of the database. It contains information about:
- Table names and structures
- Column names, data types, and sizes
- Constraints and rules
- Relationships between tables
- Indexes and views

### Creating Tables

Tables are created using the `CREATE TABLE` statement with specific data types:

```sql
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Weight DECIMAL(5,2),
    Email VARCHAR(100)
);
```

### Primary Keys

A **Primary Key** uniquely identifies each row in a table. It must:
- Be unique (no duplicates)
- Not be NULL
- Be stable (not change frequently)

**Example:**
```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,  -- Primary key uniquely identifies each order
    CustomerID INT,
    OrderDate DATETIME,
    TotalAmount DECIMAL(10,2)
);
```

### Constraints

**Constraints** are rules that enforce data integrity and maintain data quality:

#### NOT NULL Constraint
Ensures a column cannot contain empty values:

```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,  -- Must have a value
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100)  -- Can be NULL
);
```

#### CHECK Constraint
Ensures values fall within a specified range or meet certain conditions:

```sql
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2) CHECK (Price > 0),  -- Price must be positive
    StockQuantity INT CHECK (StockQuantity >= 0),  -- Cannot be negative
    Category VARCHAR(50) CHECK (Category IN ('Electronics', 'Clothing', 'Food'))
);
```

#### UNIQUE Constraint
Ensures all values in a column are unique:

```sql
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE,  -- Each username must be unique
    Email VARCHAR(100) UNIQUE,    -- Each email must be unique
    PasswordHash VARCHAR(255)
);
```

#### FOREIGN KEY Constraint
Maintains referential integrity between tables:

```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    -- Ensures CustomerID exists in Customers table
);
```

### Example: Complete Table with Multiple Constraints

```sql
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentNumber VARCHAR(20) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    DateOfBirth DATE CHECK (DateOfBirth < GETDATE()),
    GPA DECIMAL(3,2) CHECK (GPA >= 0.0 AND GPA <= 4.0),
    EnrollmentDate DATE DEFAULT GETDATE()
);
```

## Week 3: Indexes, Views, and Subqueries

### Indexes

**Indexes** are database objects that improve query performance by allowing the DBMS to find data faster without scanning every row. Think of an index like a book's index—instead of reading every page, you can jump directly to the relevant section.

**Creating an Index:**
```sql
-- Create an index on the LastName column for faster searches
CREATE INDEX idx_LastName ON Customers(LastName);

-- Create a composite index on multiple columns
CREATE INDEX idx_NameEmail ON Customers(LastName, Email);
```

**When to Use Indexes:**
- Frequently searched columns
- Columns used in JOIN operations
- Columns used in WHERE clauses
- Foreign key columns

**Trade-offs:**
- Indexes speed up SELECT queries
- Indexes slow down INSERT, UPDATE, and DELETE operations (because the index must be updated)
- Indexes consume additional storage space

### Views

**Views** are virtual tables that provide a specific, filtered perspective on data without storing it twice. They are based on the result of a SQL query.

**Creating a View:**
```sql
-- Create a view showing only active customers
CREATE VIEW ActiveCustomers AS
SELECT CustomerID, FirstName, LastName, Email, RegistrationDate
FROM Customers
WHERE Status = 'Active';

-- Use the view like a regular table
SELECT * FROM ActiveCustomers;
```

**Benefits of Views:**
- Simplify complex queries
- Provide security (hide sensitive columns)
- Present data in a user-friendly format
- Maintain consistency across applications

**Example: Complex View**
```sql
CREATE VIEW OrderSummary AS
SELECT 
    o.OrderID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderDate,
    o.TotalAmount,
    COUNT(oi.ProductID) AS ItemCount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.FirstName, c.LastName, o.OrderDate, o.TotalAmount;
```

### Subqueries

**Subqueries** (also called nested queries) are queries nested inside another query to perform multi-step data retrieval.

#### Scalar Subquery
Returns a single value:

```sql
-- Find customers who have placed orders above the average order amount
SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID 
    FROM Orders 
    WHERE TotalAmount > (SELECT AVG(TotalAmount) FROM Orders)
);
```

#### Correlated Subquery
References columns from the outer query:

```sql
-- Find products that have been ordered more than the average for that product category
SELECT ProductID, ProductName, Category
FROM Products p1
WHERE (
    SELECT COUNT(*) 
    FROM OrderItems oi
    JOIN Products p2 ON oi.ProductID = p2.ProductID
    WHERE p2.Category = p1.Category
) > (
    SELECT AVG(OrderCount)
    FROM (
        SELECT Category, COUNT(*) AS OrderCount
        FROM OrderItems oi
        JOIN Products p ON oi.ProductID = p.ProductID
        GROUP BY Category
    ) AS CategoryAverages
);
```

#### EXISTS Subquery
Checks for the existence of rows:

```sql
-- Find customers who have placed at least one order
SELECT CustomerID, FirstName, LastName
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID
);
```

## Week 4: Data Manipulation (INSERT, DELETE, UPDATE)

**Data Manipulation Language (DML)** is used to manage the information within tables. These operations are often governed by triggers or business rules to prevent accidental data loss.

### INSERT Statement

The **INSERT** statement adds new rows of data to a table.

**Basic INSERT:**
```sql
-- Insert a single row
INSERT INTO Customers (FirstName, LastName, Email)
VALUES ('John', 'Smith', 'john.smith@email.com');

-- Insert multiple rows
INSERT INTO Customers (FirstName, LastName, Email)
VALUES 
    ('Jane', 'Doe', 'jane.doe@email.com'),
    ('Bob', 'Johnson', 'bob.johnson@email.com'),
    ('Alice', 'Williams', 'alice.williams@email.com');
```

**INSERT with SELECT:**
```sql
-- Copy data from another table
INSERT INTO CustomersArchive (CustomerID, FirstName, LastName, Email)
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE RegistrationDate < '2020-01-01';
```

### UPDATE Statement

The **UPDATE** statement modifies existing data in a table.

**Basic UPDATE:**
```sql
-- Update a single row
UPDATE Customers
SET Email = 'newemail@example.com'
WHERE CustomerID = 1;

-- Update multiple columns
UPDATE Products
SET Price = Price * 1.10,  -- Increase price by 10%
    LastUpdated = GETDATE()
WHERE Category = 'Electronics';

-- Update with a subquery
UPDATE Orders
SET Status = 'Shipped'
WHERE OrderID IN (
    SELECT OrderID 
    FROM Orders 
    WHERE OrderDate < DATEADD(day, -7, GETDATE())
    AND Status = 'Pending'
);
```

**Important:** Always use a WHERE clause with UPDATE to avoid updating all rows accidentally!

### DELETE Statement

The **DELETE** statement removes rows from a table.

**Basic DELETE:**
```sql
-- Delete a specific row
DELETE FROM Customers
WHERE CustomerID = 5;

-- Delete multiple rows based on condition
DELETE FROM Orders
WHERE OrderDate < '2020-01-01'
AND Status = 'Cancelled';

-- Delete using a subquery
DELETE FROM OrderItems
WHERE OrderID IN (
    SELECT OrderID 
    FROM Orders 
    WHERE Status = 'Cancelled'
);
```

**Important:** Always use a WHERE clause with DELETE to avoid deleting all rows accidentally!

### Transaction Safety

To prevent accidental data loss, wrap DML operations in transactions:

```sql
BEGIN TRANSACTION;

UPDATE Products
SET StockQuantity = StockQuantity - 5
WHERE ProductID = 10;

INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
VALUES (100, 10, 5, 29.99);

-- Review changes before committing
-- If everything looks good:
COMMIT TRANSACTION;

-- If something went wrong:
-- ROLLBACK TRANSACTION;
```

## Week 5: Joining Tables and Date Processing

### Joining Tables

Databases rarely store all information in one table. **Joins** allow you to combine related rows from different tables based on common columns.

#### INNER JOIN
Returns only rows that have matching values in both tables:

```sql
-- Get customer names with their orders
SELECT c.FirstName, c.LastName, o.OrderID, o.OrderDate, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;
```

#### LEFT JOIN (LEFT OUTER JOIN)
Returns all rows from the left table and matching rows from the right table:

```sql
-- Get all customers, even if they haven't placed orders
SELECT c.FirstName, c.LastName, o.OrderID, o.OrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;
```

#### RIGHT JOIN (RIGHT OUTER JOIN)
Returns all rows from the right table and matching rows from the left table:

```sql
-- Get all orders, even if customer information is missing
SELECT c.FirstName, c.LastName, o.OrderID, o.OrderDate
FROM Customers c
RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID;
```

#### FULL OUTER JOIN
Returns all rows from both tables:

```sql
-- Get all customers and all orders
SELECT c.FirstName, c.LastName, o.OrderID, o.OrderDate
FROM Customers c
FULL OUTER JOIN Orders o ON c.CustomerID = o.CustomerID;
```

#### Multiple Table Joins
```sql
-- Join three tables: Customers, Orders, and OrderItems
SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    oi.Quantity,
    oi.Price
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID;
```

### Date Processing

Date functions are essential for working with temporal data in databases.

#### GETDATE()
Retrieves the current date and time:

```sql
SELECT GETDATE() AS CurrentDateTime;
-- Returns: 2026-01-31 14:30:45.123
```

#### DATE Functions
```sql
-- Extract parts of a date
SELECT 
    OrderDate,
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DAY(OrderDate) AS OrderDay,
    DATENAME(WEEKDAY, OrderDate) AS DayOfWeek
FROM Orders;
```

#### DATEDIFF()
Calculates the difference between two dates:

```sql
-- Calculate days between order date and today
SELECT 
    OrderID,
    OrderDate,
    DATEDIFF(day, OrderDate, GETDATE()) AS DaysSinceOrder
FROM Orders;

-- Calculate age in years
SELECT 
    FirstName,
    LastName,
    DateOfBirth,
    DATEDIFF(year, DateOfBirth, GETDATE()) AS Age
FROM Customers;
```

#### DATEADD()
Adds or subtracts a time interval to a date:

```sql
-- Add 30 days to order date (estimated delivery)
SELECT 
    OrderID,
    OrderDate,
    DATEADD(day, 30, OrderDate) AS EstimatedDeliveryDate
FROM Orders;

-- Find orders from the last 7 days
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
WHERE OrderDate >= DATEADD(day, -7, GETDATE());
```

#### Example: Complex Date Query
```sql
-- Find customers who haven't placed an order in the last 90 days
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    MAX(o.OrderDate) AS LastOrderDate,
    DATEDIFF(day, MAX(o.OrderDate), GETDATE()) AS DaysSinceLastOrder
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING MAX(o.OrderDate) IS NULL 
    OR DATEDIFF(day, MAX(o.OrderDate), GETDATE()) > 90;
```

## Week 6: Predicates and Entity Relationship Diagrams (ERD)

### Predicates

**Predicates** are conditions used in `WHERE` clauses to filter data. They allow you to specify exactly which rows should be included in your query results.

#### Comparison Operators
```sql
-- Equal to
SELECT * FROM Products WHERE Price = 29.99;

-- Not equal to
SELECT * FROM Customers WHERE Status <> 'Inactive';

-- Greater than / Less than
SELECT * FROM Orders WHERE TotalAmount > 100;
SELECT * FROM Products WHERE StockQuantity < 10;
```

#### BETWEEN
Checks if a value falls within a range (inclusive):

```sql
-- Find products priced between $10 and $50
SELECT ProductName, Price
FROM Products
WHERE Price BETWEEN 10.00 AND 50.00;

-- Find orders placed in January 2026
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
WHERE OrderDate BETWEEN '2026-01-01' AND '2026-01-31';
```

#### IN
Checks if a value matches any value in a list:

```sql
-- Find customers in specific cities
SELECT FirstName, LastName, City
FROM Customers
WHERE City IN ('New York', 'Los Angeles', 'Chicago');

-- Find products in specific categories
SELECT ProductName, Category, Price
FROM Products
WHERE Category IN ('Electronics', 'Computers', 'Accessories');
```

#### LIKE
Performs pattern matching (often used with wildcards):

```sql
-- Find customers with last names starting with 'S'
SELECT FirstName, LastName
FROM Customers
WHERE LastName LIKE 'S%';

-- Find email addresses from a specific domain
SELECT FirstName, LastName, Email
FROM Customers
WHERE Email LIKE '%@gmail.com';

-- Find products with 'phone' anywhere in the name
SELECT ProductName
FROM Products
WHERE ProductName LIKE '%phone%';

-- Find customers with exactly 5 characters in last name
SELECT FirstName, LastName
FROM Customers
WHERE LastName LIKE '_____';  -- 5 underscores
```

**LIKE Wildcards:**
- `%` - Matches any sequence of characters (zero or more)
- `_` - Matches exactly one character
- `[charlist]` - Matches any single character in the list
- `[^charlist]` - Matches any single character NOT in the list

#### EXISTS
Checks for the existence of rows in a subquery:

```sql
-- Find customers who have placed orders
SELECT CustomerID, FirstName, LastName
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID
);
```

#### IS NULL / IS NOT NULL
Checks for NULL values:

```sql
-- Find customers without email addresses
SELECT FirstName, LastName
FROM Customers
WHERE Email IS NULL;

-- Find products with descriptions
SELECT ProductName, Description
FROM Products
WHERE Description IS NOT NULL;
```

### Entity Relationship Diagrams (ERD)

**Entity Relationship Diagrams (ERDs)** are visual representations that identify vital entities (e.g., Patients, Doctors) and how they relate to one another before the database is built.

#### Key Components of ERDs

1. **Entities**: Represent real-world objects (tables)
   - Examples: Patient, Doctor, Appointment, Prescription

2. **Attributes**: Properties of entities (columns)
   - Examples: PatientID, PatientName, DateOfBirth

3. **Relationships**: How entities connect
   - One-to-One (1:1)
   - One-to-Many (1:M)
   - Many-to-Many (M:M)

4. **Cardinality**: The number of instances in a relationship
   - One (1)
   - Many (M)

#### Example ERD Structure

```
┌─────────────┐         ┌──────────────┐
│   Patient   │         │    Doctor    │
├─────────────┤         ├──────────────┤
│ PatientID   │◄───────│ DoctorID     │
│ FirstName   │    M    │ FirstName    │
│ LastName    │    │    │ LastName     │
│ DateOfBirth │    │    │ Specialty    │
└─────────────┘    │    └──────────────┘
                   │
                   │
            ┌──────▼──────┐
            │ Appointment │
            ├────────────┤
            │ ApptID      │
            │ PatientID   │
            │ DoctorID    │
            │ ApptDate    │
            │ ApptTime    │
            └─────────────┘
```

**Reading the ERD:**
- One Doctor can have Many Appointments (1:M)
- One Patient can have Many Appointments (1:M)
- Appointment is the "junction" or "linking" table

## Week 7: Relationships and Business Rules

### Relationships

Relationships define how entities interact in a database. Understanding relationship types is crucial for proper database design.

#### One-to-One (1:1) Relationship
Each record in one table relates to exactly one record in another table.

**Example:** Employee and EmployeeDetails
```sql
-- Each employee has exactly one set of details
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50)
);

CREATE TABLE EmployeeDetails (
    EmployeeID INT PRIMARY KEY,
    SocialSecurityNumber VARCHAR(11),
    EmergencyContact VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
```

#### One-to-Many (1:M) Relationship
One record in a table relates to many records in another table. This is the most common relationship type.

**Example:** Customer and Orders
```sql
-- One customer can have many orders
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
```

#### Many-to-Many (M:M) Relationship
Records in both tables can relate to many records in the other table. Requires a junction/linking table.

**Example:** Students and Courses
```sql
-- Students can enroll in many courses
-- Courses can have many students
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50)
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100),
    Credits INT
);

-- Junction table to link Students and Courses
CREATE TABLE Enrollments (
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE,
    Grade CHAR(2),
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);
```

### Business Rules

**Business Rules** are specifications that preserve the integrity of the data model. They ensure data quality and enforce organizational policies.

#### Types of Business Rules

1. **Data Integrity Rules**
   - Ensure data accuracy and consistency
   - Example: "A patient's weight must always be greater than zero"

2. **Referential Integrity Rules**
   - Maintain relationships between tables
   - Example: "An order cannot exist without a customer"

3. **Domain Rules**
   - Define valid values for attributes
   - Example: "Order status must be 'Pending', 'Shipped', or 'Delivered'"

4. **Derivation Rules**
   - Calculate values from other attributes
   - Example: "TotalAmount = Sum of all OrderItems.Price * Quantity"

#### Implementing Business Rules

**Using CHECK Constraints:**
```sql
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Weight DECIMAL(5,2) CHECK (Weight > 0),  -- Business rule: weight must be positive
    Height DECIMAL(5,2) CHECK (Height > 0),  -- Business rule: height must be positive
    BloodType VARCHAR(3) CHECK (BloodType IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);
```

**Using Triggers:**
```sql
-- Business rule: Prevent orders with total amount less than $10
CREATE TRIGGER trg_MinimumOrderAmount
ON Orders
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE TotalAmount < 10.00)
    BEGIN
        RAISERROR('Order total must be at least $10.00', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

**Using Stored Procedures:**
```sql
-- Business rule: Ensure inventory is sufficient before allowing order
CREATE PROCEDURE sp_PlaceOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    DECLARE @AvailableStock INT;
    
    SELECT @AvailableStock = StockQuantity
    FROM Products
    WHERE ProductID = @ProductID;
    
    IF @AvailableStock < @Quantity
    BEGIN
        RAISERROR('Insufficient stock available', 16, 1);
        RETURN;
    END
    
    -- Proceed with order placement
    INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderDate)
    VALUES (@CustomerID, @ProductID, @Quantity, GETDATE());
    
    -- Update inventory
    UPDATE Products
    SET StockQuantity = StockQuantity - @Quantity
    WHERE ProductID = @ProductID;
END;
```

#### Example: Complete Business Rules Implementation

```sql
-- Hospital Database with Business Rules
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE CHECK (DateOfBirth < GETDATE()),
    Weight DECIMAL(5,2) CHECK (Weight > 0 AND Weight < 1000),  -- Reasonable weight range
    Height DECIMAL(5,2) CHECK (Height > 0 AND Height < 300),  -- Height in cm
    InsuranceNumber VARCHAR(20) UNIQUE
);

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    LicenseNumber VARCHAR(20) UNIQUE NOT NULL,
    Specialty VARCHAR(50) CHECK (Specialty IN ('Cardiology', 'Pediatrics', 'Surgery', 'General'))
);

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME CHECK (AppointmentDate > GETDATE()),  -- Future appointments only
    Duration INT CHECK (Duration BETWEEN 15 AND 120),  -- 15 to 120 minutes
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
```

## Week 8: Stored Procedures

**Stored Procedures** are pieces of executable code (small programs) stored within the database. They are preferred for database access because they are:
- **Compiled**: Faster execution than ad-hoc SQL
- **Network Efficient**: Reduce network traffic by sending procedure name and parameters instead of full SQL
- **Secure**: Provide consistent, controlled methods for performing complex tasks
- **Reusable**: Can be called from multiple applications

### Creating Stored Procedures

**Basic Syntax:**
```sql
CREATE PROCEDURE ProcedureName
    @Parameter1 DataType,
    @Parameter2 DataType
AS
BEGIN
    -- SQL statements
END
```

### Simple Stored Procedure Example

```sql
-- Get customer information by ID
CREATE PROCEDURE sp_GetCustomer
    @CustomerID INT
AS
BEGIN
    SELECT CustomerID, FirstName, LastName, Email, RegistrationDate
    FROM Customers
    WHERE CustomerID = @CustomerID;
END;

-- Execute the stored procedure
EXEC sp_GetCustomer @CustomerID = 1;
```

### Stored Procedure with Multiple Parameters

```sql
-- Add a new customer
CREATE PROCEDURE sp_AddCustomer
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Phone VARCHAR(20) = NULL  -- Optional parameter with default value
AS
BEGIN
    INSERT INTO Customers (FirstName, LastName, Email, Phone, RegistrationDate)
    VALUES (@FirstName, @LastName, @Email, @Phone, GETDATE());
    
    -- Return the new customer ID
    SELECT SCOPE_IDENTITY() AS NewCustomerID;
END;

-- Execute with all parameters
EXEC sp_AddCustomer 
    @FirstName = 'John',
    @LastName = 'Smith',
    @Email = 'john.smith@email.com',
    @Phone = '555-1234';

-- Execute without optional parameter
EXEC sp_AddCustomer 
    @FirstName = 'Jane',
    @LastName = 'Doe',
    @Email = 'jane.doe@email.com';
```

### Stored Procedure with Output Parameters

```sql
-- Calculate order statistics and return via output parameter
CREATE PROCEDURE sp_GetOrderStatistics
    @CustomerID INT,
    @TotalOrders INT OUTPUT,
    @TotalAmount DECIMAL(10,2) OUTPUT,
    @AverageAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT 
        @TotalOrders = COUNT(*),
        @TotalAmount = SUM(TotalAmount),
        @AverageAmount = AVG(TotalAmount)
    FROM Orders
    WHERE CustomerID = @CustomerID;
END;

-- Execute and retrieve output parameters
DECLARE @TotalOrders INT;
DECLARE @TotalAmount DECIMAL(10,2);
DECLARE @AverageAmount DECIMAL(10,2);

EXEC sp_GetOrderStatistics 
    @CustomerID = 1,
    @TotalOrders = @TotalOrders OUTPUT,
    @TotalAmount = @TotalAmount OUTPUT,
    @AverageAmount = @AverageAmount OUTPUT;

SELECT @TotalOrders AS TotalOrders, @TotalAmount AS TotalAmount, @AverageAmount AS AverageAmount;
```

### Complex Stored Procedure Example

```sql
-- Process a complete order with validation and inventory management
CREATE PROCEDURE sp_ProcessOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @OrderID INT OUTPUT
AS
BEGIN
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Validate customer exists
        IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerID)
        BEGIN
            RAISERROR('Invalid Customer ID', 16, 1);
            RETURN;
        END
        
        -- Validate product exists and has sufficient stock
        DECLARE @AvailableStock INT;
        DECLARE @UnitPrice DECIMAL(10,2);
        
        SELECT @AvailableStock = StockQuantity, @UnitPrice = Price
        FROM Products
        WHERE ProductID = @ProductID;
        
        IF @AvailableStock IS NULL
        BEGIN
            RAISERROR('Invalid Product ID', 16, 1);
            RETURN;
        END
        
        IF @AvailableStock < @Quantity
        BEGIN
            RAISERROR('Insufficient stock available', 16, 1);
            RETURN;
        END
        
        -- Create order
        INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, Status)
        VALUES (@CustomerID, GETDATE(), @UnitPrice * @Quantity, 'Pending');
        
        SET @OrderID = SCOPE_IDENTITY();
        
        -- Add order items
        INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
        VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice);
        
        -- Update inventory
        UPDATE Products
        SET StockQuantity = StockQuantity - @Quantity
        WHERE ProductID = @ProductID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Error processing order: %s', 16, 1, ERROR_MESSAGE());
    END CATCH
END;
```

### Modifying and Dropping Stored Procedures

```sql
-- Modify an existing stored procedure
ALTER PROCEDURE sp_GetCustomer
    @CustomerID INT
AS
BEGIN
    SELECT 
        CustomerID, 
        FirstName, 
        LastName, 
        Email, 
        RegistrationDate,
        (SELECT COUNT(*) FROM Orders WHERE CustomerID = @CustomerID) AS TotalOrders
    FROM Customers
    WHERE CustomerID = @CustomerID;
END;

-- Drop a stored procedure
DROP PROCEDURE sp_GetCustomer;
```

## Week 9: Triggers

A **Trigger** is a special type of stored procedure that "fires" automatically in response to an event, such as an `INSERT`, `UPDATE`, or `DELETE` operation. Triggers are primarily used to enforce complex business rules that cannot be handled by simple constraints.

### Types of Triggers

1. **AFTER Triggers** (also called FOR triggers): Execute after the triggering event
2. **INSTEAD OF Triggers**: Execute instead of the triggering event (often used with views)

### When to Use Triggers

- Enforce complex business rules
- Maintain audit trails
- Automatically update related tables
- Enforce referential integrity across databases
- Prevent invalid data modifications

### AFTER INSERT Trigger

```sql
-- Automatically update inventory when a sale is recorded
CREATE TRIGGER trg_UpdateInventoryOnSale
ON Sales
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET StockQuantity = p.StockQuantity - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
```

**Example Usage:**
```sql
-- When this INSERT executes, the trigger automatically fires
INSERT INTO Sales (ProductID, Quantity, SaleDate)
VALUES (10, 5, GETDATE());

-- The trigger automatically reduces ProductID 10's stock by 5
```

### AFTER UPDATE Trigger

```sql
-- Maintain an audit trail of price changes
CREATE TABLE PriceHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangedDate DATETIME,
    ChangedBy VARCHAR(50)
);

CREATE TRIGGER trg_LogPriceChanges
ON Products
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Price)  -- Only fire if Price column was updated
    BEGIN
        INSERT INTO PriceHistory (ProductID, OldPrice, NewPrice, ChangedDate, ChangedBy)
        SELECT 
            i.ProductID,
            d.Price AS OldPrice,
            i.Price AS NewPrice,
            GETDATE(),
            SYSTEM_USER
        FROM inserted i
        INNER JOIN deleted d ON i.ProductID = d.ProductID
        WHERE i.Price <> d.Price;  -- Only log actual changes
    END
END;
```

### AFTER DELETE Trigger

```sql
-- Archive deleted orders instead of permanently removing them
CREATE TABLE OrdersArchive (
    OrderID INT,
    CustomerID INT,
    OrderDate DATETIME,
    TotalAmount DECIMAL(10,2),
    DeletedDate DATETIME,
    DeletedBy VARCHAR(50)
);

CREATE TRIGGER trg_ArchiveDeletedOrders
ON Orders
AFTER DELETE
AS
BEGIN
    INSERT INTO OrdersArchive (OrderID, CustomerID, OrderDate, TotalAmount, DeletedDate, DeletedBy)
    SELECT OrderID, CustomerID, OrderDate, TotalAmount, GETDATE(), SYSTEM_USER
    FROM deleted;
END;
```

### Complex Trigger Example: Enforcing Business Rules

```sql
-- Prevent orders that would result in negative inventory
CREATE TRIGGER trg_PreventNegativeInventory
ON OrderItems
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Products p ON i.ProductID = p.ProductID
        WHERE p.StockQuantity < (
            SELECT COALESCE(SUM(oi.Quantity), 0)
            FROM OrderItems oi
            WHERE oi.ProductID = i.ProductID
            AND oi.OrderID IN (
                SELECT OrderID FROM Orders WHERE Status = 'Pending'
            )
        )
    )
    BEGIN
        RAISERROR('Order would result in negative inventory', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

### INSTEAD OF Trigger

```sql
-- Allow updates to a view that joins multiple tables
CREATE VIEW CustomerOrderSummary AS
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;

-- Create INSTEAD OF trigger to handle updates
CREATE TRIGGER trg_UpdateCustomerOrderSummary
ON CustomerOrderSummary
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Customers
    SET FirstName = i.CustomerName  -- Simplified example
    FROM inserted i
    WHERE Customers.CustomerID = i.CustomerID;
END;
```

### Disabling and Enabling Triggers

```sql
-- Disable a specific trigger
DISABLE TRIGGER trg_UpdateInventoryOnSale ON Sales;

-- Enable a trigger
ENABLE TRIGGER trg_UpdateInventoryOnSale ON Sales;

-- Disable all triggers on a table
ALTER TABLE Sales DISABLE TRIGGER ALL;

-- Enable all triggers on a table
ALTER TABLE Sales ENABLE TRIGGER ALL;
```

### Best Practices for Triggers

1. **Keep triggers simple**: Complex logic should be in stored procedures
2. **Avoid recursive triggers**: Triggers that call themselves can cause infinite loops
3. **Handle errors properly**: Use TRY-CATCH blocks
4. **Consider performance**: Triggers execute for every row affected
5. **Document thoroughly**: Triggers can be hard to debug

## Week 10: Normalization (Part 1)

**Normalization** is the process of organizing data to minimize redundancy and prevent "storage anomalies." It involves decomposing tables to eliminate data duplication and ensure data integrity.

### Storage Anomalies

**Insertion Anomaly**: Difficulty inserting data without other related data
**Update Anomaly**: Need to update multiple rows when data changes
**Deletion Anomaly**: Loss of related data when deleting a row

### First Normal Form (1NF)

**Rules:**
- Eliminates repeating groups
- Eliminates multi-valued attributes
- Each cell contains atomic (indivisible) values
- Each row is unique

**Example - Before 1NF:**
```
┌──────────┬──────────────┬─────────────────────────────┐
│ OrderID  │ CustomerName │ Products                    │
├──────────┼──────────────┼─────────────────────────────┤
│ 1        │ John Smith   │ Laptop, Mouse, Keyboard     │
│ 2        │ Jane Doe     │ Monitor, Speakers           │
└──────────┴──────────────┴─────────────────────────────┘
```
*Problem: Products column contains multiple values*

**After 1NF:**
```
┌──────────┬──────────────┬───────────┐
│ OrderID  │ CustomerName │ Product   │
├──────────┼──────────────┼───────────┤
│ 1        │ John Smith   │ Laptop    │
│ 1        │ John Smith   │ Mouse     │
│ 1        │ John Smith   │ Keyboard  │
│ 2        │ Jane Doe     │ Monitor   │
│ 2        │ Jane Doe     │ Speakers  │
└──────────┴──────────────┴───────────┘
```

### Second Normal Form (2NF)

**Rules:**
- Must be in 1NF
- Removes attributes that don't depend on the whole primary key
- All non-key attributes must be fully functionally dependent on the primary key

**Example - Before 2NF:**
```
┌──────────┬───────────┬──────────────┬──────────────┐
│ OrderID  │ ProductID │ ProductName  │ CustomerName │
├──────────┼───────────┼──────────────┼──────────────┤
│ 1        │ 10        │ Laptop       │ John Smith   │
│ 1        │ 20        │ Mouse        │ John Smith   │
│ 2        │ 10        │ Laptop       │ Jane Doe     │
└──────────┴───────────┴──────────────┴──────────────┘
```
*Problem: ProductName depends only on ProductID, not on OrderID. CustomerName depends only on OrderID.*

**After 2NF:**
```
Orders Table:
┌──────────┬──────────────┐
│ OrderID  │ CustomerName │
├──────────┼──────────────┤
│ 1        │ John Smith   │
│ 2        │ Jane Doe     │
└──────────┴──────────────┘

Products Table:
┌───────────┬──────────────┐
│ ProductID │ ProductName  │
├───────────┼──────────────┤
│ 10        │ Laptop       │
│ 20        │ Mouse        │
└───────────┴──────────────┘

OrderItems Table:
┌──────────┬───────────┐
│ OrderID  │ ProductID │
├──────────┼───────────┤
│ 1        │ 10        │
│ 1        │ 20        │
│ 2        │ 10        │
└──────────┴───────────┘
```

### Third Normal Form (3NF)

**Rules:**
- Must be in 2NF
- Removes "transitive dependencies"
- No non-key field depends on another non-key field
- All non-key attributes must depend only on the primary key

**Example - Before 3NF:**
```
┌───────────┬──────────────┬────────────┬──────────────┐
│ ProductID │ ProductName  │ CategoryID │ CategoryName │
├───────────┼──────────────┼────────────┼──────────────┤
│ 10        │ Laptop       │ 1          │ Electronics  │
│ 20        │ Mouse        │ 1          │ Electronics  │
│ 30        │ T-Shirt      │ 2          │ Clothing     │
└───────────┴──────────────┴────────────┴──────────────┘
```
*Problem: CategoryName depends on CategoryID, not directly on ProductID (transitive dependency)*

**After 3NF:**
```
Products Table:
┌───────────┬──────────────┬────────────┐
│ ProductID │ ProductName  │ CategoryID │
├───────────┼──────────────┼────────────┤
│ 10        │ Laptop       │ 1          │
│ 20        │ Mouse        │ 1          │
│ 30        │ T-Shirt      │ 2          │
└───────────┴──────────────┴────────────┘

Categories Table:
┌────────────┬──────────────┐
│ CategoryID │ CategoryName │
├────────────┼──────────────┤
│ 1          │ Electronics  │
│ 2          │ Clothing     │
└────────────┴──────────────┘
```

### Normalization Example: Complete Process

**Unnormalized Data:**
```
Student Course Enrollment:
┌──────────┬──────────┬──────────────┬────────────┬──────────┬────────────┐
│ StudentID│ StudentName│ CourseID   │ CourseName │ Instructor│ Grade     │
├──────────┼──────────┼──────────────┼────────────┼──────────┼────────────┤
│ 1        │ John      │ CS101, CS102│ Database,  │ Dr. Smith│ A, B      │
│          │           │             │ Programming│          │           │
└──────────┴──────────┴──────────────┴────────────┴──────────┴────────────┘
```

**After 1NF:**
```
┌──────────┬────────────┬───────────┬──────────────┬────────────┬──────────┐
│ StudentID│ StudentName│ CourseID  │ CourseName   │ Instructor │ Grade    │
├──────────┼────────────┼───────────┼──────────────┼────────────┼──────────┤
│ 1        │ John       │ CS101     │ Database     │ Dr. Smith  │ A        │
│ 1        │ John       │ CS102     │ Programming  │ Dr. Smith  │ B        │
└──────────┴────────────┴───────────┴──────────────┴────────────┴──────────┘
```

**After 2NF:**
```
Students Table:
┌──────────┬────────────┐
│ StudentID│ StudentName│
├──────────┼────────────┤
│ 1        │ John       │
└──────────┴────────────┘

Courses Table:
┌───────────┬──────────────┬────────────┐
│ CourseID  │ CourseName   │ Instructor │
├───────────┼──────────────┼────────────┤
│ CS101     │ Database     │ Dr. Smith  │
│ CS102     │ Programming  │ Dr. Smith  │
└───────────┴──────────────┴────────────┘

Enrollments Table:
┌──────────┬───────────┬──────────┐
│ StudentID│ CourseID  │ Grade   │
├──────────┼───────────┼──────────┤
│ 1        │ CS101     │ A       │
│ 1        │ CS102     │ B       │
└──────────┴───────────┴──────────┘
```

**After 3NF:**
```
Students Table:
┌──────────┬────────────┐
│ StudentID│ StudentName│
├──────────┼────────────┤
│ 1        │ John       │
└──────────┴────────────┘

Courses Table:
┌───────────┬──────────────┬──────────────┐
│ CourseID  │ CourseName   │ InstructorID │
├───────────┼──────────────┼──────────────┤
│ CS101     │ Database     │ 1            │
│ CS102     │ Programming  │ 1            │
└───────────┴──────────────┴──────────────┘

Instructors Table:
┌──────────────┬────────────┐
│ InstructorID │ Name       │
├──────────────┼────────────┤
│ 1            │ Dr. Smith  │
└──────────────┴────────────┘

Enrollments Table:
┌──────────┬───────────┬──────────┐
│ StudentID│ CourseID  │ Grade   │
├──────────┼───────────┼──────────┤
│ 1        │ CS101     │ A       │
│ 1        │ CS102     │ B       │
└──────────┴───────────┴──────────┘
```

## Week 11: Normalized vs. Denormalized Data

### Normalized Data (OLTP)

**Online Transaction Processing (OLTP)** systems use normalized databases (typically 3NF) optimized for:
- **Data Integrity**: Minimizes redundancy and inconsistencies
- **Transaction Speed**: Fast INSERT, UPDATE, DELETE operations
- **Storage Efficiency**: Reduces storage requirements
- **Data Consistency**: Changes propagate correctly

**Characteristics:**
- Many small tables
- Complex relationships
- Optimized for write operations
- Example: E-commerce order processing system

**Example Normalized Structure:**
```sql
-- Normalized OLTP Database
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    Price DECIMAL(10,2)
);

CREATE TABLE OrderItems (
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    Price DECIMAL(10,2),
    PRIMARY KEY (OrderID, ProductID)
);
```

### Denormalized Data (OLAP)

**Online Analytical Processing (OLAP)** systems use denormalized databases optimized for:
- **Query Speed**: Fast SELECT operations for complex analysis
- **Business Intelligence**: Pre-aggregated data for reporting
- **Read Performance**: Optimized for analytical queries
- **Data Warehousing**: Historical data analysis

**Characteristics:**
- Fewer, larger tables
- Redundant data is acceptable
- Optimized for read operations
- Pre-calculated aggregations
- Example: Data warehouse for business reporting

**Example Denormalized Structure:**
```sql
-- Denormalized OLAP Data Warehouse
CREATE TABLE SalesFact (
    SaleDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),      -- Denormalized from Customers
    ProductID INT,
    ProductName VARCHAR(100),      -- Denormalized from Products
    CategoryName VARCHAR(50),      -- Denormalized from Categories
    Region VARCHAR(50),            -- Denormalized from Geography
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),     -- Pre-calculated
    ProfitMargin DECIMAL(10,2)     -- Pre-calculated
);

-- This structure allows fast analytical queries:
SELECT 
    CategoryName,
    Region,
    SUM(TotalAmount) AS TotalSales,
    AVG(ProfitMargin) AS AvgProfitMargin
FROM SalesFact
WHERE SaleDate BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY CategoryName, Region
ORDER BY TotalSales DESC;
```

### When to Normalize vs. Denormalize

**Use Normalization (3NF) When:**
- Building transactional systems (OLTP)
- Data integrity is critical
- Write operations are frequent
- Storage space is a concern
- Multiple applications access the same data

**Use Denormalization When:**
- Building analytical systems (OLAP)
- Read performance is critical
- Complex reporting and analysis needed
- Historical data analysis
- Data warehouse or data mart design

### Trade-offs

| Aspect | Normalized (3NF) | Denormalized |
|--------|------------------|--------------|
| **Data Integrity** | High | Lower (redundancy) |
| **Write Performance** | Fast | Slower |
| **Read Performance** | Slower (joins required) | Fast |
| **Storage** | Efficient | Less efficient |
| **Maintenance** | Easier (single source) | Harder (multiple updates) |
| **Query Complexity** | More complex (joins) | Simpler |
| **Use Case** | Transaction processing | Business intelligence |

### Example: Same Data, Different Structures

**Normalized Query (OLTP):**
```sql
-- Requires multiple joins
SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    p.ProductName,
    cat.CategoryName,
    oi.Quantity,
    oi.Price * oi.Quantity AS TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE o.OrderDate >= '2025-01-01';
```

**Denormalized Query (OLAP):**
```sql
-- Simple, fast query on pre-aggregated data
SELECT 
    CustomerName,
    ProductName,
    CategoryName,
    Quantity,
    TotalAmount
FROM SalesFact
WHERE SaleDate >= '2025-01-01';
```

## Week 12: Transactions and Concurrency Control

### Transactions

A **Transaction** is a logical unit of work that must be completed entirely or not at all. This principle is known as **Atomicity**—one of the ACID properties of database transactions.

#### ACID Properties

1. **Atomicity**: All operations succeed or all fail
2. **Consistency**: Database remains in a valid state
3. **Isolation**: Concurrent transactions don't interfere
4. **Durability**: Committed changes persist

### Transaction Control

**Basic Transaction Syntax:**
```sql
BEGIN TRANSACTION;
    -- SQL statements
COMMIT TRANSACTION;  -- Save changes permanently

-- OR

BEGIN TRANSACTION;
    -- SQL statements
ROLLBACK TRANSACTION;  -- Undo all changes
```

### Example: Transferring Money Between Accounts

```sql
BEGIN TRANSACTION;

BEGIN TRY
    -- Deduct from source account
    UPDATE Accounts
    SET Balance = Balance - 1000
    WHERE AccountID = 1;
    
    -- Check if sufficient funds
    IF (SELECT Balance FROM Accounts WHERE AccountID = 1) < 0
    BEGIN
        RAISERROR('Insufficient funds', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Add to destination account
    UPDATE Accounts
    SET Balance = Balance + 1000
    WHERE AccountID = 2;
    
    -- Record the transaction
    INSERT INTO Transactions (FromAccountID, ToAccountID, Amount, TransactionDate)
    VALUES (1, 2, 1000, GETDATE());
    
    COMMIT TRANSACTION;
    PRINT 'Transfer completed successfully';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
```

### Concurrency Control

**Concurrency Control** uses **Locks** to prevent multiple users from modifying the same data simultaneously, which could lead to errors like lost updates, dirty reads, or inconsistent analysis.

### Concurrency Problems

#### 1. Lost Update
Two transactions update the same data, and one overwrites the other:

```
Time    Transaction A              Transaction B
─────────────────────────────────────────────────
T1      Read Balance = $1000
T2                              Read Balance = $1000
T3      Balance = $1000 + $500
T4      Write Balance = $1500
T5                              Balance = $1000 - $200
T6                              Write Balance = $800  (Lost update!)
```

#### 2. Dirty Read
Reading uncommitted data that may be rolled back:

```
Time    Transaction A              Transaction B
─────────────────────────────────────────────────
T1      UPDATE Balance = $2000
T2                              Read Balance = $2000 (Dirty Read)
T3      ROLLBACK (Balance = $1000)
T4                              Uses incorrect $2000 value
```

#### 3. Non-Repeatable Read
Same query returns different results within a transaction:

```
Time    Transaction A              Transaction B
─────────────────────────────────────────────────
T1      Read Balance = $1000
T2                              UPDATE Balance = $2000
T3                              COMMIT
T4      Read Balance = $2000 (Different value!)
```

#### 4. Phantom Read
New rows appear during a transaction:

```
Time    Transaction A              Transaction B
─────────────────────────────────────────────────
T1      SELECT COUNT(*) = 10
T2                              INSERT new row
T3                              COMMIT
T4      SELECT COUNT(*) = 11 (Phantom row!)
```

### Transaction Isolation Levels

SQL Server provides different isolation levels to control concurrency:

#### READ UNCOMMITTED (Lowest Isolation)
```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- Allows dirty reads, non-repeatable reads, phantom reads
-- Fastest but least safe
```

#### READ COMMITTED (Default)
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Prevents dirty reads
-- Allows non-repeatable reads and phantom reads
```

#### REPEATABLE READ
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Prevents dirty reads and non-repeatable reads
-- Allows phantom reads
```

#### SERIALIZABLE (Highest Isolation)
```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Prevents all concurrency problems
-- Slowest but safest
```

### Lock Types

**Shared Lock (S-Lock):**
- Used for reading
- Multiple transactions can hold shared locks
- Prevents exclusive locks

**Exclusive Lock (X-Lock):**
- Used for writing
- Only one transaction can hold an exclusive lock
- Prevents all other locks

**Update Lock (U-Lock):**
- Used when planning to update
- Can be upgraded to exclusive lock

### Example: Using Explicit Locks

```sql
-- Use explicit locking hints
BEGIN TRANSACTION;

-- Lock rows for update
SELECT * FROM Accounts
WHERE AccountID = 1
WITH (UPDLOCK, ROWLOCK);

-- Perform update
UPDATE Accounts
SET Balance = Balance - 1000
WHERE AccountID = 1;

COMMIT TRANSACTION;
```

### Deadlocks

A **deadlock** occurs when two transactions are waiting for each other to release locks:

```
Transaction A locks Account 1, wants Account 2
Transaction B locks Account 2, wants Account 1
→ Deadlock!
```

**Preventing Deadlocks:**
- Always lock resources in the same order
- Keep transactions short
- Use appropriate isolation levels
- SQL Server automatically detects and resolves deadlocks

### Database Logging and Recovery

Databases maintain **transaction logs** to recover to a consistent state in the event of a system failure.

**Transaction Log Functions:**
- Records all changes before they're written to disk
- Enables rollback of uncommitted transactions
- Enables recovery after system failure
- Supports point-in-time recovery

**Recovery Process:**
1. **Redo (Roll Forward)**: Reapply committed transactions from the log
2. **Undo (Roll Back)**: Remove uncommitted transactions

### Example: Complete Transaction with Error Handling

```sql
CREATE PROCEDURE sp_ProcessOrderWithInventory
    @OrderID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Lock the product row
        DECLARE @AvailableStock INT;
        
        SELECT @AvailableStock = StockQuantity
        FROM Products WITH (UPDLOCK, ROWLOCK)
        WHERE ProductID = @ProductID;
        
        -- Validate stock
        IF @AvailableStock < @Quantity
        BEGIN
            RAISERROR('Insufficient stock', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Update inventory
        UPDATE Products
        SET StockQuantity = StockQuantity - @Quantity
        WHERE ProductID = @ProductID;
        
        -- Add order item
        INSERT INTO OrderItems (OrderID, ProductID, Quantity)
        VALUES (@OrderID, @ProductID, @Quantity);
        
        -- Update order total
        UPDATE Orders
        SET TotalAmount = (
            SELECT SUM(p.Price * oi.Quantity)
            FROM OrderItems oi
            JOIN Products p ON oi.ProductID = p.ProductID
            WHERE oi.OrderID = @OrderID
        )
        WHERE OrderID = @OrderID;
        
        COMMIT TRANSACTION;
        RETURN 0;  -- Success
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN ERROR_NUMBER();  -- Return error code
    END CATCH
END;
```

## Summary

Database Theory provides the foundation for understanding how databases work, from basic concepts like tables and keys to advanced topics like normalization, transactions, and concurrency control. Mastery of these concepts enables you to:

- Design efficient, normalized database structures
- Write optimized SQL queries
- Implement business rules through constraints, triggers, and stored procedures
- Ensure data integrity and consistency
- Handle concurrent access safely
- Choose appropriate database designs for different use cases (OLTP vs. OLAP)

Whether you're building transactional systems or analytical data warehouses, understanding database theory is essential for creating robust, efficient, and maintainable database solutions.
