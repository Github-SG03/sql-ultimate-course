/* ==========================30xSQL Performance Tips===============
   1.This section demonstrates best practices for fetching data, filtering,
   joins, UNION, aggregations, subqueries/CTE, DDL, and indexing.
   It covers techniques such as selecting only necessary columns,
   proper filtering methods, explicit joins, avoiding redundant logic,
   and efficient indexing strategies.
   
   2.Table of Contents:
     1. FETCHING DATA
     2. FILTERING
     3. JOINS
     4. UNION
     5. AGGREGATIONS
     6. SUBQUERIES, CTE
     7. DDL
     8. INDEXING
===================================================================*/
-- ###############################################################
-- #                        FETCHING DATA                        #
-- ###############################################################

-- ============================================
-- Tip 1: Select Only What You Need
-- ============================================

-- Bad Practice
SELECT * FROM Sales.Customers

-- Good Practice
SELECT CustomerID, FirstName, LastName FROM Sales.Customers

-- ============================================
-- Tip 2: Avoid unnecessary DISTINCT & ORDER BY
-- ============================================

-- Bad Practice
SELECT DISTINCT 
	FirstName 
FROM Sales.Customers 
ORDER BY FirstName

-- Good Practice
SELECT 
	FirstName 
FROM Sales.Customers

-- ============================================
-- Tip 3: For Exploration Purpose, Limit Rows!
-- ============================================

-- Bad Practice
SELECT 
	OrderID,
	Sales 
FROM Sales.Orders

-- Good Practice
SELECT TOP 10 
	OrderID,
	Sales 
FROM Sales.Orders

-- ###########################################################
-- #                        FILTERING                        #
-- ###########################################################

/* ==============================================================================
   Tip 4: Create nonclustered Index on frequently used Columns in WHERE clause
===============================================================================*/

SELECT *
FROM Sales.Orders
WHERE OrderStatus = 'Delivered';

CREATE NONCLUSTERED INDEX Idx_Orders_OrderStatus ON Sales.Orders(OrderStatus)

/* ==============================================================================
   Tip 5: Avoid applying functions to columns in WHERE clauses
===============================================================================*/

-- Bad Practice
SELECT * FROM Sales.Orders 
WHERE LOWER(OrderStatus) = 'delivered'

-- Good Practice
SELECT * FROM Sales.Orders 
WHERE OrderStatus = 'Delivered'
---------------------------------------------------------
-- Bad Practice
SELECT * 
FROM Sales.Customers
WHERE SUBSTRING(FirstName, 1, 1) = 'A'

-- Good Practice
SELECT * 
FROM Sales.Customers
WHERE FirstName LIKE 'A%'
---------------------------------------------------------
-- Bad Practice
SELECT * 
FROM Sales.Orders 
WHERE YEAR(OrderDate) = 2025

-- Good Practice
SELECT * 
FROM Sales.Orders 
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-12-31'

/* ==============================================================================
   Tip 6: Avoid leading wildcards as they prevent index usage
===============================================================================*/

-- Bad Practice
SELECT * 
FROM Sales.Customers 
WHERE LastName LIKE '%Gold%'

-- Good Practice
SELECT * 
FROM Sales.Customers 
WHERE LastName LIKE 'Gold%'

/* ==============================================================================
   Tip 7: Use IN instead of Multiple OR
===============================================================================*/

-- Bad Practice
SELECT * 
FROM Sales.Orders
WHERE CustomerID = 1 OR CustomerID = 2 OR CustomerID = 3

-- Good Practice
SELECT * 
FROM Sales.Orders
WHERE CustomerID IN (1, 2, 3)

-- #######################################################
-- #                        JOINS                        #
-- #######################################################

/* ==============================================================================
   Tip 8: Understand The Speed of Joins & Use INNER JOIN when possible
===============================================================================*/

-- Best Performance
SELECT c.FirstName, o.OrderID FROM Sales.Customers c INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID

-- Slightly Slower Performance
SELECT c.FirstName, o.OrderID FROM Sales.Customers c RIGHT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
SELECT c.FirstName, o.OrderID FROM Sales.Customers c LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID

-- Worst Performance
SELECT c.FirstName, o.OrderID FROM Sales.Customers c FULL OUTER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID

