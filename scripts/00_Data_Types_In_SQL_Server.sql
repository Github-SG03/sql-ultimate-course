/*===========================================================
  SQL Server Data Types – Hands‑On Playground
  Creates database DemoTypes with tables that showcase:
  - Exact numerics
  - Approximate numerics
  - Date & time
  - Character & Unicode
  - Binary
  - Identifiers, variant, XML
  - Spatial
  - Table type & cursor demo notes
===========================================================*/

-- 0) Create a clean sandbox database
IF DB_ID('DemoTypes') IS NULL
    CREATE DATABASE DemoTypes;
GO
USE DemoTypes;
GO

/*===========================================================
  1) Exact numeric types
===========================================================*/
IF OBJECT_ID('dbo.ExactNumeric', 'U') IS NOT NULL DROP TABLE dbo.ExactNumeric;
GO
CREATE TABLE dbo.ExactNumeric
(
    -- Integers: choose the smallest that fits to save space
    TinyIntCol      TINYINT        NOT NULL    -- 0..255, 1 byte; good for small code lists
  , SmallIntCol     SMALLINT       NOT NULL    -- -32,768..32,767, 2 bytes
  , IntCol          INT            NOT NULL    -- -2.1B..2.1B, 4 bytes; common PK type
  , BigIntCol       BIGINT         NOT NULL    -- up to 9e18, 8 bytes; for large counters/IDs

    -- Bit flags: compact boolean(s); can be NULL/0/1
  , IsActive        BIT            NOT NULL    -- 0/1 flag; store simple true/false

    -- Fixed-precision decimals: use when exact money/scale matters (no FP error)
  , DecimalCol      DECIMAL(18,4)  NOT NULL    -- generic fixed precision/scale
  , NumericCol      NUMERIC(10,2)  NOT NULL    -- synonym of DECIMAL; choose one consistently

    -- Money types: fixed scale; use DECIMAL for cross-DB portability/precision control
  , MoneyCol        MONEY          NOT NULL    -- currency with 4 decimal places
  , SmallMoneyCol   SMALLMONEY     NOT NULL    -- smaller range money

    CONSTRAINT PK_ExactNumeric PRIMARY KEY (IntCol)
);
GO

/*===========================================================
  2) Approximate numeric types (floating point)
  Use for scientific/engineering values where small rounding errors are acceptable.
===========================================================*/
IF OBJECT_ID('dbo.ApproxNumeric', 'U') IS NOT NULL DROP TABLE dbo.ApproxNumeric;
GO
CREATE TABLE dbo.ApproxNumeric
(
    -- FLOAT(n): precision depends on n; commonly FLOAT(53) ~ double precision
    FloatCol        FLOAT(53)      NOT NULL    -- ~15–17 digits; wide range; not exact
  , RealCol         REAL           NOT NULL    -- ~7 digits; 4 bytes; smaller precision

    , CONSTRAINT PK_ApproxNumeric PRIMARY KEY (FloatCol)
);
GO

/*===========================================================
  3) Date & time types
  Prefer date, time, datetime2, datetimeoffset for precision & standard alignment.
===========================================================*/
IF OBJECT_ID('dbo.DateTimeTypes', 'U') IS NOT NULL DROP TABLE dbo.DateTimeTypes;
GO
CREATE TABLE dbo.DateTimeTypes
(
    DateOnly            DATE                NOT NULL    -- Calendar date only
  , TimeOnly            TIME(7)             NOT NULL    -- Time of day to 100ns
  , DateTime2_7         DATETIME2(7)        NOT NULL    -- Modern replacement for datetime
  , DateTimeLegacy      DATETIME            NOT NULL    -- Legacy; lower precision; avoid new design
  , SmallDateTimeLegacy SMALLDATETIME       NOT NULL    -- Legacy; minute precision; avoid new design
  , WithTimeZone        DATETIMEOFFSET(7)   NOT NULL    -- Stores UTC offset; use for TZ-aware data

  , CONSTRAINT PK_DateTimeTypes PRIMARY KEY (DateOnly, TimeOnly)
);
GO

