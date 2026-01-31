# Database Lab 5: Advanced SQL Queries

This lab focused on writing complex SQL queries using various techniques including subqueries, GROUP BY aggregations, multi-table JOINs, and EXISTS predicates. The assignment required creating 10 SELECT statements across 6 different query groups, demonstrating proficiency in different SQL query patterns.

## Assignment Overview

The lab required students to create a SQL script with the following specifications:

- **Database**: The first SQL statement (after the comment block) must be `USE chdb`
- **Query Count**: The script must contain exactly 10 SELECT statements
- **Query Groups**: 6 groups of SELECT scenarios, with specific selection requirements:
  - Group 1: Pick 2 queries (from 4 options)
  - Group 2: Pick 2 queries (from 4 options)
  - Group 3: Pick 2 queries (from 4 options)
  - Group 4: Pick 2 queries (from 4 options)
  - Group 5: Pick 1 query (from 2 options)
  - Group 6: Pick 1 query (from 2 options)
- **Documentation**: Each SELECT statement must have a PRINT statement before it identifying the group and query (e.g., `PRINT 'GROUP 1 SELECT C'`)
- **Result Set Requirements**: 
  - Every result set should have at least one row
  - No result set should have more than 50 rows

## Concepts and Lessons Covered

This lab touched upon several important SQL concepts:

### 1. **Basic Queries with Subqueries**
- Using scalar subqueries in WHERE clauses
- Comparing values against calculated aggregates (AVG, MAX)
- Filtering with multiple conditions

### 2. **Aggregation and GROUP BY**
- Using COUNT() with GROUP BY
- Filtering groups with HAVING clause
- Understanding the difference between WHERE and HAVING

### 3. **Two-Table JOINs**
- INNER JOIN syntax
- Joining tables on foreign key relationships
- Using ORDER BY with joined tables

### 4. **Three-Table JOINs**
- Chaining multiple JOINs together
- Understanding join order and relationships
- Filtering results from multiple tables

### 5. **Four-Table JOINs**
- Complex multi-table relationships
- String concatenation with CONCAT()
- Column aliasing

### 6. **EXISTS Predicate**
- Using NOT EXISTS to find missing relationships
- Correlated subqueries
- Checking for absence of related records

## Assignment Solutions

### Script Header

```sql
/*
I, Marcello De Filippis, student number 000823174, certify that this material is my original work. 
No other person's work has been used without due acknowledgment and I have not made my work available to anyone else.

db name: lab5
Name: Marcello De Filippis
Date: October 24th 2022
*/
USE chdb
```

✅ **Correct**: The script properly starts with `USE chdb` as required.

---

## Group 1: Basic Queries (Selected: B and C)

### GROUP 1 SELECT B: Count of Male Patients Weighing Less Than Average Female Weight

**Assignment Requirement**: Show a count of male patients that weigh less than the average weight of female patients.

**My Solution**:
```sql
PRINT 'GROUP 1 SELECT B '

SELECT COUNT (*)
FROM patients
where gender = 'M' AND patient_weight <
	(SELECT AVG(patient_weight)
	FROM patients
	WHERE gender = 'F'
	)
```

**Analysis**:
- ✅ Correctly uses a scalar subquery to calculate the average weight of female patients
- ✅ Filters for male patients (`gender = 'M'`)
- ✅ Compares patient weight to the calculated average
- ✅ Uses COUNT() to return a single count value

**Concept**: This demonstrates using a **scalar subquery** (returns a single value) in a WHERE clause to compare against an aggregate value calculated from a different subset of data.

---

### GROUP 1 SELECT C: Tallest Female Patients

**Assignment Requirement**: Find the first name, last name, and height of the tallest female patient(s). There may be more than one.

**My Solution**:
```sql
PRINT 'GROUP 1 SELECT C '

SELECT first_name, last_name, patient_height
from patients
WHERE patient_height = 
	(SELECT MAX(patient_height)
	FROM patients
	WHERE gender = 'F')
```