/* ==============================================================================
   Tip 9: Use Explicit Join (ANSI Join) Instead of Implicit Join (non-ANSI Join)
===============================================================================*/

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers c, Sales.Orders o
WHERE c.CustomerID = o.CustomerID

-- Good Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID;

--For simple queries: There is no measurable performance difference if both ANSI and non-ANSI queries are correctly written.
--For complex queries: ANSI joins are usually easier to optimize and debug because their structure makes the intent of the query clearer.

/* ==============================================================================
   Tip 10: Make sure to Index the columns used in the ON clause
===============================================================================*/

SELECT c.FirstName, o.OrderID
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c
    ON c.CustomerID = o.CustomerID;

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID ON Sales.Orders(CustomerID)

/* ==============================================================================
   Tip 11: Filter Before Joining (Big Tables)
===============================================================================*/

-- Best Practice For Small-Medium Tables
-- Filter After Join (WHERE)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus = 'Delivered';

-- Filter During Join (ON)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
   AND o.OrderStatus = 'Delivered';

-- Best Practice For Big Tables
-- Filter Before Join (SUBQUERY)
SELECT c.FirstName, o.OrderID
FROM Sales.Customers AS c
INNER JOIN (
    SELECT OrderID, CustomerID
    FROM Sales.Orders
    WHERE OrderStatus = 'Delivered'
) AS o
    ON c.CustomerID = o.CustomerID;

/* ==============================================================================
   Tip 12: Aggregate Before Joining (Big Tables)
===============================================================================*/

-- Best Practice For Small-Medium Tables
-- Grouping and Joining
SELECT c.CustomerID, c.FirstName, COUNT(o.OrderID) AS OrderCount
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName;

-- Best Practice For Big Tables
-- Pre-aggregated Subquery
SELECT c.CustomerID, c.FirstName, o.OrderCount
FROM Sales.Customers AS c
INNER JOIN (
    SELECT CustomerID, COUNT(OrderID) AS OrderCount
    FROM Sales.Orders
    GROUP BY CustomerID
) AS o
    ON c.CustomerID = o.CustomerID;

-- Bad Practice
-- Correlated Subquery
SELECT 
    c.CustomerID, 
    c.FirstName,
    (SELECT COUNT(o.OrderID)
     FROM Sales.Orders AS o
     WHERE o.CustomerID = c.CustomerID) AS OrderCount
FROM Sales.Customers AS c;

/* ==============================================================================
   Tip 13: Use Union Instead of OR in Joins
===============================================================================*/

-- Bad Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
    OR c.CustomerID = o.SalesPersonID;

-- Best Practice
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
UNION
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.SalesPersonID;

/* ==============================================================================
   Tip 14: Check for Nested Loops and Use SQL HINTS
===============================================================================*/

SELECT o.OrderID, c.FirstName
FROM Sales.Customers c
INNER JOIN Sales.Orders o 
ON c.CustomerID = o.CustomerID

-- Good Practice for Having Big Table & Small Table
SELECT o.OrderID, c.FirstName
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID
OPTION (HASH JOIN);

-- ################################################################
-- #                           UNION                              #
-- ################################################################

/* ==============================================================================
   Tip 15: Use UNION ALL instead of using UNION | duplicates are acceptable
===============================================================================*/

-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive 

-- Best Practice
SELECT CustomerID FROM Sales.Orders
UNION ALL
SELECT CustomerID FROM Sales.OrdersArchive 

/* =======================================================================================
   Tip 16: Use UNION ALL + Distinct instead of using UNION | duplicates are not acceptable
========================================================================================*/

-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive 

-- Best Practice
SELECT DISTINCT CustomerID
FROM (
    SELECT CustomerID FROM Sales.Orders
    UNION ALL
    SELECT CustomerID FROM Sales.OrdersArchive
) AS CombinedData


-- ##########################################################
-- #                     AGGREGATIONS                       #
-- ##########################################################

/* ==============================================================================
   Tip 17: Use Columnstore Index for Aggregations on Large Table
===============================================================================*/

SELECT CustomerID, COUNT(OrderID) AS OrderCount
FROM Sales.Orders 
GROUP BY CustomerID

