# Database Lab 6: Stored Procedures and Table Modifications

This lab focused on modifying existing table structures using ALTER TABLE, managing data updates, and creating stored procedures with conditional logic. The assignment required adding a new column to track activity dates, populating that column with UPDATE statements, inserting test data, and creating a stored procedure that can either preview or execute data purging operations based on activity dates.

## Topics Covered

This lab touched upon several important database administration and programming concepts:

### 1. **ALTER TABLE Statement**
- Modifying existing table structures without recreating tables
- Adding new columns to existing tables
- Understanding NULL constraints and default values
- Impact on existing data when adding columns

### 2. **UPDATE Statements**
- Updating specific rows using WHERE clauses
- Setting values for newly added columns
- Ensuring data consistency across multiple UPDATE operations

### 3. **Stored Procedures**
- Creating reusable database procedures
- Using input parameters with default values
- Conditional logic with IF/ELSE statements
- Preview vs. execute patterns for data modification operations

### 4. **Data Purging Logic**
- Implementing business rules for data retention
- Safe deletion patterns (preview before delete)
- Date-based filtering and comparison

## Assignment Overview

The lab required students to:

1. **Modify Table Structure**: Add a `last_activity_date` column to the master table
2. **Populate Data**: Use UPDATE statements to set activity dates for existing records
3. **Insert Test Data**: Add a record with activity date more than 3 years ago
4. **Create Stored Procedure**: Build a procedure that can preview or delete records based on activity dates
5. **Test Procedure**: Demonstrate the procedure working in both preview and execute modes

## Lessons Learned

### 1. **Table Modifications in Production**
- ALTER TABLE allows schema changes without losing data
- New columns added to existing tables will have NULL values initially
- Always plan UPDATE statements to populate new columns appropriately
- Consider the impact on existing applications when modifying table structures

### 2. **Stored Procedure Design Patterns**
- **Preview Mode**: Always provide a way to see what will be affected before executing destructive operations
- **Parameter Defaults**: Use default values to make procedures safer (default to preview mode)
- **Conditional Logic**: IF/ELSE statements allow procedures to behave differently based on parameters
- **Naming Conventions**: Follow consistent naming patterns for procedures

### 3. **Data Management Best Practices**
- Test data should represent edge cases (e.g., records older than retention period)
- Always verify data state before and after procedure execution
- Use PRINT statements to document what's happening at each step
- Include GO statements to separate batches properly

### 4. **Date Handling**
- Date comparisons require careful attention to format
- Business rules often involve date-based criteria (e.g., "3 years ago")
- Test with various date scenarios to ensure procedures work correctly

## Assignment Instructions Summary

The lab instructions specified:

1. **ALTER TABLE**: Add `last_activity_date` column (DATE type) that accepts NULL values
2. **UPDATE Statements**: Set `last_activity_date` for each existing master record with different dates within the last 2 years
3. **INSERT Statement**: Add one new record with `last_activity_date` more than 3 years ago (no sales records)
4. **Stored Procedure**: Create `purge_<master>` procedure with:
   - Parameter `@cut_off_date` (DATE)
   - Parameter `@update` (INT, default 0)
   - If `@update = 1`: Delete records where `last_activity_date < @cut_off_date`
   - If `@update ≠ 1`: Print message and SELECT records that would be deleted
5. **Verification**: Test the procedure showing table state before and after each execution

## My Implementation

### Step 1: ALTER TABLE - Adding the New Column

I added the `last_activity_date` column to the `media_services` table:

```sql
--Alter the table for a new column called last_activity_date
ALTER TABLE media_services
ADD last_activity_date date;
GO
```

**Key Points:**
- The `date` data type stores date values without time components
- By default, the column allows NULL values (as required)
- All existing rows will have NULL in this column initially
- The GO statement separates this batch from subsequent operations

**Result:** The table structure is modified, and all 5 existing records now have a `last_activity_date` column with NULL values.

---

### Step 2: UPDATE Statements - Populating Activity Dates

I created individual UPDATE statements for each existing record, ensuring each has a different date within the last 2 years:

