/* ==============================================================================
   SQL Data Manipulation Language (DML)
-------------------------------------------------------------------------------
   This guide covers the essential DML commands used for inserting, updating, 
   and deleting data in database tables.

   Table of Contents:
     1. INSERT - Adding Data to Tables
     2. UPDATE - Modifying Existing Data
     3. DELETE - Removing Data from Tables
     4. MERGE  - Merging two Tables
=================================================================================
*/

/* ============================================================================== 
   INSERT
=============================================================================== */
/* #1 Method: Manual INSERT using VALUES */
-- Insert new records into the customers table
use MyDatabase;
go

INSERT INTO customers (id, first_name, country, score)
VALUES 
    (6, 'Anna', 'USA', NULL),
    (7, 'Sam', NULL, 100)

-- Incorrect column order 
INSERT INTO customers (id, first_name, country, score)
VALUES 
    (8, 'Max', 'USA', NULL)
    
-- Incorrect data type in values
INSERT INTO customers (id, first_name, country, score)
VALUES 
	('Max', 9, 'Max', NULL)

-- Insert a new record with full column values
INSERT INTO customers (id, first_name, country, score)
VALUES (8, 'Max', 'USA', 368)

-- Insert a new record without specifying column names (not recommended)
INSERT INTO customers 
VALUES 
    (9, 'Andreas', 'Germany', NULL)
    
-- Insert a record with only id and first_name (other columns will be NULL or default values)
INSERT INTO customers (id, first_name)
VALUES 
    (10, 'Sahra')

/* #2 Method: INSERT DATA USING SELECT - Moving Data From One Table to Another */
-- Copy data from the 'customers' table into 'persons'
INSERT INTO persons (id, person_name, birth_date, phone)
SELECT
    id,
    first_name,
    NULL,
    'Unknown'
FROM customers

/* ============================================================================== 
   UPDATE
=============================================================================== */

-- Change the score of customer with ID 6 to 0
UPDATE customers
SET score = 0
WHERE id = 6

-- Change the score of customer with ID 10 to 0 and update the country to 'UK'
UPDATE customers
SET score = 0,
    country = 'UK'
WHERE id = 10

-- Update all customers with a NULL score by setting their score to 0
UPDATE customers
SET score = 0
WHERE score IS NULL

-- Verify the update
SELECT *
FROM customers
WHERE score IS NULL

/* ============================================================================== 
   DELETE
=============================================================================== */

-- Select customers with an ID greater than 5 before deleting
SELECT *
FROM customers
WHERE id > 5

-- Delete all customers with an ID greater than 5
DELETE FROM customers
WHERE id > 5

-- Delete all data from the persons table
DELETE FROM persons

-- Faster method to delete all rows, especially useful for large tables
TRUNCATE TABLE persons

/* ============================================================================== 
   MERGE
=============================================================================== */
-- Demo setup
USE tempdb;
GO
IF OBJECT_ID('dbo.Target', 'U') IS NOT NULL DROP TABLE dbo.Target;
IF OBJECT_ID('dbo.Source', 'U') IS NOT NULL DROP TABLE dbo.Source;

CREATE TABLE dbo.Target (
  id INT PRIMARY KEY,
  name VARCHAR(50),
  amount DECIMAL(10,2)
);

CREATE TABLE dbo.Source (
  id INT PRIMARY KEY,
  name VARCHAR(50),
  amount DECIMAL(10,2)
);

INSERT dbo.Target(id,name,amount) VALUES
 (1,'A',10.00),(2,'B',20.00),(3,'C',30.00);

INSERT dbo.Source(id,name,amount) VALUES
 (1,'A',10.00),              -- same as target -> UPDATE does nothing
 (3,'C updated',35.00),      -- exists in both -> UPDATE
 (4,'D new',40.00);          -- only in source -> INSERT

-- MERGE: sync Target to Source by id
BEGIN TRAN

MERGE dbo.Target AS t
USING dbo.Source AS s
  ON s.id = t.id
WHEN MATCHED THEN
  UPDATE SET t.name = s.name, t.amount = s.amount      -- rows 1,3
WHEN NOT MATCHED BY TARGET THEN
  INSERT (id,name,amount) VALUES (s.id,s.name,s.amount) -- row 4
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;                                               -- row 2 is deleted

COMMIT TRAN


SELECT * FROM dbo.Target;  -- Result: {1 A 10.00}, {3 C updated 35.00}, {4 D new 40.00}