CREATE CLUSTERED COLUMNSTORE INDEX Idx_Orders_Columnstore ON Sales.Orders

/* ==============================================================================
   Tip 18: Pre-Aggregate Data and store it in new Table for Reporting
===============================================================================*/

SELECT MONTH(OrderDate) OrderYear, SUM(Sales) AS TotalSales
INTO Sales.SalesSummary
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

SELECT OrderYear, TotalSales FROM Sales.SalesSummary


-- ##############################################################
-- #                       SUBQUERIES, CTE                      #
-- ##############################################################

/* ==============================================================================
   Tip 19: JOIN vs EXISTS vs IN (Avoid using IN)
===============================================================================*/

-- JOIN (Best Practice: If the Performance equals to EXISTS)
SELECT o.OrderID, o.Sales
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA';

-- EXISTS (Best Practice: Use it for Large Tables)
SELECT o.OrderID, o.Sales
FROM Sales.Orders AS o
WHERE EXISTS (
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'USA'
);

-- IN (Bad Practice)
SELECT o.OrderID, o.Sales
FROM Sales.Orders AS o
WHERE o.CustomerID IN (
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'USA'
);

/* ==============================================================================
   Tip 20: Avoid Redundant Logic in Your Query
===============================================================================*/

-- Bad Practice
SELECT EmployeeID, FirstName, 'Above Average' AS Status
FROM Sales.Employees
WHERE Salary > (SELECT AVG(Salary) FROM Sales.Employees)
UNION ALL
SELECT EmployeeID, FirstName, 'Below Average' AS Status
FROM Sales.Employees
WHERE Salary < (SELECT AVG(Salary) FROM Sales.Employees);

-- Good Practice
SELECT 
    EmployeeID, 
    FirstName, 
    CASE 
        WHEN Salary > AVG(Salary) OVER () THEN 'Above Average'
        WHEN Salary < AVG(Salary) OVER () THEN 'Below Average'
        ELSE 'Average'
    END AS Status
FROM Sales.Employees;

-- ##############################################################
-- #                             DDL                            #
-- ##############################################################
/*
=============================================================================
Tip 21: Avoid VARCHAR Data Type If Possible
=============================================================================
Tip 22: Avoid Using MAX or Overly Large Lengths
=============================================================================
Tip 23: Use NOT NULL If possible 
=============================================================================
Tip 24: Make sure all tables have a CLUSTERED PRIMARY KEY
=============================================================================
Tip 25: Creeate Nonclustered Index on Foreign Key if they are frequently used
=============================================================================*/

/*-- Bad Practice 
CREATE TABLE CustomersInfo (
    CustomerID INT,
    FirstName VARCHAR(MAX),
    LastName TEXT,
    Country VARCHAR(255),
    TotalPurchases FLOAT, 
    Score VARCHAR(255),
    BirthDate VARCHAR(255),
    EmployeeID INT,
    CONSTRAINT FK_Bad_Customers_EmployeeID FOREIGN KEY (EmployeeID)
        REFERENCES Sales.Employees(EmployeeID)
);

-- Good Practice Practice 
CREATE TABLE CustomersInfo (
    CustomerID INT PRIMARY KEY CLUSTERED,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    TotalPurchases FLOAT,
    Score INT,
    BirthDate DATE,
    EmployeeID INT,
    CONSTRAINT FK_CustomersInfo_EmployeeID FOREIGN KEY (EmployeeID)
        REFERENCES Sales.Employees(EmployeeID)
);
CREATE NONCLUSTERED INDEX IX_CustomersInfo_EmployeeID
ON CustomersInfo(EmployeeID);

-- ##############################################################
-- #                        INDEXING                            #
-- ##############################################################
/*================================================================
Tip 26: Avoid Over Indexing, as it can slow down insert, update, and delete operations
===================================================================
Tip 27: Regularly review and drop unused indexes to save space and improve write performance
===================================================================
Tip 28: Update table statistics weekly to ensure the query optimizer has the most up-to-date information
===================================================================
Tip 29: Reorganize and rebuild fragmented indexes weekly to maintain query performance.
===================================================================
Tip 30: For large tables (e.g., fact tables), partition the data and then apply a columnstore index for best performance results
===================================================================*/

