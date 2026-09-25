/* ================================================================
   07_get_source_watermarks.sql
   Run on: ON-PREMISES SQL SERVER (MigrationSourceDB)
   Purpose: SOURCE-side diagnostic/reference script only. Shows
            what the current watermark (MAX ModifiedDate) is for
            each table, for manual inspection while testing.

   IMPORTANT:
   This does NOT write to Azure SQL and is not part of the
   pipeline. Azure SQL never queries the on-prem SQL Server
   directly. The actual production watermark advancement happens
   inside ADF, via dbo.usp_Update_Control on the Azure SQL side,
   after PL_Incremental_Load's merge succeeds (see
   05_update_control_procedure.sql). This script previously (and
   incorrectly) tried to update Azure SQL's ETL_Control directly
   from a local SELECT — that is not a valid pattern because
   source and target are separate systems.
   ================================================================ */

USE MigrationSourceDB;
GO

SELECT
    'Customers' AS TableName,
    CONVERT(VARCHAR(23), MAX(ModifiedDate), 121) AS LastWatermark
FROM dbo.Customers

UNION ALL

SELECT
    'Products',
    CONVERT(VARCHAR(23), MAX(ModifiedDate), 121)
FROM dbo.Products

UNION ALL

SELECT
    'Orders',
    CONVERT(VARCHAR(23), MAX(ModifiedDate), 121)
FROM dbo.Orders

UNION ALL

SELECT
    'OrderItems',
    CONVERT(VARCHAR(23), MAX(ModifiedDate), 121)
FROM dbo.OrderItems;