/*===========================================================
  4) Character strings (non‑Unicode) and Unicode
  Non‑Unicode = CHAR/VARCHAR (code page dependent).
  Unicode    = NCHAR/NVARCHAR (use for multi‑language text).
  Prefer VARCHAR(MAX)/NVARCHAR(MAX) over deprecated TEXT/NTEXT.
===========================================================*/
IF OBJECT_ID('dbo.StringTypes', 'U') IS NOT NULL DROP TABLE dbo.StringTypes;
GO
CREATE TABLE dbo.StringTypes
(
    -- Fixed length (pads or truncates); good for codes with fixed size
    CharFixed          CHAR(5)             NOT NULL     -- e.g., fixed code like 'INDUS'
  , VarCharShort       VARCHAR(50)         NOT NULL     -- variable ASCII text up to 8000
  , VarCharLong        VARCHAR(MAX)        NULL         -- large ASCII text up to ~2GB

    -- Unicode (stores international scripts); 2 bytes/char
  , NCharFixed         NCHAR(4)            NOT NULL     -- fixed-length Unicode
  , NVarCharShort      NVARCHAR(100)       NOT NULL     -- variable Unicode text (preferred)
  , NVarCharLong       NVARCHAR(MAX)       NULL         -- large Unicode text up to ~2GB

    -- Deprecated legacy text types (for study only; don’t use in new design)
  , TextLegacy         TEXT                NULL         -- deprecated; use VARCHAR(MAX)
  , NTextLegacy        NTEXT               NULL         -- deprecated; use NVARCHAR(MAX)

  , CONSTRAINT PK_StringTypes PRIMARY KEY (CharFixed, NCharFixed)
);
GO

/*===========================================================
  5) Binary strings
  Fixed/variable raw bytes; VARBINARY(MAX) for large blobs.
  IMAGE is deprecated (use VARBINARY(MAX)).
===========================================================*/
IF OBJECT_ID('dbo.BinaryTypes', 'U') IS NOT NULL DROP TABLE dbo.BinaryTypes;
GO
CREATE TABLE dbo.BinaryTypes
(
    BinaryFixed     BINARY(16)       NOT NULL    -- fixed 16 bytes; GUIDs or hashes (if not UNIQUEIDENTIFIER)
  , VarBinarySmall  VARBINARY(256)   NULL        -- small blobs; thumbnails, small files
  , VarBinaryLarge  VARBINARY(MAX)   NULL        -- large blobs; documents, media
  , ImageLegacy     IMAGE            NULL        -- deprecated; use VARBINARY(MAX)

  , CONSTRAINT PK_BinaryTypes PRIMARY KEY (BinaryFixed)
);
GO

/*===========================================================
  6) Identifiers & special
===========================================================*/
IF OBJECT_ID('dbo.IdsAndSpecial', 'U') IS NOT NULL DROP TABLE dbo.IdsAndSpecial;
GO
CREATE TABLE dbo.IdsAndSpecial
(
    -- Identity: auto-increment per table; simple surrogate key
    IdIdentity          INT IDENTITY(1,1)       NOT NULL

    -- GUID: globally unique identifier; random unless using NEWSEQUENTIALID
  , IdGuid              UNIQUEIDENTIFIER        NOT NULL DEFAULT NEWID()

    -- ROWVERSION: auto-generated unique binary per row change; not a time stamp
  , VersionToken        ROWVERSION              NOT NULL

    -- SQL_VARIANT: can hold different underlying types; use sparingly
  , VariantValue        SQL_VARIANT             NULL

    -- XML: typed/untyped XML storage; supports XQuery
  , XmlPayload          XML                     NULL

    , CONSTRAINT PK_IdsAndSpecial PRIMARY KEY (IdIdentity)
    , CONSTRAINT UQ_IdsAndSpecial_Guid UNIQUE (IdGuid)
);
GO

/*===========================================================
  7) Hierarchy & spatial types
===========================================================*/
IF OBJECT_ID('dbo.HierarchyAndSpatial', 'U') IS NOT NULL DROP TABLE dbo.HierarchyAndSpatial;
GO
CREATE TABLE dbo.HierarchyAndSpatial
(
    -- hierarchyid: represents a position in a tree (needs the hierarchyid CLR type installed)
    NodePath            HIERARCHYID         NULL       -- e.g., GetAncestor/GetDescendant for trees

    -- geometry: planar (flat-earth) coordinates
  , ShapePlanar         GEOMETRY            NULL       -- e.g., polygons, points; SRID optional

    -- geography: round-earth coordinates (lat/long)
  , ShapeGeographic     GEOGRAPHY           NULL       -- e.g., POLYGON/POINT with SRID 4326
);
GO

/*===========================================================
  8) Table type & table variable demo
  TABLE type can be used for table variables or TVPs (table‑valued parameters).
===========================================================*/
-- Table type definition
IF TYPE_ID('dbo.PhoneListType') IS NOT NULL DROP TYPE dbo.PhoneListType;
GO
CREATE TYPE dbo.PhoneListType AS TABLE
(
    PhoneLabel  NVARCHAR(20) NOT NULL,
    PhoneNumber NVARCHAR(30) NOT NULL
);
GO

