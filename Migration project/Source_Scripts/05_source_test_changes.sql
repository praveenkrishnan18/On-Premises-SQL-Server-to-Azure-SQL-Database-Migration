/* ================================================================
   05_source_test_changes.sql
   Run on: ON-PREMISES SQL SERVER (MigrationSourceDB)
   Purpose: Manual test script used to generate known INSERT,
            UPDATE and DELETE changes on the source so that
            PL_Incremental_Load and PL_CDC_Load have something to
            pick up, and so results can be verified against the
            target afterward (see README "Manual Validation").

   This script is optional and for testing only — it is not part
   of the core pipeline build.
   ================================================================ */

USE MigrationSourceDB;
GO

/* ---- 1. Known UPDATE ----
   Watermark trigger refreshes ModifiedDate automatically.
   Note the CustomerID, City and new ModifiedDate so they can be
   compared against Azure SQL after the pipeline runs. */
UPDATE dbo.Customers
SET City = 'Hyderabad'
WHERE CustomerID = 1;

SELECT CustomerID, City, ModifiedDate
FROM dbo.Customers
WHERE CustomerID = 1;
GO

/* ---- 2. Known INSERT ----
   Use an ID outside the seeded CSV range so it's easy to identify. */
INSERT INTO dbo.Customers (CustomerID, CustomerName, Email, City, State, ModifiedDate)
VALUES (900001, 'Test Insert Customer', 'test.insert@example.com', 'Chennai', 'Tamil Nadu', SYSUTCDATETIME());
GO

/* ---- 3. Known DELETE ----
   CDC captures this as a 'D' operation; the watermark pipeline
   cannot detect deletes — only CDC can. */
DELETE FROM dbo.Customers
WHERE CustomerID = 900001;
GO

/* After running PL_CDC_Load, confirm on the source: */
SELECT * FROM cdc.dbo_Customers_CT
ORDER BY __$start_lsn DESC;
