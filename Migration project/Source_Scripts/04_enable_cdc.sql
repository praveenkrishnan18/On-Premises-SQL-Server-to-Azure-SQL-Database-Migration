/* ================================================================
   04_enable_cdc.sql
   Run on: ON-PREMISES SQL SERVER (MigrationSourceDB)
   Purpose: Enable SQL Server Change Data Capture (CDC) at the
            database level and on the four source tables. This is
            SOURCE-side CDC enablement only. CDC merge processing on
            the target lives in Target_Scripts/06_cdc_merge_procedures.sql.

   Prerequisite: SQL Server Agent must be running (the CDC capture
   and cleanup jobs depend on it).
   ================================================================ */

USE MigrationSourceDB;
GO

/* Enable CDC for the database */
EXEC sys.sp_cdc_enable_db;
GO

/* Confirm the database is CDC-enabled */
SELECT
    name,
    is_cdc_enabled
FROM sys.databases
WHERE name = 'MigrationSourceDB';
GO

/* Enable CDC on each source table */
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Customers',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Products',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Orders',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'OrderItems',
    @role_name = NULL,
    @supports_net_changes = 1;
GO

/* Confirm CDC-enabled tables and their capture instances */
SELECT
    capture_instance,
    source_object_id,
    object_id,
    start_lsn
FROM cdc.change_tables;
GO

/* Current max LSN (informational only here — the real baseline
   capture happens in 08_initialize_cdc_baseline.sql) */
SELECT sys.fn_cdc_get_max_lsn() AS MaxLSN;
