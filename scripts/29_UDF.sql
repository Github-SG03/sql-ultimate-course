/*=====================SQL SERVER UDF (USER-DEFINED FUNCTIONS)===================
PURPOSE
- UDFs encapsulate reusable logic in SQL Server.
- They return a value (scalar) or a table (table-valued).
- UDFs are used for standardization, reuse, and cleaner queries.

TABLE OF CONTENTS
1) TYPES OF UDFs
2) BASIC SYNTAX
3) SCALAR UDF EXAMPLES
4) INLINE TABLE-VALUED UDF (iTVF)
5) MULTI-STATEMENT TABLE-VALUED UDF (mTVF)
6) USING UDFS IN QUERIES
7) DETERMINISTIC vs NONDETERMINISTIC
8) SCHEMABINDING
9) LIMITATIONS + PERFORMANCE
10) CREATE / ALTER / DROP
11) INTERVIEW QUESTIONS

===============================================================================
1) TYPES OF UDFs
- Scalar UDF: returns a single value (INT, VARCHAR, DECIMAL, etc.)
- Inline Table-Valued UDF (iTVF): returns a table from one SELECT
- Multi-Statement Table-Valued UDF (mTVF): builds a table via multiple steps

===============================================================================
2) BASIC SYNTAX
CREATE FUNCTION dbo.FunctionName (@param1 INT, @param2 NVARCHAR(50))
RETURNS <data_type>
AS
BEGIN
    -- logic
    RETURN <value>;
END;

===============================================================================
3) SCALAR UDF EXAMPLES
-- Example 1: Calculate 10% tax
CREATE FUNCTION dbo.fn_Tax10 (@amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @amount * 0.10;
END;

SELECT dbo.fn_Tax10(200.00) AS TaxAmount;

-- Example 2: Full name formatter
CREATE FUNCTION dbo.fn_FullName (@first NVARCHAR(50), @last NVARCHAR(50))
RETURNS NVARCHAR(120)
AS
BEGIN
    RETURN RTRIM(@first) + ' ' + RTRIM(@last);
END;

SELECT dbo.fn_FullName('Amit', 'Sharma') AS FullName;

===============================================================================
4) INLINE TABLE-VALUED UDF (iTVF)
-- Returns a table directly from a SELECT statement
CREATE FUNCTION dbo.fn_CustomersByCountry (@country NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT CustomerID, FirstName, LastName, Country
    FROM Sales.Customers
    WHERE Country = @country
);

SELECT *
FROM dbo.fn_CustomersByCountry('USA');

===============================================================================
5) MULTI-STATEMENT TABLE-VALUED UDF (mTVF)
-- Returns a table variable populated with multiple steps
CREATE FUNCTION dbo.fn_TopCustomers (@minScore INT)
RETURNS @Result TABLE
(
    CustomerID INT,
    FullName NVARCHAR(120),
    Score INT
)
AS
BEGIN
    INSERT INTO @Result
    SELECT CustomerID,
           FirstName + ' ' + LastName,
           Score
    FROM Sales.Customers
    WHERE Score >= @minScore;

    RETURN;
END;

SELECT *
FROM dbo.fn_TopCustomers(800);

===============================================================================
6) USING UDFS IN QUERIES
-- Scalar UDF in SELECT
SELECT CustomerID, dbo.fn_FullName(FirstName, LastName) AS FullName
FROM Sales.Customers;

-- iTVF in FROM
SELECT *
FROM dbo.fn_CustomersByCountry('India');

-- CROSS APPLY (useful with table-valued functions)
SELECT c.CustomerID, f.*
FROM Sales.Customers c
CROSS APPLY dbo.fn_CustomersByCountry(c.Country) f;

===============================================================================
7) DETERMINISTIC vs NONDETERMINISTIC
- Deterministic: same input always gives same output
- Nondeterministic: result can change even with same input
Examples:
- Deterministic: ABS(5), UPPER('a')
- Nondeterministic: GETDATE(), NEWID()

===============================================================================
8) SCHEMABINDING
- Prevents underlying tables from being changed
- Can improve performance and allow indexed views
Example:
CREATE FUNCTION dbo.fn_OrdersTotal (@custId INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT OrderID, Amount
    FROM dbo.Orders
    WHERE CustomerID = @custId
);

===============================================================================
9) LIMITATIONS + PERFORMANCE
- Scalar UDFs can be slow in large queries (row-by-row execution)
- iTVFs usually perform better than scalar or mTVFs
- Avoid using UDFs inside WHERE clauses on large tables if possible
- Prefer inline TVFs or computed columns for performance

===============================================================================
10) CREATE / ALTER / DROP
-- Alter UDF
ALTER FUNCTION dbo.fn_Tax10 (@amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @amount * 0.12;
END;

-- Drop UDF
DROP FUNCTION dbo.fn_Tax10;

===============================================================================
11) INTERVIEW QUESTIONS
- What is the difference between scalar and table-valued UDF?
- Why are inline TVFs faster than scalar UDFs?
- When should you avoid UDFs in a query?
- What does SCHEMABINDING do?
- How do you use a UDF with CROSS APPLY?

===============================================================================*/