--=====================================================================
 --Subquery Vs CTE vs Temp Vs CTAS VS View | Quick Comparison
--=====================================================================
/*
✅ SQL Comparison (Simple + Structured)
📌 1) Easy One-Line Meaning
Type	Simple Meaning
Subquery	Query inside another query
CTE	Named temporary query
Temp Table	Temporary stored table
CTAS	Create table from query
View	Saved virtual query
📌 2) Storage (Where Data is Kept)
Type	Storage
Subquery	Memory
CTE	Memory
Temp Table	Disk
CTAS	Disk
View	No storage
📌 3) Lifetime (How Long It Exists)
Type	Lifetime
Subquery	Only while query runs
CTE	Only while query runs
Temp Table	Till session ends
CTAS	Permanent
View	Permanent
📌 4) When Deleted
Type	Deleted When
Subquery	Query ends
CTE	Query ends
Temp Table	Session ends
CTAS	Manually dropped
View	Manually dropped
📌 5) Scope (Where You Can Use It)
Type	Scope
Subquery	One query only
CTE	One query only
Temp Table	Many queries
CTAS	Many queries
View	Many queries
📌 6) Reusability (Reuse Level)
Type	Reusability
Subquery	Low
CTE	Low
Temp Table	Medium
CTAS	High
View	High
📌 7) Can We Update Data?
Type	Can Update?
Subquery	✅ Yes
CTE	✅ Yes
Temp Table	❌ No (mostly)
CTAS	❌ No
View	✅ Yes (sometimes)
✅ 8) Best Use Case (Very Important)
Use	Which One
Small logic inside query	Subquery
Clean complex query	CTE
Store temp results	Temp Table
Build reporting table	CTAS
Reusable logic	View
✅ 9) One-Line Exam / Interview Answer

Subquery and CTE are temporary in memory, Temp and CTAS store data on disk, and View stores only query logic.

*/