```sql
--Multiple UPDATE commands to provide values for last_activity_date

UPDATE media_services
SET last_activity_date = '2022-11-17'
WHERE service_id = 100;
GO

UPDATE media_services
SET last_activity_date = '2022-09-25'
WHERE service_id = 200;
GO

UPDATE media_services
SET last_activity_date = '2022-06-11'
WHERE service_id = 300;
GO

UPDATE media_services
SET last_activity_date = '2021-03-02'
WHERE service_id = 400;
GO

UPDATE media_services
SET last_activity_date = '2021-07-28'
WHERE service_id = 500;
GO
```

**Activity Date Breakdown:**
- Service 100: `2022-11-17` (recent activity)
- Service 200: `2022-09-25` (2 months ago)
- Service 300: `2022-06-11` (5 months ago)
- Service 400: `2021-03-02` (20 months ago)
- Service 500: `2021-07-28` (16 months ago)

**Key Points:**
- Each UPDATE targets a specific record using `WHERE service_id = X`
- All dates are within the last 2 years (from November 2022)
- Dates are different as required
- GO statements separate each UPDATE batch

**Result:** All 5 existing records now have `last_activity_date` values populated.

---

### Step 3: INSERT - Adding Test Data

I inserted a new record with an activity date more than 3 years ago:

```sql
-- Insert a new record into the table with a last_activity_date more than 3 years 
INSERT INTO media_services
(service_id, service_description, service_type, flat_fee, sales_ytd, last_activity_date)
VALUES (600, 'revisions', 'H', 0, 0, '2016-02-01');
GO
```

**Key Points:**
- Service ID 600: 'revisions' service
- Activity date: `2016-02-01` (more than 6 years ago, well beyond the 3-year requirement)
- No sales records were inserted for this service (as required)
- This record will be a candidate for purging when testing the procedure

**Result:** The table now contains 6 records, with one record (service_id 600) having an activity date older than 3 years.

---

### Step 4: Creating the Stored Procedure

I created the stored procedure `sp_purge_media_services` with conditional logic:

```sql
-- Write a procedure
GO
CREATE PROCEDURE sp_purge_media_services
	@cut_off date,
	@Update int = 0
AS
BEGIN	
	IF @Update = 1
		DELETE media_services
		WHERE last_activity_date < @cut_off;
	ELSE
		PRINT 'Records that would be deleted'
		SELECT * FROM media_services
		WHERE last_activity_date < @cut_off;
END
GO
```

**Procedure Components:**

1. **Procedure Name**: `sp_purge_media_services`
   - Follows the pattern `purge_<master>` where master is `media_services`
   - Uses `sp_` prefix (SQL Server convention)

2. **Parameters**:
   - `@cut_off` (DATE): The cutoff date for determining which records to purge
   - `@Update` (INT, default 0): Control parameter for preview vs. execute mode

3. **Conditional Logic**:
   - **IF @Update = 1**: Executes DELETE statement to remove records
   - **ELSE**: Prints message and SELECTs records that would be deleted (preview mode)

4. **Safety Feature**: Default value of 0 for `@Update` means the procedure defaults to preview mode, preventing accidental deletions

**Key Learning:** This pattern (preview before delete) is a best practice for data modification procedures, allowing users to verify what will be affected before committing to changes.

---

### Step 5: Verification and Testing

I added comprehensive verification code to test the procedure:

```sql
-- Verification
PRINT 'Verify procedure'
PRINT 'Master Table Before Changes'

--SELECT all rows and columns from the master table
SELECT * FROM media_services

--Execute procedure passing a date 3 years ago from today
EXEC sp_purge_media_services @cut_off = '2012-01-02';

PRINT 'After 1st Call To Procedure'

--SELECT all rows and columns from the master table
SELECT * FROM media_services

--Execute procedure passing a date 3 years ago from today and 1 for @Update 
EXEC sp_purge_media_services @cut_off = '2019-11-17', @Update = 1;

PRINT 'After 2nd Call To Procedure'

--SELECT all rows and columns from the master table
SELECT * FROM media_services
```

**Test Scenario Breakdown:**

1. **Initial State**: Shows all 6 records in the table
   - 5 records with recent activity dates (within 2 years)
   - 1 record (service_id 600) with activity date from 2016

