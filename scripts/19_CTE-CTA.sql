/* ===========================SQL Common Table Expressions(CTEs)============
   1.A CTE is a named temporary result set that you define within a SQL statement and  then use like a table inside that sql statement. 

   2.It improves readability, reduces duplication, and can make complex queries much easier to understand.
 
   3.This script demonstrates the use of Common Table Expressions (CTEs) in SQL Server.
   It includes examples of non-recursive CTEs for data aggregation and segmentation,
   as well as recursive CTEs for generating sequences and building hierarchical data.

   4.Table of Contents:
     1. NON-RECURSIVE CTE
     2. RECURSIVE CTE | GENERATE SEQUENCE
     3. RECURSIVE CTE | BUILD HIERARCHY

    5.CTE vs Subquery vs CTAs vs Temp Table vs View
       -CTE:Improved readability, reusable within a single query, better for recursion.
       -Subquery:Good for simple filters or quick calculations, can be less readable.
       -Temp Table:Persistent database object within a session, good for complex intermediate results, requires more overhead.
       -CTAS:Creates a new table from a query result, good for creating permanent tables.
       -View:Persistent database object, good for encapsulating complex queries, not reusable within a single query. 
===============================================================================*/
/*=============================================================================
  NON-RECURSIVE CTE(Single CTE)
===============================================================================*/
WITH CTE_Total_Sales AS
    (
        SELECT
            CustomerID,
            SUM(Sales) AS TotalSales
        FROM
            Sales.Orders
        GROUP BY CustomerID
    )
--Main Query
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cts.TotalSales
FROM
    Sales.Customers c
    LEFT JOIN CTE_Total_Sales cts
    ON cts.CustomerID = c.CustomerID;


/*=============================================================================
  NON-RECURSIVE CTE(Multiple CTEs in a single query)
===============================================================================*/
--Step1: Find the total Sales Per Customer (Standalone CTE)
WITH CTE_Total_Sales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders   
    GROUP BY CustomerID
)
-- Step2: Find the last order date for each customer (Standalone CTE)
, CTE_Last_Order AS
(
    SELECT
        CustomerID,
        MAX(OrderDate) AS Last_Order
    FROM Sales.Orders
    GROUP BY CustomerID
)
-- Step3: Rank Customers based on Total Sales Per Customer (Nested CTE)
, CTE_Customer_Rank AS
(
    SELECT
        CustomerID,
        TotalSales,
        RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
    FROM CTE_Total_Sales
)
-- Step4: segment customers based on their total sales (Nested CTE)
, CTE_Customer_Segments AS
(
    SELECT
        CustomerID,
        TotalSales,
        CASE 
            WHEN TotalSales > 100 THEN 'High'
            WHEN TotalSales > 80  THEN 'Medium'
            ELSE 'Low'
        END AS CustomerSegments
    FROM CTE_Total_Sales
)
-- Main Query
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cts.TotalSales,
    clo.Last_Order,
    ccr.CustomerRank,
    ccs.CustomerSegments
FROM Sales.Customers AS c
LEFT JOIN CTE_Total_Sales AS cts
    ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order AS clo
    ON clo.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Rank AS ccr
    ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Segments AS ccs
    ON ccs.CustomerID = c.CustomerID;

/* ==============================================================================
   RECURSIVE CTE | GENERATE SEQUENCE

   Recursive CTEs are used for hierarchies, paths, or tree-like data (e.g., employee → manager)
===============================================================================*/

/* TASK 2:
   Generate a sequence of numbers from 1 to 20.
*/
WITH Series AS (
    -- Anchor Query
    SELECT 1 AS MyNumber
    UNION ALL
    -- Recursive Query
    SELECT MyNumber + 1
    FROM Series
    WHERE MyNumber < 20
)
-- Main Query
SELECT *
FROM Series;

/* TASK 3:
   Generate a sequence of numbers from 1 to 1000.
*/
WITH Series AS
(
    -- Anchor Query
    SELECT 1 AS MyNumber
    UNION ALL
    -- Recursive Query
    SELECT MyNumber + 1
    FROM Series
    WHERE MyNumber < 1000
)
-- Main Query
SELECT *
FROM Series
OPTION (MAXRECURSION 5000);

/* ==============================================================================
   RECURSIVE CTE | BUILD HIERARCHY
===============================================================================*/

/* TASK 4:
   Build the employee hierarchy by displaying each employee's level within the organization.
   - Anchor Query: Select employees with no manager.
   - Recursive Query: Select subordinates and increment the level.
*/
WITH CTE_Emp_Hierarchy AS
(
    -- Anchor Query: Top-level employees (no manager)
    SELECT
        EmployeeID,
        FirstName,
        ManagerID,
        1 AS Level
    FROM Sales.Employees
    WHERE ManagerID IS NULL
    UNION ALL
    -- Recursive Query: Get subordinate employees and increment level
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.ManagerID,
        Level + 1
    FROM Sales.Employees AS e
    INNER JOIN CTE_Emp_Hierarchy AS ceh
        ON e.ManagerID = ceh.EmployeeID
)
-- Main Query
SELECT *
FROM CTE_Emp_Hierarchy;

--####################################CTAs##########################################
/* CTA 1:
    Create a new table named MonthlyOrders that contains the total number of orders for each month.
*/
--###################################################################################
-- Drop table if it already exists(keep refreshing the table for every run)
BEGIN TRAN
   --Check if table exists and drop it
   IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
    DROP TABLE Sales.MonthlyOrders;

    -- Create table using CTAS
    SELECT
    DATENAME(month, OrderDate) AS OrderMonth,
    COUNT(OrderID) AS TotalOrders
    INTO Sales.MonthlyOrders
    FROM Sales.Orders
    GROUP BY DATENAME(month, OrderDate);

COMMIT
GO