**Issue Identified**: ⚠️ **Missing gender filter in outer query**

**Problem**: The subquery correctly finds the maximum height of female patients, but the outer query doesn't filter for `gender = 'F'`. This could return male patients who happen to have the same height as the tallest female.

**Corrected Solution**:
```sql
PRINT 'GROUP 1 SELECT C '

SELECT first_name, last_name, patient_height
FROM patients
WHERE patient_height = 
	(SELECT MAX(patient_height)
	FROM patients
	WHERE gender = 'F')
AND gender = 'F'  -- Added: Ensure only females are returned
```

**Concept**: When using subqueries to find maximum/minimum values, ensure the outer query filters match the subquery's filter criteria to avoid incorrect results.

---

## Group 2: Sub-totals using GROUP BY (Selected: C and D)

### GROUP 2 SELECT C: Patient Count by Province (Excluding Ontario)

**Assignment Requirement**: Show a count of patients by province except for Ontario.

**My Solution**:
```sql
PRINT 'GROUP 2 SELECT C '

SELECT COUNT(*), province_id
from patients
GROUP BY province_id
HAVING province_id != 'ON'
```

**Analysis**:
- ✅ Correctly uses GROUP BY to aggregate by province
- ✅ Uses COUNT(*) to count patients per province
- ✅ Uses HAVING to filter out Ontario

**Note**: While this works, using WHERE would be more efficient since filtering happens before grouping. However, HAVING is syntactically correct and acceptable.

**Alternative (More Efficient)**:
```sql
SELECT COUNT(*), province_id
FROM patients
WHERE province_id != 'ON'  -- Filter before grouping
GROUP BY province_id
```

**Concept**: **HAVING vs WHERE**: 
- WHERE filters rows before grouping
- HAVING filters groups after aggregation
- Both work, but WHERE is more efficient when filtering on the grouped column

---

### GROUP 2 SELECT D: Gender Count for Patients Taller Than 175cm

**Assignment Requirement**: Show a count of the female, male, and other gender patients that are taller than 175 cm.

**My Solution**:
```sql
PRINT 'GROUP 2 SELECT D '

SELECT COUNT(*), gender
from patients
WHERE patient_height > 175 
GROUP BY gender
```

**Analysis**:
- ✅ Correctly filters for height > 175 before grouping
- ✅ Groups by gender to get counts for each gender category
- ✅ Returns count and gender for each group

**Concept**: This demonstrates proper use of **WHERE before GROUP BY** to filter rows, then grouping the filtered results to get subtotals by category.

---

## Group 3: Two Table JOINs and ORDER BY (Selected: A and B)

### GROUP 3 SELECT A: Current Admissions in Short Stay (2SOUTH)

**Assignment Requirement**: List the patient id, first name, last name, room number, and bed number for every current admission (no discharge date) in Short Stay (2SOUTH). Order the results by the last name.

**My Solution**:
```sql
PRINT 'GROUP 3 SELECT A'

SELECT patients.patient_id, patients.first_name, patients.last_name, admissions.room, admissions.bed
from patients
JOIN admissions
ON patients.patient_id = admissions.patient_id
WHERE nursing_unit_id = '2SOUTH' AND discharge_date is null 
ORDER BY last_name
```

**Analysis**:
- ✅ Correctly joins patients and admissions tables
- ✅ Filters for current admissions (`discharge_date IS NULL`)
- ✅ Filters for the specific nursing unit (`nursing_unit_id = '2SOUTH'`)
- ✅ Orders results by last name
- ✅ Selects all required columns

**Concept**: This demonstrates a **two-table INNER JOIN** where:
- The join condition links patients to their admissions
- Multiple WHERE conditions filter the joined result set
- ORDER BY sorts the final results

---

### GROUP 3 SELECT B: Pharmacists Who Prepared Morphine Unit Dose Orders