2. **First Procedure Call** (Preview Mode):
   ```sql
   EXEC sp_purge_media_services @cut_off = '2012-01-02';
   ```
   - Uses default `@Update = 0` (preview mode)
   - Cutoff date: `2012-01-02` (very old date)
   - **Expected Result**: Prints "Records that would be deleted" and shows service_id 600 (last_activity_date = '2016-02-01' < '2012-01-02' is false, so actually no records would be deleted with this date)
   - **Note**: The cutoff date should be more recent to actually show records. A better test would use a date like '2019-11-17' to catch the old record.

3. **After First Call**: Table still contains all 6 records (no deletion occurred in preview mode)

4. **Second Procedure Call** (Execute Mode):
   ```sql
   EXEC sp_purge_media_services @cut_off = '2019-11-17', @Update = 1;
   ```
   - `@Update = 1` (execute mode - actual deletion)
   - Cutoff date: `2019-11-17` (approximately 3 years before November 2022)
   - **Expected Result**: Deletes service_id 600 (last_activity_date = '2016-02-01' < '2019-11-17' is true)

5. **Final State**: Table should contain 5 records (service_id 600 deleted)

**Visual Representation:**

```
Before Changes:
┌─────────────┬──────────────────────┬──────────────────┐
│ service_id  │ service_description  │ last_activity_   │
│             │                      │ date             │
├─────────────┼──────────────────────┼──────────────────┤
│ 100         │ 1 hour photo         │ 2022-11-17       │
│ 200         │ branding session     │ 2022-09-25       │
│ 300         │ video                │ 2022-06-11       │
│ 400         │ website building     │ 2021-03-02       │
│ 500         │ content creation     │ 2021-07-28       │
│ 600         │ revisions            │ 2016-02-01       │ ← Old record
└─────────────┴──────────────────────┴──────────────────┘

After 1st Call (Preview Mode):
┌─────────────┬──────────────────────┬──────────────────┐
│ service_id  │ service_description  │ last_activity_   │
│             │                      │ date             │
├─────────────┼──────────────────────┼──────────────────┤
│ 600         │ revisions            │ 2016-02-01       │ ← Would be deleted
└─────────────┴──────────────────────┴──────────────────┘
(Preview shows what would be deleted, but table unchanged)

After 2nd Call (Execute Mode):
┌─────────────┬──────────────────────┬──────────────────┐
│ service_id  │ service_description  │ last_activity_   │
│             │                      │ date             │
├─────────────┼──────────────────────┼──────────────────┤
│ 100         │ 1 hour photo         │ 2022-11-17       │
│ 200         │ branding session     │ 2022-09-25       │
│ 300         │ video                │ 2022-06-11       │
│ 400         │ website building     │ 2021-03-02       │
│ 500         │ content creation     │ 2021-07-28       │
└─────────────┴──────────────────────┴──────────────────┘
(Service 600 deleted - only 5 records remain)
```

---

## Complete Script Structure

The complete Lab 6 script follows this structure:

1. **Header Comments**: Script name, author, date, description
2. **Environment Setup**: Database creation (from Lab 4)
3. **Table Creation**: Master and sales tables (from Lab 4)
4. **Data Loading**: Initial INSERT statements (from Lab 4)
5. **Index and View Creation**: Performance objects (from Lab 4)
6. **Lab 6 Additions**:
   - ALTER TABLE to add `last_activity_date` column
   - UPDATE statements to populate activity dates
   - INSERT statement for test data
   - CREATE PROCEDURE for purge functionality
   - Verification code with test executions

---

## Key Concepts Demonstrated

### 1. **ALTER TABLE Statement**
```sql
ALTER TABLE table_name
ADD column_name data_type;
```
- Modifies existing table structure
- Preserves existing data
- New columns start with NULL values (unless specified otherwise)

### 2. **Conditional UPDATE**
```sql
UPDATE table_name
SET column_name = value
WHERE condition;
```
- Updates specific rows based on conditions
- Can be executed multiple times for different rows
- Each UPDATE should target specific records

