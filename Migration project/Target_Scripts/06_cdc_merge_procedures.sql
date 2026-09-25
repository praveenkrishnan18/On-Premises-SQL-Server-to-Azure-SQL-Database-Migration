/* ================================================================
   06_cdc_merge_procedures.sql
   Run on: AZURE SQL DATABASE (SalesDB)
   Purpose: MERGE procedures used by PL_CDC_Load. Unlike the
            watermark procedures, these read stg.<Table>.CDC_Operation
            to decide the action per row:
                I -> INSERT
                U -> UPDATE
                D -> DELETE

   NOTE: This file was previously (and misleadingly) named
   enable_table_cdc_6.sql. It contains target-side CDC MERGE
   processing only. Source-side CDC enablement lives in
   Source_Scripts/04_enable_cdc.sql — keep these two concepts
   separate.
   ================================================================ */

/* Customers */
CREATE OR ALTER PROCEDURE dbo.usp_CDC_Merge_Customers
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.Customers AS T
    USING stg.Customers AS S
        ON T.CustomerID = S.CustomerID

    -- DELETE
    WHEN MATCHED
         AND S.CDC_Operation = 'D'
    THEN DELETE

    -- UPDATE
    WHEN MATCHED
         AND S.CDC_Operation = 'U'
    THEN UPDATE SET
        T.CustomerName = S.CustomerName,
        T.Email = S.Email,
        T.City = S.City,
        T.State = S.State,
        T.ModifiedDate = S.ModifiedDate

    -- INSERT
    WHEN NOT MATCHED BY TARGET
         AND S.CDC_Operation = 'I'
    THEN INSERT
    (
        CustomerID,
        CustomerName,
        Email,
        City,
        State,
        ModifiedDate
    )
    VALUES
    (
        S.CustomerID,
        S.CustomerName,
        S.Email,
        S.City,
        S.State,
        S.ModifiedDate
    );
END;
GO

/* Products */
CREATE OR ALTER PROCEDURE dbo.usp_CDC_Merge_Products
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.Products AS T
    USING stg.Products AS S
        ON T.ProductID = S.ProductID

    WHEN MATCHED
         AND S.CDC_Operation = 'D'
    THEN DELETE

    WHEN MATCHED
         AND S.CDC_Operation = 'U'
    THEN UPDATE SET
        T.ProductName = S.ProductName,
        T.Category = S.Category,
        T.Price = S.Price,
        T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET
         AND S.CDC_Operation = 'I'
    THEN INSERT
    (
        ProductID,
        ProductName,
        Category,
        Price,
        ModifiedDate
    )
    VALUES
    (
        S.ProductID,
        S.ProductName,
        S.Category,
        S.Price,
        S.ModifiedDate
    );
END;
GO

/* Orders */
CREATE OR ALTER PROCEDURE dbo.usp_CDC_Merge_Orders
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.Orders AS T
    USING stg.Orders AS S
        ON T.OrderID = S.OrderID

    WHEN MATCHED
         AND S.CDC_Operation = 'D'
    THEN DELETE

    WHEN MATCHED
         AND S.CDC_Operation = 'U'
    THEN UPDATE SET
        T.CustomerID = S.CustomerID,
        T.OrderDate = S.OrderDate,
        T.Status = S.Status,
        T.TotalAmount = S.TotalAmount,
        T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET
         AND S.CDC_Operation = 'I'
    THEN INSERT
    (
        OrderID,
        CustomerID,
        OrderDate,
        Status,
        TotalAmount,
        ModifiedDate
    )
    VALUES
    (
        S.OrderID,
        S.CustomerID,
        S.OrderDate,
        S.Status,
        S.TotalAmount,
        S.ModifiedDate
    );
END;
GO

/* OrderItems */
CREATE OR ALTER PROCEDURE dbo.usp_CDC_Merge_OrderItems
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.OrderItems AS T
    USING stg.OrderItems AS S
        ON T.OrderItemID = S.OrderItemID

    WHEN MATCHED
         AND S.CDC_Operation = 'D'
    THEN DELETE

    WHEN MATCHED
         AND S.CDC_Operation = 'U'
    THEN UPDATE SET
        T.OrderID = S.OrderID,
        T.ProductID = S.ProductID,
        T.Quantity = S.Quantity,
        T.UnitPrice = S.UnitPrice,
        T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET
         AND S.CDC_Operation = 'I'
    THEN INSERT
    (
        OrderItemID,
        OrderID,
        ProductID,
        Quantity,
        UnitPrice,
        ModifiedDate
    )
    VALUES
    (
        S.OrderItemID,
        S.OrderID,
        S.ProductID,
        S.Quantity,
        S.UnitPrice,
        S.ModifiedDate
    );
END;
GO

/* Confirm all four CDC merge procedures exist */
SELECT name
FROM sys.procedures
WHERE name LIKE 'usp_CDC_Merge_%';
