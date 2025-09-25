/* ==============================================================================
   SQL Data Definition Language (DDL)
-------------------------------------------------------------------------------
   This guide covers the essential DDL commands used for defining and managing
   database structures, including creating, modifying, and deleting tables.

   Table of Contents:
     1. CREATE - Creating Tables
     2. ALTER - Modifying Table Structure
     3. DROP - Removing Tables
     4. RENAME - Renaming the database objects
     5. SYNONYM - Referencing Other database objevt from same table
=================================================================================*/

--This statement lists all databases in the SQL Server:
SELECT 
    name
FROM 
    master.sys.databases

--Or you can execute the stored procedure sp_databases
EXEC sp_databases;


--This staement list all the schemas in the SQL SERVER:
SELECT 
    name
FROM 
    master.sys.schemas;

--or you can execute the stored procedure sp_databases
/* ============================================================================== 
   CREATE
=============================================================================== */

--Create a new database called DemoDatabase (optional here in this learning)
CREATE DATABASE DemoDatabase;
use DemoDatabase;
go

--or either use the existinb database 'MyDatabase'
use MyDatabase;
go

-- CREATE SCHEMA statement to create the customer_services schema:
CREATE SCHEMA customer_services;
GO

/* Create a new  regular table called persons 
   with columns: id, person_name, birth_date, and phone */
CREATE TABLE MyDatabase.dbo.persons (
    id           INT IDENTITY(1,1) NOT NULL,
    person_name  VARCHAR(50)       NOT NULL,
    birth_date   DATE              NULL,
    phone        VARCHAR(15)       UNIQUE,
    CONSTRAINT pk_persons PRIMARY KEY (id),
    CONSTRAINT chk_phone CHECK (phone LIKE '[0-9-%()+ ]%' AND LEN(phone) BETWEEN 7 AND 15)
   -- CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES procurement.vendor_groups(group_id)
);


--Create global temporary tables using CREATE TABLE statement & insert data into it
/*CREATE TABLE ##haro_products (
    product_name VARCHAR(MAX),
    list_price DEC(10,2)
);
INSERT INTO ##heller_products
SELECT
    product_name,
    list_price
FROM 
    demo.persons
WHERE
    email = ;
*/

/* ============================================================================== 
   ALTER
=============================================================================== */

-- Add a new column called email to the persons table
ALTER TABLE persons
ADD email VARCHAR(50) NOT NULL

-- Remove the column phone from the persons table
ALTER TABLE persons
DROP COLUMN phone


--modify column email
ALTER TABLE persons
ALTER COLUMN email VARCHAR(25) NOT NULL


ALTER TABLE persons
ADD full_name AS (first_name + ' ' + last_name); --computed columns

/* ============================================================================== 
   DROP
=============================================================================== */
--The following example uses the DROP DATABASE statement to delete the TestDb database:
DROP DATABASE IF EXISTS TestDb;

--The following example uses the DROP SCHEMA 'customer_services'
DROP SCHEMA if EXISTS customer_services;

-- Truncate and delete data from the table persons (before dropping the table)
TRUNCATE TABLE dbo.persons;
DELETE FROM MyDatabase.dbo.persons;

-- Delete the table persons from the database
DROP TABLE persons;


/* ============================================================================== 
   RENAME
=============================================================================== */
EXEC sp_rename 'person', 'persons';

/* ============================================================================== 
   SEQUENCE
=============================================================================== */
--create a sequence 'order_number'
CREATE SEQUENCE customer_services.order_number
as int
start with 1
increment by 1;

--see the results
SELECT NEXT VALUE FOR customer_services.order_number;

/* ============================================================================== 
   SYNONYM
=============================================================================== */
CREATE SYNONYM suppliers 
FOR DemoDatabase.dbo.DemoTables;

SELECT * FROM suppliers;


/* ============================================================================== 
   SELECT INTO
=============================================================================== */
SELECT    
    customer_id, 
    first_name, 
    last_name, 
    email
INTO 
    TestDb.dbo.customers
FROM    
    sales.customers
WHERE 
    state = 'CA';