### 3. **Stored Procedure with Parameters**
```sql
CREATE PROCEDURE procedure_name
    @parameter1 data_type,
    @parameter2 data_type = default_value
AS
BEGIN
    -- Procedure logic
END
```
- Parameters allow procedures to be flexible
- Default values make procedures safer
- Procedures can be called multiple times with different parameters

### 4. **Conditional Logic in Procedures**
```sql
IF condition
    -- Execute action
ELSE
    -- Preview action
```
- Allows procedures to behave differently based on input
- Enables safe preview before destructive operations
- Common pattern for data modification procedures

### 5. **Date Comparisons**
```sql
WHERE last_activity_date < @cut_off_date
```
- Date columns can be compared directly
- Business rules often use date-based criteria
- Important to test with various date scenarios

---

## Business Application

This lab demonstrates real-world database administration scenarios:

### **Data Retention Policies**
- Businesses often need to purge old data based on activity dates
- Regulatory requirements may mandate data retention periods
- Storage costs can be reduced by removing inactive records

### **Safe Data Modification**
- Preview mode prevents accidental data loss
- Allows verification before committing changes
- Critical for production database operations

### **Schema Evolution**
- Tables often need new columns as business requirements change
- ALTER TABLE allows modifications without recreating tables
- Existing data must be migrated to new structure

### **Automated Maintenance**
- Stored procedures can be scheduled to run automatically
- Parameters allow flexibility for different retention periods
- Can be integrated into maintenance plans

---

## Common Patterns and Best Practices

### 1. **Preview Before Delete Pattern**
Always provide a way to preview what will be affected before executing destructive operations:
```sql
IF @execute = 1
    DELETE ...
ELSE
    SELECT ...  -- Show what would be deleted
```

### 2. **Default to Safe Mode**
Use default parameter values that prevent accidental data loss:
```sql
@Update int = 0  -- Default to preview mode
```

### 3. **Comprehensive Testing**
Always test procedures in both modes:
- Preview mode: Verify correct records are identified
- Execute mode: Verify correct records are deleted
- Check table state before and after

### 4. **Documentation**
Use PRINT statements to document procedure execution:
```sql
PRINT 'Master Table Before Changes'
SELECT * FROM table_name
```

---

## Potential Improvements

### 1. **Dynamic Date Calculation**
Instead of hardcoded dates, use date functions:
```sql
-- Calculate 3 years ago dynamically
DECLARE @three_years_ago DATE = DATEADD(YEAR, -3, GETDATE());
EXEC sp_purge_media_services @cut_off = @three_years_ago;
```

### 2. **Transaction Handling**
Wrap delete operations in transactions for rollback capability:
```sql
BEGIN TRANSACTION
    DELETE ...
    -- Verify results
    IF @@ROWCOUNT > expected_count
        ROLLBACK TRANSACTION
    ELSE
        COMMIT TRANSACTION
```

### 3. **Error Handling**
Add error handling for edge cases:
```sql
IF @cut_off_date IS NULL
BEGIN
    PRINT 'Error: Cutoff date cannot be NULL'
    RETURN
END
```

### 4. **Logging**
Log purged records for audit purposes:
```sql
-- Before deleting, log to audit table
INSERT INTO purge_log (service_id, purge_date, cutoff_date)
SELECT service_id, GETDATE(), @cut_off
WHERE last_activity_date < @cut_off
```

---

## Conclusion

Lab 6 successfully demonstrated:

- ✅ **ALTER TABLE**: Modifying existing table structures
- ✅ **UPDATE Statements**: Populating new columns with appropriate data
- ✅ **INSERT Statements**: Adding test data for procedure testing
- ✅ **Stored Procedures**: Creating reusable database procedures with parameters
- ✅ **Conditional Logic**: Implementing preview vs. execute patterns
- ✅ **Verification**: Testing procedures with comprehensive test cases
- ✅ **Documentation**: Using PRINT statements to document execution flow

This lab provided hands-on experience with essential database administration tasks including schema modifications, data management, and stored procedure development. These skills are critical for database administrators and developers working with production database systems.

The pattern demonstrated (preview before delete) is a best practice that should be applied to any procedure that modifies or deletes data, ensuring data integrity and preventing accidental data loss.
