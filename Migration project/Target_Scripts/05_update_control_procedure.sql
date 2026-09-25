/* ================================================================
   05_update_control_procedure.sql
   Run on: AZURE SQL DATABASE (SalesDB)
   Purpose: Single reusable procedure that advances ETL_Control
            checkpoints AFTER a merge succeeds.

   Rules:
     - If @NewWatermark is supplied, update LastWatermark.
     - If @NewLSN is supplied, update LastProcessedLSN.
     - If a parameter is NULL, that checkpoint is left unchanged.
     - Always set LastRunStatus = 'SUCCESS' and LastRunTime = now.

   Usage:
     PL_Incremental_Load calls this passing @NewWatermark only
     (NewLSN omitted/NULL).
     PL_CDC_Load calls this passing @NewLSN only
     (NewWatermark omitted/NULL).
   ================================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Update_Control
    @PipelineName  VARCHAR(100),
    @TableName     VARCHAR(100),
    @NewWatermark  VARCHAR(23) = NULL,
    @NewLSN        VARCHAR(22) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ETL_Control
    SET
        LastWatermark =
            CASE
                WHEN @NewWatermark IS NOT NULL
                THEN CONVERT(DATETIME2(3), @NewWatermark, 121)
                ELSE LastWatermark
            END,

        LastProcessedLSN =
            CASE
                WHEN @NewLSN IS NOT NULL
                THEN @NewLSN
                ELSE LastProcessedLSN
            END,

        LastRunStatus = 'SUCCESS',
        LastRunTime = SYSUTCDATETIME()

    WHERE TableName = @TableName;
END;
GO