**Assignment Requirement**: List the pharmacist's initials, entered date, and dosage for every pharmacist who has made up a Unit Dose Order for Morphine. Order the results by pharmacist initials.

**My Solution**:
```sql
PRINT 'GROUP 3 SELECT B'

SELECT unit_dose_orders.pharmacist_initials, unit_dose_orders.entered_date, unit_dose_orders.dosage, medications.medication_description
FROM unit_dose_orders
JOIN medications
ON unit_dose_orders.medication_id = medications.medication_id
Where medication_description= 'Morphine' 
order by pharmacist_initials
```

**Analysis**:
- ✅ Correctly joins unit_dose_orders and medications tables
- ✅ Filters for Morphine medication
- ✅ Orders by pharmacist initials
- ✅ Includes all required columns

**Note**: The query includes `medication_description` in the SELECT, which is helpful for verification but wasn't explicitly required.

**Concept**: This demonstrates joining tables through a **foreign key relationship** (medication_id) to access related information from another table.

---

## Group 4: Three Table JOINs (Selected: A and B)

### GROUP 4 SELECT A: Physicians Who Encountered Walter Mitty

**Assignment Requirement**: List the physician id, physician's first name, physician's last name, and specialty of any physician who has had an encounter with the patient named Walter Mitty.

**My Solution**:
```sql
PRINT 'GROUP 4 SELECT A'

SELECT 
physicians.physician_id, 
physicians.first_name, 
physicians.last_name,
physicians.specialty, 
encounters.patient_id,
patients.first_name
FROM ((physicians
JOIN encounters ON physicians.physician_id = encounters.physician_id)
JOIN patients ON encounters.patient_id = patients.patient_id)
where patients.first_name = 'Walter'
```

**Issues Identified**: ⚠️ **Missing last name filter** and **includes extra columns**

**Problems**:
1. The WHERE clause only filters for `first_name = 'Walter'` but should also filter for `last_name = 'Mitty'` to match "Walter Mitty"
2. The SELECT includes `encounters.patient_id` and `patients.first_name` which weren't required

**Corrected Solution**:
```sql
PRINT 'GROUP 4 SELECT A'

SELECT 
	physicians.physician_id, 
	physicians.first_name, 
	physicians.last_name,
	physicians.specialty
FROM ((physicians
JOIN encounters ON physicians.physician_id = encounters.physician_id)
JOIN patients ON encounters.patient_id = patients.patient_id)
WHERE patients.first_name = 'Walter' 
AND patients.last_name = 'Mitty'  -- Added: Complete name match
```

**Concept**: This demonstrates a **three-table JOIN chain**:
- physicians → encounters (via physician_id)
- encounters → patients (via patient_id)
- The join order matters: start with the table you want to filter on (patients) or the table you want to return (physicians)

---

### GROUP 4 SELECT B: Current Admissions with Internist Attending Physicians

**Assignment Requirement**: List the patient id, patient first name, patient last name, nursing unit and primary diagnosis of any current admission (no discharge date) whose attending physician's specialty is Internist.

**My Solution**:
```sql
PRINT 'GROUP 4 SELECT B'

SELECT
patients.first_name,
patients.last_name,
admissions.nursing_unit_id,
admissions.primary_diagnosis,
admissions.discharge_date,
physicians.specialty
FROM ((patients
JOIN admissions ON patients.patient_id  = admissions.patient_id)
JOIN  physicians ON admissions.attending_physician_id = admissions.attending_physician_id)
WHERE admissions.discharge_date IS null 
AND physicians.specialty = 'internist'
ORDER BY first_name
```

**Critical Issue Identified**: ❌ **Incorrect JOIN condition**

**Problem**: Line 99 has a self-referencing join condition:
```sql
JOIN physicians ON admissions.attending_physician_id = admissions.attending_physician_id
```

This compares the column to itself, which will always be true but doesn't actually join to the physicians table correctly. It should join to `physicians.physician_id`.

