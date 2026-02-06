/*==========================SQL SERVER API (PYTHON)=============================
PURPOSE
- Python connects to SQL Server via drivers (ODBC) and libraries (pyodbc, SQLAlchemy).
- Use Python to run queries, load data, automate ETL, and call stored procedures.

TABLE OF CONTENTS
1) DRIVERS + LIBRARIES
2) CONNECTION STRING BASICS
3) CONNECTING (pyodbc)
4) EXECUTING QUERIES
5) PARAMETERIZED QUERIES (SAFE)
6) TRANSACTIONS + COMMIT/ROLLBACK
7) FETCHING RESULTS
8) PANDAS INTEGRATION
9) STORED PROCEDURE CALLS
10) BULK INSERT OPTIONS
11) ERROR HANDLING + TIMEOUTS
12) BEST PRACTICES

-------------------------------------------------------------------------------
1) DRIVERS + LIBRARIES
- ODBC Driver: Microsoft ODBC Driver 17 or 18 for SQL Server
- pyodbc: Low-level ODBC access (fast + common)
- SQLAlchemy: Higher-level ORM/engine layer (works with pandas)
- pymssql: Older driver; less preferred than pyodbc

-------------------------------------------------------------------------------
2) CONNECTION STRING BASICS
- Server name: localhost, .\SQLEXPRESS, IP, or hostname
- Database: target DB
- Authentication:
  - Windows Integrated Security
  - SQL Login (username/password)
- Example (Windows auth):
  Driver={ODBC Driver 17 for SQL Server};
  Server=localhost;
  Database=MyDB;
  Trusted_Connection=yes;

-------------------------------------------------------------------------------
3) CONNECTING (pyodbc)
import pyodbc

conn = pyodbc.connect(
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=localhost;"
    "Database=MyDB;"
    "Trusted_Connection=yes;"
)

-------------------------------------------------------------------------------
4) EXECUTING QUERIES
cursor = conn.cursor()
cursor.execute("SELECT TOP 5 * FROM dbo.Customers")
rows = cursor.fetchall()

-------------------------------------------------------------------------------
5) PARAMETERIZED QUERIES (SAFE)
# Avoid SQL injection by using parameters
cursor.execute(
    "SELECT * FROM dbo.Customers WHERE City = ?",
    ("London",)
)

-------------------------------------------------------------------------------
6) TRANSACTIONS + COMMIT/ROLLBACK
try:
    cursor.execute("UPDATE dbo.Accounts SET Balance = Balance - 100 WHERE Id = 1")
    cursor.execute("UPDATE dbo.Accounts SET Balance = Balance + 100 WHERE Id = 2")
    conn.commit()
except:
    conn.rollback()
    raise

-------------------------------------------------------------------------------
7) FETCHING RESULTS
row = cursor.fetchone()
rows = cursor.fetchall()

for r in rows:
    print(r.Id, r.Name)

-------------------------------------------------------------------------------
8) PANDAS INTEGRATION
import pandas as pd

df = pd.read_sql("SELECT * FROM dbo.Customers", conn)

# Write data back to SQL Server (via SQLAlchemy engine or fast_executemany)
# Prefer SQLAlchemy for to_sql:
# df.to_sql("Customers", engine, if_exists="append", index=False)

-------------------------------------------------------------------------------
9) STORED PROCEDURE CALLS
cursor.execute("EXEC dbo.GetCustomerById ?", (101,))

# If procedure returns rows:
rows = cursor.fetchall()

-------------------------------------------------------------------------------
10) BULK INSERT OPTIONS
- Use pandas to_sql (SQLAlchemy)
- Use pyodbc with fast_executemany = True
- SQL Server native BULK INSERT (from file)
- bcp utility (command line)

-------------------------------------------------------------------------------
11) ERROR HANDLING + TIMEOUTS
- Wrap DB calls in try/except
- Use connection timeouts to avoid hanging
- Always close cursor/connection

conn = pyodbc.connect(conn_str, timeout=10)

-------------------------------------------------------------------------------
12) BEST PRACTICES
- Use parameterized queries always
- Keep credentials in environment variables
- Use context managers for cleanup
- Limit result size with TOP or filters
- Prefer SQLAlchemy for larger projects

===============================================================================*/
/*======================PYTHON API CRUD (SQL SERVER)===========================
PURPOSE
- Perform CRUD (Create, Read, Update, Delete) in SQL Server using Python API
- Uses pyodbc (most common low-level connector)

TABLE OF CONTENTS
1) SETUP + CONNECTION
2) CREATE (INSERT)
3) READ (SELECT)
4) UPDATE
5) DELETE
6) TRANSACTIONS + SAFE PRACTICES

-------------------------------------------------------------------------------
1) SETUP + CONNECTION
import pyodbc

conn = pyodbc.connect(
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=localhost;"
    "Database=MyDB;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()

-------------------------------------------------------------------------------
2) CREATE (INSERT)
# Insert one row
cursor.execute(
    "INSERT INTO dbo.Students (FirstName, LastName, Email, Age) VALUES (?, ?, ?, ?)",
    ("Amit", "Sharma", "amit.sharma@email.com", 21)
)
conn.commit()

# Insert multiple rows
students = [
    ("Neha", "Verma", "neha@email.com", 22),
    ("Rahul", "Singh", "rahul@email.com", 20)
]
cursor.executemany(
    "INSERT INTO dbo.Students (FirstName, LastName, Email, Age) VALUES (?, ?, ?, ?)",
    students
)
conn.commit()

-------------------------------------------------------------------------------
3) READ (SELECT)
cursor.execute("SELECT StudentId, FirstName, LastName, Age FROM dbo.Students")
rows = cursor.fetchall()

for r in rows:
    print(r.StudentId, r.FirstName, r.LastName, r.Age)

# Read with condition
cursor.execute("SELECT * FROM dbo.Students WHERE Age >= ?", (21,))
rows = cursor.fetchall()

-------------------------------------------------------------------------------
4) UPDATE
cursor.execute(
    "UPDATE dbo.Students SET Age = ? WHERE StudentId = ?",
    (23, 1)
)
conn.commit()

-------------------------------------------------------------------------------
5) DELETE
cursor.execute("DELETE FROM dbo.Students WHERE StudentId = ?", (3,))
conn.commit()

-------------------------------------------------------------------------------
6) TRANSACTIONS + SAFE PRACTICES
try:
    cursor.execute("UPDATE dbo.Accounts SET Balance = Balance - 100 WHERE Id = 1")
    cursor.execute("UPDATE dbo.Accounts SET Balance = Balance + 100 WHERE Id = 2")
    conn.commit()
except:
    conn.rollback()
    raise

# Always close
cursor.close()
conn.close()

===============================================================================*/
