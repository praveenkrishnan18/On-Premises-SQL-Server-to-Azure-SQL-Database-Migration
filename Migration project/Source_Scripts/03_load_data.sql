/* ================================================================
   03_load_data.sql
   Run on: ON-PREMISES SQL SERVER (MigrationSourceDB)
   Purpose: Load the sample CSV data (from /Data) into the source
            tables using BULK INSERT.

   IMPORTANT:
   Update the file path below to the local folder containing the
   CSV files before running BULK INSERT. 'C:\Data\...' is an
   example path from the original build machine, not a universal
   location.
   ================================================================ */

USE MigrationSourceDB;
GO

BULK INSERT dbo.Customers
FROM 'C:\Data\customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    TABLOCK
);

BULK INSERT dbo.Products
FROM 'C:\Data\products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    TABLOCK
);

BULK INSERT dbo.Orders
FROM 'C:\Data\orders.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    TABLOCK
);

BULK INSERT dbo.OrderItems
FROM 'C:\Data\order_items.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    TABLOCK
);
GO

/* Quick sanity check on row counts */
SELECT 'Customers' AS TableName, COUNT(*) AS RowCount FROM dbo.Customers
UNION ALL
SELECT 'Products',  COUNT(*) FROM dbo.Products
UNION ALL
SELECT 'Orders',    COUNT(*) FROM dbo.Orders
UNION ALL
SELECT 'OrderItems',COUNT(*) FROM dbo.OrderItems;