**Corrected Solution**:
```sql
PRINT 'GROUP 4 SELECT B'

SELECT
	patients.patient_id,  -- Added: Required by assignment
	patients.first_name,
	patients.last_name,
	admissions.nursing_unit_id,
	admissions.primary_diagnosis
FROM ((patients
JOIN admissions ON patients.patient_id = admissions.patient_id)
JOIN physicians ON admissions.attending_physician_id = physicians.physician_id)  -- Fixed: Join to physicians.physician_id
WHERE admissions.discharge_date IS NULL 
AND physicians.specialty = 'internist'
ORDER BY first_name
```

**Concept**: This demonstrates the importance of **correct JOIN conditions**. The join must link:
- `admissions.attending_physician_id` (foreign key) → `physicians.physician_id` (primary key)

**Common Mistake**: Accidentally comparing a column to itself instead of to the related table's primary key.

---

## Group 5: Four Table JOINs (Selected: B)

### GROUP 5 SELECT B: Current Admissions Allergic to Penicillin with Medications

**Assignment Requirement**: List the patient first name concatenated with a space and patient last name and aliased as patient, nursing unit, room, and medication description for any current admissions (no discharge date) who are allergic to Penicillin.

**My Solution**:
```sql
PRINT 'GROUP 5 SELECT B'

SELECT
CONCAT(patients.first_name, ' ' ,patients.last_name) AS patient,
admissions.nursing_unit_id,
admissions.room, 
medications.medication_description
FROM (((patients
JOIN admissions ON patients.patient_id = admissions.patient_id)
JOIN unit_dose_orders on patients.patient_id = unit_dose_orders.patient_id)
JOIN medications on unit_dose_orders.medication_id = medications.medication_id)
WHERE allergies = 'Penicillin' and discharge_date is null
```

**Issue Identified**: ⚠️ **Ambiguous column reference**

**Problem**: The `allergies` column is not qualified with a table name. Since `allergies` likely belongs to the `patients` table, it should be `patients.allergies`.

**Corrected Solution**:
```sql
PRINT 'GROUP 5 SELECT B'

SELECT
	CONCAT(patients.first_name, ' ', patients.last_name) AS patient,
	admissions.nursing_unit_id,
	admissions.room, 
	medications.medication_description
FROM (((patients
JOIN admissions ON patients.patient_id = admissions.patient_id)
JOIN unit_dose_orders ON patients.patient_id = unit_dose_orders.patient_id)
JOIN medications ON unit_dose_orders.medication_id = medications.medication_id)
WHERE patients.allergies = 'Penicillin'  -- Fixed: Qualified column name
AND admissions.discharge_date IS NULL
```

**Concept**: This demonstrates a **four-table JOIN**:
1. patients → admissions (via patient_id)
2. patients → unit_dose_orders (via patient_id)
3. unit_dose_orders → medications (via medication_id)

**Key Learning**: Always qualify column names with table aliases in multi-table queries to avoid ambiguity and improve readability.

---

## Group 6: WHERE [NOT] EXISTS (Selected: B)

### GROUP 6 SELECT B: Purchase Orders with No Associated Lines

**Assignment Requirement**: List the purchase order id, order date, and department id for any purchase order that has no associated purchase order lines.

**My Solution**:
```sql
PRINT 'GROUP 6 SELECT B'

SELECT 
purchase_order_id,
order_date,
department_id
FROM purchase_orders
	WHERE NOT EXISTS ( SELECT purchase_order_line_id
	FROM purchase_order_lines 
	WHERE purchase_orders.purchase_order_id = purchase_order_lines.purchase_order_id)
```

