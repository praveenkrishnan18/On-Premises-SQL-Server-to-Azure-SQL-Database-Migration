/* ================================================================
   02_watermark_triggers.sql
   Run on: ON-PREMISES SQL SERVER (MigrationSourceDB)
   Purpose: Keep ModifiedDate current on every UPDATE so it can be
            used as the watermark column for PL_Incremental_Load.
   ================================================================ */

USE MigrationSourceDB;
GO

/* Watermark trigger for Customers */
CREATE TRIGGER trg_Customers_ModifiedDate
ON dbo.Customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(ModifiedDate)
    BEGIN
        UPDATE c
        SET ModifiedDate = SYSUTCDATETIME()
        FROM dbo.Customers c
        INNER JOIN inserted i
            ON c.CustomerID = i.CustomerID;
    END
END;
GO

/* Watermark trigger for Products */
CREATE TRIGGER trg_Products_ModifiedDate
ON dbo.Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(ModifiedDate)
    BEGIN
        UPDATE p
        SET ModifiedDate = SYSUTCDATETIME()
        FROM dbo.Products p
        INNER JOIN inserted i
            ON p.ProductID = i.ProductID;
    END
END;
GO

/* Watermark trigger for Orders */
CREATE TRIGGER trg_Orders_ModifiedDate
ON dbo.Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(ModifiedDate)
    BEGIN
        UPDATE o
        SET ModifiedDate = SYSUTCDATETIME()
        FROM dbo.Orders o
        INNER JOIN inserted i
            ON o.OrderID = i.OrderID;
    END
END;
GO

/* Watermark trigger for OrderItems */
CREATE TRIGGER trg_OrderItems_ModifiedDate
ON dbo.OrderItems
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(ModifiedDate)
    BEGIN
        UPDATE oi
        SET ModifiedDate = SYSUTCDATETIME()
        FROM dbo.OrderItems oi
        INNER JOIN inserted i
            ON oi.OrderItemID = i.OrderItemID;
    END
END;
GO
