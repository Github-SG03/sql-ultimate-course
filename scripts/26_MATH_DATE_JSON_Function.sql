/*=====================MATH + DATE/TIME + JSON (SQL SERVER)====================
PURPOSE
- Quick reference of common Math, Date/Time, and JSON functions in SQL Server
- Includes theory + examples for each concept

TABLE OF CONTENTS
1) MATH FUNCTIONS
2) DATE/TIME FUNCTIONS
3) JSON FUNCTIONS
4) COMMON PITFALLS + BEST PRACTICES

===============================================================================
1) MATH FUNCTIONS
-------------------------------------------------------------------------------
1.1 ABS (absolute value)
SELECT ABS(-15) AS AbsVal;                      -- 15

1.2 CEILING / FLOOR
SELECT CEILING(12.3) AS UpVal;                  -- 13
SELECT FLOOR(12.9)   AS DownVal;                -- 12

1.3 ROUND
SELECT ROUND(12.3456, 2) AS Round2;             -- 12.35
SELECT ROUND(12.3456, 0) AS Round0;             -- 12
SELECT ROUND(12.3456, -1) AS RoundTens;         -- 10

1.4 POWER / SQRT
SELECT POWER(2, 5) AS TwoPower5;                -- 32
SELECT SQRT(49) AS SqrtVal;                     -- 7

1.5 LOG / EXP
SELECT LOG(10) AS NaturalLog;                   -- ln(10)
SELECT LOG10(1000) AS Log10Val;                 -- 3
SELECT EXP(1) AS EPower1;                       -- e^1

1.6 SIGN
SELECT SIGN(-5) AS SignVal;                     -- -1
SELECT SIGN(0)  AS SignZero;                    -- 0
SELECT SIGN(8)  AS SignPos;                     -- 1

1.7 PI / RADIANS / DEGREES
SELECT PI() AS PiVal;
SELECT RADIANS(180) AS RadVal;                  -- 3.14159...
SELECT DEGREES(PI()) AS DegVal;                 -- 180

1.8 RAND (random number)
SELECT RAND() AS Random0to1;                    -- 0 <= x < 1
-- Use a seed for repeatability:
SELECT RAND(123) AS SeededRand;

1.9 CAST + DECIMAL CONTROL (important for division)
SELECT 5 / 2 AS IntDiv;                         -- 2 (integer division)
SELECT 5.0 / 2 AS DecimalDiv;                   -- 2.5
SELECT CAST(5 AS DECIMAL(10,2)) / 2 AS Precise; -- 2.50

===============================================================================
2) DATE/TIME FUNCTIONS
-------------------------------------------------------------------------------
2.1 CURRENT DATE/TIME
SELECT GETDATE() AS GetDate;        -- datetime (local)
SELECT SYSDATETIME() AS SysDate;    -- datetime2 (local, higher precision)
SELECT CURRENT_TIMESTAMP AS CTime;  -- same as GETDATE()
SELECT SYSUTCDATETIME() AS UtcNow;  -- UTC

2.2 DATEPART / DATENAME
SELECT DATEPART(year, GETDATE()) AS YearPart;
SELECT DATENAME(month, GETDATE()) AS MonthName;

2.3 DATEADD (add interval)
SELECT DATEADD(day, 10, GETDATE()) AS Plus10Days;
SELECT DATEADD(month, -1, GETDATE()) AS Minus1Month;

2.4 DATEDIFF (difference)
SELECT DATEDIFF(day, '2024-01-01', GETDATE()) AS DaysDiff;

2.5 EOMONTH (end of month)
SELECT EOMONTH(GETDATE()) AS EndOfMonth;
SELECT EOMONTH(GETDATE(), 1) AS EndOfNextMonth;

2.6 FORMAT (string formatting)
SELECT FORMAT(GETDATE(), 'yyyy-MM-dd') AS DateISO;
SELECT FORMAT(GETDATE(), 'dd-MMM-yyyy') AS DatePretty;

2.7 CONVERT / CAST (control output)
SELECT CONVERT(date, GETDATE()) AS OnlyDate;
SELECT CONVERT(varchar(19), GETDATE(), 120) AS Style120; -- yyyy-mm-dd hh:mi:ss

2.8 DATEFROMPARTS / TIMEFROMPARTS
SELECT DATEFROMPARTS(2024, 12, 25) AS Xmas;
SELECT TIMEFROMPARTS(14, 30, 15, 0, 0) AS TeaTime;

2.9 DATETIMEFROMPARTS
SELECT DATETIMEFROMPARTS(2024, 12, 25, 10, 30, 0, 0) AS FullDate;

===============================================================================
3) JSON FUNCTIONS
-------------------------------------------------------------------------------
SQL Server stores JSON as NVARCHAR; functions allow querying and shaping JSON.

3.1 ISJSON (validates JSON text)
SELECT ISJSON('{"a":1,"b":"x"}') AS ValidJson;   -- 1
SELECT ISJSON('{bad json}') AS InvalidJson;      -- 0

3.2 JSON_VALUE (extract scalar)
DECLARE @j NVARCHAR(MAX) = N'{"name":"Amit","age":22}';
SELECT JSON_VALUE(@j, '$.name') AS Name;         -- Amit
SELECT JSON_VALUE(@j, '$.age')  AS Age;          -- 22

3.3 JSON_QUERY (extract object/array)
DECLARE @j2 NVARCHAR(MAX) = N'{"skills":["SQL","Python"]}';
SELECT JSON_QUERY(@j2, '$.skills') AS Skills;    -- ["SQL","Python"]

3.4 JSON_MODIFY (update JSON)
DECLARE @j3 NVARCHAR(MAX) = N'{"name":"Amit","age":22}';
SELECT JSON_MODIFY(@j3, '$.age', 23) AS UpdatedJson;

3.5 OPENJSON (parse into rows)
DECLARE @j4 NVARCHAR(MAX) = N'
{
  "students": [
    {"id":1,"name":"Amit"},
    {"id":2,"name":"Neha"}
  ]
}';

SELECT *
FROM OPENJSON(@j4, '$.students')
WITH (
    id   INT         '$.id',
    name NVARCHAR(50) '$.name'
);

3.6 OPENJSON without WITH (key-value)
DECLARE @j5 NVARCHAR(MAX) = N'{"a":10,"b":20}';
SELECT [key], [value], [type]
FROM OPENJSON(@j5);

===============================================================================
4) COMMON PITFALLS + BEST PRACTICES
-------------------------------------------------------------------------------
- Integer division truncates decimals. Use DECIMAL/NUMERIC.
- ROUND uses banker's rounding only for certain precision rules; test if needed.
- GETDATE returns local time; use SYSUTCDATETIME for UTC.
- JSON stored as NVARCHAR; always validate with ISJSON if data is unknown.
- JSON_VALUE returns NULL if path not found or value is not scalar.
- Use TRY_CONVERT / TRY_CAST for safer conversions.

===============================================================================*/