**Analysis**:
- ✅ Correctly uses NOT EXISTS to find purchase orders without related lines
- ✅ Uses a correlated subquery (references outer query's `purchase_orders.purchase_order_id`)
- ✅ Returns all required columns
- ✅ The subquery checks for the existence of matching purchase_order_line_id records

**Concept**: This demonstrates the **NOT EXISTS predicate** with a **correlated subquery**:
- For each row in `purchase_orders`, the subquery checks if any matching rows exist in `purchase_order_lines`
- NOT EXISTS returns TRUE when the subquery finds NO matching rows
- This is an efficient way to find "orphaned" records (parent records without children)

**Alternative Approach** (using LEFT JOIN):
```sql
SELECT 
	po.purchase_order_id,
	po.order_date,
	po.department_id
FROM purchase_orders po
LEFT JOIN purchase_order_lines pol ON po.purchase_order_id = pol.purchase_order_id
WHERE pol.purchase_order_line_id IS NULL
```

Both approaches work, but NOT EXISTS is often more intuitive for "find records without related records" queries.

---

## Summary of Issues and Corrections

### Issues Found:

1. **GROUP 1 SELECT C**: Missing `gender = 'F'` filter in outer query
2. **GROUP 4 SELECT A**: Missing `last_name = 'Mitty'` filter; includes extra columns
3. **GROUP 4 SELECT B**: ❌ **Critical**: Incorrect JOIN condition (self-referencing)
4. **GROUP 5 SELECT B**: Unqualified `allergies` column reference

### Requirements Compliance:

✅ **USE chdb statement**: Present and correct  
✅ **10 SELECT statements**: All present  
✅ **Group selections**: Correct (2+2+2+2+1+1 = 10)  
✅ **PRINT statements**: All 10 queries have PRINT statements  
⚠️ **Result set validation**: Cannot verify without running queries (should be tested)

---

## Key Learning Outcomes

### 1. **Subqueries**
- Scalar subqueries return single values for comparison
- Can be used in WHERE clauses to filter based on calculated aggregates
- Must ensure outer query filters match subquery logic

### 2. **GROUP BY and Aggregation**
- GROUP BY creates subtotals by grouping rows
- HAVING filters groups after aggregation
- WHERE filters rows before grouping (more efficient for simple filters)

### 3. **JOIN Operations**
- INNER JOIN combines rows from multiple tables based on matching keys
- Join order matters for readability and sometimes performance
- JOIN conditions must correctly link foreign keys to primary keys
- Always qualify column names in multi-table queries

### 4. **Multi-Table Queries**
- Two-table JOINs: Basic relationships
- Three-table JOINs: Chain relationships through intermediate tables
- Four-table JOINs: Complex relationships requiring careful join order

### 5. **EXISTS Predicate**
- EXISTS checks for the existence of rows in a subquery
- NOT EXISTS finds records without related records
- Correlated subqueries reference the outer query
- Efficient for finding orphaned or missing relationships

### 6. **String Functions**
- CONCAT() combines strings with separators
- Useful for creating readable output (e.g., full names)

### 7. **Query Structure Best Practices**
- Use table aliases for readability
- Qualify all column names in multi-table queries
- Verify JOIN conditions are correct (not self-referencing)
- Test queries to ensure result sets meet requirements (1-50 rows)

---

## Common Mistakes to Avoid

1. **Self-Referencing JOINs**: Always join foreign keys to primary keys, not columns to themselves
2. **Missing Filters**: When using subqueries with filters, ensure outer query filters match
3. **Unqualified Columns**: Always use table prefixes/aliases in multi-table queries
4. **Incomplete Name Matching**: When searching for full names, filter both first and last name
5. **WHERE vs HAVING**: Use WHERE for row filtering, HAVING for group filtering

---

## Conclusion

This lab successfully demonstrated proficiency in:
- ✅ Writing complex SQL queries with multiple techniques
- ✅ Using subqueries for filtering and comparison
- ✅ Aggregating data with GROUP BY
- ✅ Joining multiple tables (2, 3, and 4 tables)
- ✅ Using EXISTS predicates for relationship checking
- ✅ Structuring queries with proper formatting and documentation

The assignment provided comprehensive practice in combining these SQL concepts to solve real-world database query problems, preparing students for more advanced database work and complex reporting requirements.
