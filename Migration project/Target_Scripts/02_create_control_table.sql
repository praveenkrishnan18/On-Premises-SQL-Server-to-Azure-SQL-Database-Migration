/* ================================================================
   02_create_control_table.sql
   Run on: AZURE SQL DATABASE (SalesDB)
   Purpose: Create dbo.ETL_Control, the checkpoint table shared by
            PL_Incremental_Load and PL_CDC_Load.

   ETL_Control maintains TWO INDEPENDENT checkpoints per table:
       LastWatermark    -> updated ONLY by PL_Incremental_Load
       LastProcessedLSN -> updated ONLY by PL_CDC_Load
   These are never merged into a single concept.

   NOTE: This script does NOT set a starting LastProcessedLSN.
   The CDC baseline LSN is captured separately and only once, from
   the SOURCE server, in 08_initialize_cdc_baseline.sql. Do not
   hard-code a runtime LSN value here — it is not reusable across
   environments/rebuilds.
   ================================================================ */

CREATE TABLE dbo.ETL_Control
(
    TableName         VARCHAR(100) NOT NULL,
    LastWatermark     DATETIME2(3) NULL,
    LastProcessedLSN  VARCHAR(22) NULL,
    LastRunStatus     VARCHAR(30) NULL,
    LastRunTime       DATETIME2(3) NULL,
    ColumnList        VARCHAR(1000) NULL,

    CONSTRAINT PK_ETL_Control
        PRIMARY KEY (TableName)
);
GO

INSERT INTO dbo.ETL_Control
(
    TableName,
    LastWatermark,
    LastProcessedLSN,
    LastRunStatus,
    LastRunTime
)
VALUES
('Customers',   NULL, NULL, NULL, NULL),
('Products',    NULL, NULL, NULL, NULL),
('Orders',      NULL, NULL, NULL, NULL),
('OrderItems',  NULL, NULL, NULL, NULL);
GO

/* ColumnList is required by PL_CDC_Load (used as item().ColumnList
   when building the CDC net-changes SELECT for each table). It
   must be populated here — do not hard-code column lists inside
   ADF expressions. */
UPDATE dbo.ETL_Control
SET ColumnList =
    CASE TableName
        WHEN 'Customers'
            THEN 'CustomerID, CustomerName, Email, City, State, ModifiedDate'
        WHEN 'Products'
            THEN 'ProductID, ProductName, Category, Price, ModifiedDate'
        WHEN 'Orders'
            THEN 'OrderID, CustomerID, OrderDate, Status, TotalAmount, ModifiedDate'
        WHEN 'OrderItems'
            THEN 'OrderItemID, OrderID, ProductID, Quantity, UnitPrice, ModifiedDate'
    END;
GO

SELECT * FROM dbo.ETL_Control;
