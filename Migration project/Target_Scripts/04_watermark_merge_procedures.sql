/* ================================================================
   04_watermark_merge_procedures.sql
   Run on: AZURE SQL DATABASE (SalesDB)
   Purpose: MERGE procedures used by PL_Incremental_Load. These
            process rows staged from a plain watermark filter
            (CDC_Operation is NULL) — matched rows are updated,
            unmatched rows are inserted. There is no delete
            semantics here; deletes are handled only by CDC
            (see 06_cdc_merge_procedures.sql).
   ================================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Merge_Customers
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.Customers AS T
    USING stg.Customers AS S
        ON T.CustomerID = S.CustomerID

    WHEN MATCHED THEN
        UPDATE SET
            T.CustomerName = S.CustomerName,
            T.Email = S.Email,
            T.City = S.City,
            T.State = S.State,
            T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
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

CREATE OR ALTER PROCEDURE dbo.usp_Merge_Products
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.Products AS T
    USING stg.Products AS S
        ON T.ProductID = S.ProductID

    WHEN MATCHED THEN
        UPDATE SET
            T.ProductName = S.ProductName,
            T.Category = S.Category,
            T.Price = S.Price,
            T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
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

CREATE OR ALTER PROCEDURE dbo.usp_Merge_Orders
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.Orders AS T
    USING stg.Orders AS S
        ON T.OrderID = S.OrderID

    WHEN MATCHED THEN
        UPDATE SET
            T.CustomerID = S.CustomerID,
            T.OrderDate = S.OrderDate,
            T.Status = S.Status,
            T.TotalAmount = S.TotalAmount,
            T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
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

CREATE OR ALTER PROCEDURE dbo.usp_Merge_OrderItems
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.OrderItems AS T
    USING stg.OrderItems AS S
        ON T.OrderItemID = S.OrderItemID

    WHEN MATCHED THEN
        UPDATE SET
            T.OrderID = S.OrderID,
            T.ProductID = S.ProductID,
            T.Quantity = S.Quantity,
            T.UnitPrice = S.UnitPrice,
            T.ModifiedDate = S.ModifiedDate

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
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
