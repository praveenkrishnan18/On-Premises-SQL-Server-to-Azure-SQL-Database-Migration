/* ================================================================
   01_create_target_tables.sql
   Run on: AZURE SQL DATABASE (SalesDB)
   Purpose: Create the target (serving) tables that mirror the
            source schema. These are the final dbo tables that
            PL_Full_Load, PL_Incremental_Load and PL_CDC_Load all
            write to (via staging + MERGE).
   ================================================================ */

CREATE TABLE dbo.Customers
(
    CustomerID      INT NOT NULL PRIMARY KEY,
    CustomerName    NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(150) NULL,
    City            NVARCHAR(100) NULL,
    State           NVARCHAR(100) NULL,
    ModifiedDate    DATETIME2(3) NOT NULL
);
GO

CREATE TABLE dbo.Products
(
    ProductID       INT NOT NULL PRIMARY KEY,
    ProductName     NVARCHAR(150) NOT NULL,
    Category        NVARCHAR(100) NULL,
    Price           DECIMAL(12,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL
);
GO

CREATE TABLE dbo.Orders
(
    OrderID         INT NOT NULL PRIMARY KEY,
    CustomerID      INT NOT NULL,
    OrderDate       DATETIME2(3) NOT NULL,
    Status          VARCHAR(30) NOT NULL,
    TotalAmount     DECIMAL(14,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL
);
GO

CREATE TABLE dbo.OrderItems
(
    OrderItemID     INT NOT NULL PRIMARY KEY,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NOT NULL,
    UnitPrice       DECIMAL(12,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL
);
GO
