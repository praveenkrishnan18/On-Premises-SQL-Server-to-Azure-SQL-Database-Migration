# PL_CDC_Load

**Purpose:** Row-level change capture using SQL Server CDC. Unlike the watermark pipeline, this one also detects **deletes**.

## Flow

```
Lookup_Control
  -> Lookup_MaxLSN
       -> ForEach_Table
            -> If_HasChanges
                 True:
                     Copy_CDC_To_Staging
                     -> SP_CDC_Merge
                     -> SP_Update_Control
                 False:
                     (no-op)
```

## Activity Details

**Lookup_Control**
```sql
SELECT
    TableName,
    ColumnList,
    LastProcessedLSN
FROM dbo.ETL_Control;
```
- First row only: **OFF**

**Lookup_MaxLSN** (via `DS_SQLServer_OnPrem`, run against the SOURCE)
```sql
SELECT CONVERT(
    VARCHAR(22),
    sys.fn_cdc_get_max_lsn(),
    1
) AS MaxLSN;
```
- First row only: **ON**

**ForEach_Table**
- Items: `@activity('Lookup_Control').output.value`
- Sequential: **ON**

**If_HasChanges**
```
@not(
    equals(
        activity('Lookup_MaxLSN').output.firstRow.MaxLSN,
        item().LastProcessedLSN
    )
)
```
If the current source `MaxLSN` equals the table's stored `LastProcessedLSN`, there's nothing new — the branch does nothing and moves to the next table.

**Copy_CDC_To_Staging** (True branch, source query conceptually)
```sql
SELECT
    CASE __$operation
        WHEN 1 THEN 'D'
        WHEN 2 THEN 'I'
        WHEN 4 THEN 'U'
    END AS CDC_Operation,
    <ColumnList>
FROM cdc.fn_cdc_get_net_changes_dbo_<TableName>(
    sys.fn_cdc_increment_lsn(
        CONVERT(BINARY(10), '<LastProcessedLSN>', 1)
    ),
    CONVERT(BINARY(10), '<MaxLSN>', 1),
    N'all'
);
```
- `<ColumnList>` comes from `item().ColumnList` (see `ETL_Control`).
- `<LastProcessedLSN>` comes from `item().LastProcessedLSN`; `<MaxLSN>` from `activity('Lookup_MaxLSN').output.firstRow.MaxLSN`.
- `__$operation` mapping: `1 = D`, `2 = I`, `4 = U`.
- Sink: `stg.<current_table>`
- Pre-copy script: `TRUNCATE TABLE stg.<current_table>`
- Column mapping: left empty (source and target column names match)

**SP_CDC_Merge**
- Stored procedure: `@concat('dbo.usp_CDC_Merge_', item().TableName)`

**SP_Update_Control (CDC branch)**
- Stored procedure: `dbo.usp_Update_Control`
- `PipelineName` = `@pipeline().Pipeline`
- `TableName` = `@item().TableName`
- `NewWatermark` = omitted (this pipeline never touches `LastWatermark`)
- `NewLSN` = `@activity('Lookup_MaxLSN').output.firstRow.MaxLSN`

## Checkpoint rule

Only `LastProcessedLSN` is updated by this pipeline, and only **after** `SP_CDC_Merge` succeeds. A failure before `SP_Update_Control` leaves `LastProcessedLSN` at its old value, so the next run recomputes the same LSN window via `sys.fn_cdc_increment_lsn` — safe to repeat because `SP_CDC_Merge` is a keyed `MERGE`.

## Architecture note

CDC exists **only** on the local source SQL Server in this project. Azure SQL does not own the source CDC log or generate LSNs — it only stores the last **processed** LSN as a checkpoint.

```
Local SQL Server
    CDC
     |
     v
   SHIR
     |
     v
    ADF
     |
     v
Azure SQL ETL_Control
    LastProcessedLSN
```

`sys.fn_cdc_get_max_lsn()` is never called from Azure SQL in this project — it's a source-only function, always invoked through `DS_SQLServer_OnPrem`.

## Evidence

See `Screenshots/cdc_load.png` — ADF run output showing `Lookup_Control` → `Lookup_MaxLSN` → `ForEach_Table`, with `SP_Update_Control_CDC` and `SP_CDC_Merge` succeeding.