/*
  THEROITICAL EXPLANATION IN REAL TIME USE CASES:
 
Technical Comparative Analysis: SQL Subqueries, CTEs, Views, CTAS, and Temporary Tables

1. The Challenge of Modern Analytical Environments

In professional data environments, the transition from simple data retrieval to complex analytical use cases introduces significant architectural strain. As multiple users hit the database simultaneously with disparate, unoptimized logic, the lack of a structured query strategy creates "query bloat." Managing this complexity, reducing logic redundancy, and ensuring high performance and security are critical strategic mandates. In multi-user environments, failure to implement a rigorous architectural approach leads to five primary technical challenges:

* Logic Complexity: Analysts must write increasingly convoluted queries for multi-step calculations, making the code nearly impossible to debug or peer-review.
* Logic Redundancy: Multiple users frequently rewrite the same complex logic across different scripts, creating "multiple versions of the truth" and inconsistent results.
* Performance Degradation: Repeatedly executing unoptimized or redundant logic from hundreds of users places an unsustainable burden on database resources.
* Security Vulnerabilities: Without structured objects (like views), it is difficult to manage granular, secure access to specific logic or data subsets without exposing underlying schemas.
* Maintainability Hurdles: Updating a single business rule requires manual, error-prone changes across every individual query using that logic throughout the organization.

To mitigate these challenges, architects utilize five advanced techniques for real data projects: Subqueries, Common Table Expressions (CTEs), Views, Create Table As Select (CTAS), and Temporary Tables.

2. Architectural Dimensions: Storage and Persistence

The utility of a query technique is dictated by its underlying architecture—specifically where the data resides and how long it persists. As an architect, I evaluate these based on system resource impact and persistence requirements.

* Memory/Cache-Based Storage (Subqueries, CTEs): The database stores intermediate results in memory (cache) during execution. This allows the main query fast access to temporary results without hitting the disk.
* Disk-Based Storage (CTAS, Temp Tables): These methods create physical or semi-physical structures on the disk. CTAS creates a permanent table, while Temporary Tables consume disk space for the duration of a session.
* The "No Data Storage" Exception (Views): A View is strictly a stored query definition. It stores zero data. Every single time a View is called, the database engine must go back to the original source tables and fetch the data on the fly.
* Short-Term vs. Permanent Persistence:
  * Subqueries and CTEs live only during the execution of the query. Once the query ends, the database clears the cache immediately.
  * Temporary Tables persist for the duration of the user session. Once the session is closed, the database automatically drops the table.
  * CTAS and Views are permanent objects. From a governance perspective, these objects will never be deleted automatically; they require a manual DDL DROP command to be removed from the database schema.

These architectural constraints define the scope of accessibility and the long-term resource footprint of your data project.

3. Operational Scope and Reusability

Query scope and reusability are strategic levers used to eliminate logic redundancy and reduce development overhead. We categorize these techniques by how easily they can be leveraged across the organization.

* Internal Scope (Subqueries, CTEs): Restricted to a single query execution. They are "private" logic and cannot be called by external scripts.
* External/Session Scope (Temporary Tables): Accessible across multiple queries, but only by the user who created them within a specific session.
* Global Scope (Views, CTAS): Permanent objects accessible to all authorized users across different sessions, making them the gold standard for shared logic.

Reusability Scaling:

1. Lowest (Subqueries): The worst for reusability. A subquery is confined to one specific place in a query. If you need that logic elsewhere, you must repeat the code, violating DRY (Don't Repeat Yourself) principles.
2. Limited (CTEs): Highly superior to subqueries because a single CTE can be referenced in multiple joins within the same query. You define the logic once at the top and join it wherever needed, though it remains localized to that script.
3. Medium (Temporary Tables): These allow logic reuse across multiple queries in a session, but the requirement to recreate them in every new session limits their scaling potential.
4. Highest (Views and CTAS): These offer maximum reusability. By persisting the logic (Views) or the results (CTAS) in the database, you eliminate logic repetition across the entire organization.

4. Data Integrity: Freshness and Update Mechanisms

The "So What?" of data management is data freshness. Architects must balance the need for performance against the requirement for real-time accuracy.

* On-the-fly Execution (Subqueries, CTEs, and Views): These are always 100% up-to-date. Subqueries and CTEs execute at runtime. Because Views store no data and fetch from the source every time, they reflect the absolute current state of the database.
* Static Execution (CTAS and Temporary Tables): These create a point-in-time "snapshot." If the underlying source data changes, these tables become "stale" immediately. To refresh the data, there is a manual architectural cost: you must drop the table and create it again from the query.

5. Strategic Selection: Expert Rankings and Decision Framework

In my practice, I utilize a clear hierarchy to choose between these tools, prioritizing maintainability and performance.

1. Views: My first choice. They provide the highest reusability and guaranteed freshness without wasting storage.
2. CTEs: The preferred method for organizing complex logic within a single script. Warning: I enforce a limit of five CTEs per query. Exceeding this "Annoyance Factor" severely degrades code readability and maintainability.
3. Subqueries: Used only for quick, one-off logic preparation where reusability is not a concern.
4. CTAS (Create Table As Select): This is my performance fail-safe. If a View is too complex and takes approximately 30 minutes or more to execute, I jump to CTAS. This generates a physical table so that other analysts can access the pre-calculated results instantly.
5. Temporary Tables: This is the last option on my list and one I rarely use, reserved only for very specific session-based intermediate processing.

6. Workflow Synthesis: From Schema Design to Analytical Output

A professional data pipeline is a collaborative lifecycle where different roles apply these techniques as the project matures.

* Foundational Setup: A Data Engineer initiates the project with DDL to create physical tables and INSERT statements to populate the raw data.
* Initial Data Exploration: A Data Scientist or Analyst begins by using Subqueries to handle "two-step logic," where the first step prepares a specific subset of data for the final retrieval step.
* Logic Refinement: As the analysis grows complex, the analyst moves that logic into CTEs. This allows them to join the same prepared logic multiple times in one script without repeating code.
* Logic Persistence: Once the logic is finalized and proven valuable, it is saved as a View. This persists the logic for the entire organization, allowing others to benefit without writing a single line of join logic themselves.
* Performance Optimization: If the View becomes a bottleneck (exceeding our 30-minute threshold), the Architect utilizes CTAS to generate a physical table. This allows the organization to reuse the results of the complex logic at high speed, trading off real-time freshness for operational efficiency.

By strategically navigating these five techniques, data professionals transform a simple SELECT statement into a robust, high-performance analytical ecosystem.


*/