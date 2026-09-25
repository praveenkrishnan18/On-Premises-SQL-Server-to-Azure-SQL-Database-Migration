/* ================================================================
   08_initialize_cdc_baseline.sql
   Purpose: One-time CDC baseline setup, done in TWO steps across
            TWO servers. Run each part where indicated.

   IMPORTANT:
   Do not copy the LSN value that appears in this project's
   screenshots/scripts into a new build — that value is evidence
   from one specific run, not a universal constant. Every fresh
   rebuild must generate its own current LSN in Step 1 below.
   ================================================================ */

/* ---------------------------------------------------------------
   STEP 1 — Run on the SOURCE SQL Server (MigrationSourceDB)
   Capture the current max LSN. This becomes the CDC starting
   point: PL_CDC_Load will only read changes AFTER this LSN.
   --------------------------------------------------------------- */
-- USE MigrationSourceDB;
-- GO

SELECT CONVERT(VARCHAR(22), sys.fn_cdc_get_max_lsn(), 1) AS MaxLSN;


/* ---------------------------------------------------------------
   STEP 2 — Run on AZURE SQL DATABASE (SalesDB)
   Copy the MaxLSN value returned above and paste it in place of
   <CURRENT_SOURCE_MAX_LSN> below. Run this ONCE, right after the
   initial full load, before the first PL_CDC_Load run.
   --------------------------------------------------------------- */
UPDATE dbo.ETL_Control
SET
    LastProcessedLSN = '<CURRENT_SOURCE_MAX_LSN>',
    LastRunStatus = 'CDC_BASELINE',
    LastRunTime = SYSUTCDATETIME()
WHERE TableName IN
(
    'Customers',
    'Products',
    'Orders',
    'OrderItems'
);

SELECT
    TableName,
    LastProcessedLSN,
    LastRunStatus,
    LastRunTime
FROM dbo.ETL_Control;
