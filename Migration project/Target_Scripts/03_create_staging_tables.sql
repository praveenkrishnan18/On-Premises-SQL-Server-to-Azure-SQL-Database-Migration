/* ================================================================
   03_create_staging_tables.sql
   Run on: AZURE SQL DATABASE (SalesDB)
   Purpose: Create the stg schema and staging tables used as the
            landing zone for both PL_Incremental_Load and
            PL_CDC_Load before MERGE into the dbo tables.

   CDC_Operation values:
       NULL -> normal / full / watermark staging (no operation flag)
       I    -> CDC INSERT
       U    -> CDC UPDATE
       D    -> CDC DELETE

   Defined directly in the table (not added later via ALTER TABLE)
   so a fresh build only needs one pass.

   No primary/foreign keys on staging tables — the working design
   does not require them (rows are truncated and reloaded each run).
   ================================================================ */

CREATE SCHEMA stg;
GO

CREATE TABLE stg.Customers
(
    CustomerID      INT NOT NULL,
    CustomerName    NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(150) NULL,
    City            NVARCHAR(100) NULL,
    State           NVARCHAR(100) NULL,
    ModifiedDate    DATETIME2(3) NOT NULL,
    CDC_Operation   CHAR(1) NULL
);
GO

CREATE TABLE stg.Products
(
    ProductID       INT NOT NULL,
    ProductName     NVARCHAR(150) NOT NULL,
    Category        NVARCHAR(100) NULL,
    Price           DECIMAL(12,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL,
    CDC_Operation   CHAR(1) NULL
);
GO

CREATE TABLE stg.Orders
(
    OrderID         INT NOT NULL,
    CustomerID      INT NOT NULL,
    OrderDate       DATETIME2(3) NOT NULL,
    Status          VARCHAR(30) NOT NULL,
    TotalAmount     DECIMAL(14,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL,
    CDC_Operation   CHAR(1) NULL
);
GO

CREATE TABLE stg.OrderItems
(
    OrderItemID     INT NOT NULL,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NOT NULL,
    UnitPrice       DECIMAL(12,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL,
    CDC_Operation   CHAR(1) NULL
);
GO
