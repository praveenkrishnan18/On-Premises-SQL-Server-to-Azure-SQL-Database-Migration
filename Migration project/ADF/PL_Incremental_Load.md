# PL_Incremental_Load

**Purpose:** Watermark-based incremental load. Detects INSERT/UPDATE changes on the source using the `ModifiedDate` column. Does **not** detect deletes — that's what CDC (`PL_CDC_Load`) is for.

## Flow

```
Lookup_Control
  -> ForEach_Table
       -> Lookup_NewWatermark
       -> Copy_To_Staging
       -> SP_Merge
       -> SP_Update_Control
```

## Activity Details

**Lookup_Control**
```sql
SELECT
    TableName,
    CONVERT(VARCHAR(23), LastWatermark, 121) AS LastWatermark
FROM dbo.ETL_Control;
```
- First row only: **OFF**

**ForEach_Table**
- Items: `@activity('Lookup_Control').output.value`
- Sequential: **ON**

**Lookup_NewWatermark** (per table, via `DS_SQLServer_OnPrem`)
```sql
SELECT CONVERT(
    VARCHAR(23),
    ISNULL(MAX(ModifiedDate), '1900-01-01'),
    121
) AS NewWatermark
FROM dbo.<current_table>;
```

**Copy_To_Staging**
- Source filter: `ModifiedDate > LastWatermark AND ModifiedDate <= NewWatermark`
- Sink: `stg.<current_table>`
- Pre-copy script: `TRUNCATE TABLE stg.<current_table>`
- Column mapping: left empty (source and target column names match)

**SP_Merge**
- Stored procedure: `@concat('dbo.usp_Merge_', item().TableName)`

**SP_Update_Control**
- Stored procedure: `dbo.usp_Update_Control`
- `PipelineName` = `@pipeline().Pipeline`
- `TableName` = `@item().TableName`
- `NewWatermark` = `@activity('Lookup_NewWatermark').output.firstRow.NewWatermark`
- `NewLSN` = omitted (this pipeline never touches `LastProcessedLSN`)

## Checkpoint rule

Only `LastWatermark` is updated by this pipeline, and only **after** `SP_Merge` succeeds. If the pipeline fails before `SP_Update_Control` runs, `LastWatermark` stays at its previous value — the next run naturally reprocesses the same window, and the `MERGE` in `SP_Merge` makes that safe to repeat.

## Evidence

See `Screenshots/incremental_load.png` — ADF run output showing `Lookup_Control` → `ForEach_Table` with `Lookup_NewWatermark`, `Copy_To_Staging`, `SP_Merge`, `SP_Update_Control` all succeeding per table.