-- Example stored proc using the table type (optional demo)
IF OBJECT_ID('dbo.SavePhones', 'P') IS NOT NULL DROP PROCEDURE dbo.SavePhones;
GO
CREATE PROCEDURE dbo.SavePhones
    @PersonId INT,
    @Phones   dbo.PhoneListType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    -- Demo only: normally you’d upsert into a real Phones table
    SELECT @PersonId AS PersonId, * FROM @Phones;
END
GO

/*===========================================================
  9) Cursor note (cannot be a column type)
  Cursors are variables/proc outputs, not table columns.
===========================================================*/
-- DECLARE @c CURSOR; -- For learning only; avoid cursors unless necessary.

/*===========================================================
  10) Quick INSERT samples so you can test SELECTs
===========================================================*/
INSERT dbo.ExactNumeric
    (TinyIntCol, SmallIntCol, IntCol, BigIntCol, IsActive, DecimalCol, NumericCol, MoneyCol, SmallMoneyCol)
VALUES
    (1, 100, 1, 100000000000, 1, 1234.5678, 99.99, 12345.6789, 12.34);

INSERT dbo.ApproxNumeric (FloatCol, RealCol)
VALUES (3.14159265358979, 3.141593);

INSERT dbo.DateTimeTypes
    (DateOnly, TimeOnly, DateTime2_7, DateTimeLegacy, SmallDateTimeLegacy, WithTimeZone)
VALUES
    (CONVERT(date, GETUTCDATE()),
<<<<<<< HEAD
     SYSDATETIME()::time(7),
=======
     CAST(SYSDATETIME() AS TIME(7)),
>>>>>>> 05d602a (commit)
     SYSDATETIME(),
     GETDATE(),
     CONVERT(smalldatetime, GETDATE()),
     SYSDATETIMEOFFSET());

INSERT dbo.StringTypes
    (CharFixed, VarCharShort, VarCharLong, NCharFixed, NVarCharShort, NVarCharLong, TextLegacy, NTextLegacy)
VALUES
    ('ABCDE', 'ASCII sample', REPLICATE('X', 1000),
     N'कक्षा', N'यूनिकोड उदाहरण', REPLICATE(N'य', 500),
     'legacy text', N'पुराना यूनिकोड');

INSERT dbo.BinaryTypes (BinaryFixed, VarBinarySmall, VarBinaryLarge, ImageLegacy)
VALUES
    (0x0123456789ABCDEF0123456789ABCDEF, 0xDEADBEEF, 0x, NULL);

INSERT dbo.IdsAndSpecial (VariantValue, XmlPayload)
VALUES
    (CAST(123 AS INT), '<order id="1"><item sku="ABC" qty="2"/></order>');

INSERT dbo.HierarchyAndSpatial (NodePath, ShapePlanar, ShapeGeographic)
VALUES
    (hierarchyid::GetRoot().GetDescendant(NULL, NULL),
     geometry::STGeomFromText('POINT (10 20)', 0),
     geography::STGeomFromText('POINT (77.5946 12.9716)', 4326));
GO

/*===========================================================
  11) Cheat‑sheet recap (as inline comments)
  - Exact integers: TINYINT/SMALLINT/INT/BIGINT -> choose smallest that fits.
  - BIT: Boolean flags.
  - DECIMAL/NUMERIC: exact financial/scientific where rounding must be controlled.
  - MONEY/SMALLMONEY: fixed scale; prefer DECIMAL for portability.
  - FLOAT/REAL: approximate; avoid for money/keys.
  - DATE/TIME/DATETIME2/DATETIMEOFFSET: prefer modern types; legacy DATETIME/SMALLDATETIME kept for compat.
  - CHAR/NCHAR: fixed length; codes.
  - VARCHAR/NVARCHAR: variable length; NVARCHAR for international text.
  - (N)TEXT/IMAGE: deprecated → use (N)VARCHAR(MAX)/VARBINARY(MAX).
  - BINARY/VARBINARY: raw bytes; MAX for large blobs.
  - UNIQUEIDENTIFIER: GUID keys; consider NEWSEQUENTIALID for index locality.
  - ROWVERSION: concurrency/change token; not a date/time.
  - SQL_VARIANT: heterogeneous storage; use sparingly.
  - XML: store/query XML; consider JSON (NVARCHAR) + ISJSON() for JSON workloads.
  - hierarchyid: model trees.
  - geometry/geography: spatial.
  - TYPE AS TABLE: TVPs/table variables.
===========================================================*/
