/*==============================SQL SERVER PIVOT===============================
PURPOSE
- PIVOT turns row values into columns and applies an aggregate in the process.
- Useful for turning categories (months, regions, statuses) into columns.

TABLE OF CONTENTS
1) BASIC IDEA
2) STANDARD SYNTAX
3) SIMPLE EXAMPLE
4) PIVOT WITH COUNT / AVG
5) MULTI-KEY PIVOT (Year + Region)
6) HANDLING NULLS
7) DYNAMIC PIVOT
8) UNPIVOT (REVERSE)
9) COMMON ERRORS + TIPS

===============================================================================
1) BASIC IDEA
Input (rows):
Year | Month | Sales
2024 | Jan   | 100
2024 | Feb   | 120

Output (columns):
Year | Jan | Feb
2024 | 100 | 120

-------------------------------------------------------------------------------
2) STANDARD SYNTAX
SELECT <static_columns>, <pivot_columns>
FROM
(
    <source_query>
) AS src
PIVOT
(
    <aggregate>(<value_column>)
    FOR <pivot_column> IN ([value1], [value2], [value3], ...)
) AS p;

NOTES
- PIVOT always needs an aggregate: SUM, COUNT, AVG, MAX, MIN
- IN list must be explicit (static list of column values)
- Output column names come from IN list values

-------------------------------------------------------------------------------
3) SIMPLE EXAMPLE (SUM)
-- Source table
-- dbo.MonthlySales(Year, Month, Sales)

SELECT Year, [Jan], [Feb], [Mar]
FROM
(
    SELECT Year, Month, Sales
    FROM dbo.MonthlySales
) AS src
PIVOT
(
    SUM(Sales)
    FOR Month IN ([Jan], [Feb], [Mar])
) AS p;

-------------------------------------------------------------------------------
4) PIVOT WITH COUNT / AVG
-- Count orders per month
SELECT Year, [Jan], [Feb], [Mar]
FROM
(
    SELECT Year, Month, OrderID
    FROM dbo.Orders
) AS src
PIVOT
(
    COUNT(OrderID)
    FOR Month IN ([Jan], [Feb], [Mar])
) AS p;

-- Average sales per month
SELECT Year, [Jan], [Feb], [Mar]
FROM
(
    SELECT Year, Month, Sales
    FROM dbo.MonthlySales
) AS src
PIVOT
(
    AVG(Sales)
    FOR Month IN ([Jan], [Feb], [Mar])
) AS p;

-------------------------------------------------------------------------------
5) MULTI-KEY PIVOT (Year + Region)
SELECT Year, Region, [Jan], [Feb], [Mar]
FROM
(
    SELECT Year, Region, Month, Sales
    FROM dbo.MonthlySales
) AS src
PIVOT
(
    SUM(Sales)
    FOR Month IN ([Jan], [Feb], [Mar])
) AS p;

-------------------------------------------------------------------------------
6) HANDLING NULLS
-- Missing data becomes NULL; use ISNULL to show 0
SELECT
    Year,
    ISNULL([Jan], 0) AS Jan,
    ISNULL([Feb], 0) AS Feb,
    ISNULL([Mar], 0) AS Mar
FROM
(
    SELECT Year, Month, Sales
    FROM dbo.MonthlySales
) AS src
PIVOT
(
    SUM(Sales)
    FOR Month IN ([Jan], [Feb], [Mar])
) AS p;

-------------------------------------------------------------------------------
7) DYNAMIC PIVOT (WHEN COLUMNS UNKNOWN)
DECLARE @cols NVARCHAR(MAX);
DECLARE @sql  NVARCHAR(MAX);

SELECT @cols = STRING_AGG(QUOTENAME(Month), ',')
FROM (SELECT DISTINCT Month FROM dbo.MonthlySales) AS m;

SET @sql = '
SELECT Year, ' + @cols + '
FROM
(
    SELECT Year, Month, Sales
    FROM dbo.MonthlySales
) AS src
PIVOT
(
    SUM(Sales)
    FOR Month IN (' + @cols + ')
) AS p;';

EXEC sp_executesql @sql;

-------------------------------------------------------------------------------
8) UNPIVOT (REVERSE OPERATION)
-- Convert columns back to rows
SELECT Year, Month, Sales
FROM dbo.PivotedSales
UNPIVOT
(
    Sales FOR Month IN ([Jan], [Feb], [Mar])
) AS u;

-------------------------------------------------------------------------------
9) COMMON ERRORS + TIPS
- Always give aliases to subquery and pivot result (src, p)
- Pivot column values must match the IN list exactly
- If you need multiple measures, use separate pivots or conditional aggregation
- Conditional aggregation alternative:

SELECT
    Year,
    SUM(CASE WHEN Month = 'Jan' THEN Sales END) AS Jan,
    SUM(CASE WHEN Month = 'Feb' THEN Sales END) AS Feb,
    SUM(CASE WHEN Month = 'Mar' THEN Sales END) AS Mar
FROM dbo.MonthlySales
GROUP BY Year;

===============================================================================*/
