/* ================================================================
   01_create_source_schema.sql
   Run on: ON-PREMISES SQL SERVER
   Purpose: Create the source database and tables for Project 1.
   ================================================================ */

CREATE DATABASE MigrationSourceDB;
GO

USE MigrationSourceDB;
GO

CREATE TABLE dbo.Customers
(
    CustomerID      INT NOT NULL PRIMARY KEY,
    CustomerName    NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(150) NULL,
    City            NVARCHAR(100) NULL,
    State           NVARCHAR(100) NULL,
    ModifiedDate    DATETIME2(3) NOT NULL
        CONSTRAINT DF_Customers_ModifiedDate
        DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Products
(
    ProductID       INT NOT NULL PRIMARY KEY,
    ProductName     NVARCHAR(150) NOT NULL,
    Category        NVARCHAR(100) NULL,
    Price           DECIMAL(12,2) NOT NULL,
    ModifiedDate    DATETIME2(3) NOT NULL
        CONSTRAINT DF_Products_ModifiedDate
        DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Products_Price CHECK (Price >= 0)
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
        CONSTRAINT DF_Orders_ModifiedDate
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT CK_Orders_TotalAmount
        CHECK (TotalAmount >= 0)
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
        CONSTRAINT DF_OrderItems_ModifiedDate
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (UnitPrice >= 0)
);
GO
