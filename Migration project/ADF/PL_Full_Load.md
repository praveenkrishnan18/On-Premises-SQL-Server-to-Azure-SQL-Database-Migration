# PL_Full_Load

**Purpose:** One-time initial migration of all rows from `MigrationSourceDB` to `SalesDB`, establishing the baseline that `PL_Incremental_Load` and `PL_CDC_Load` build on afterward.

## Flow

```
ForEach (Customers, Products, Orders, OrderItems)
    -> Copy_Table  (source -> target, full table)
```

## Design

- **Parameterized/reusable** — a single `ForEach` iterates the four table names; the same `Copy_Table` activity runs once per table, using `DS_SQLServer_OnPrem` as source and the parameterized `DS_AzureSQL` (Schema/Table) as sink.
- **Sequential or parallel** — table order doesn't matter for the copy itself, but if you load in dependency order (Customers/Products before Orders before OrderItems) it's easier to sanity-check row counts as you go.
- **Sink tables:** `dbo.Customers`, `dbo.Products`, `dbo.Orders`, `dbo.OrderItems` (loaded directly — full load does not go through staging).

## Baseline established after this pipeline

Full-load checkpoint initialization happens **after** the baseline is successfully established, in two separate steps:

1. Watermark baseline — first `PL_Incremental_Load` run will pick up `NULL` `LastWatermark` and treat everything as new; alternatively, seed `LastWatermark` explicitly per table using `Target_Scripts/07_get_source_watermarks.sql` as a reference and `usp_Update_Control`.
2. CDC baseline LSN — captured explicitly via `Target_Scripts/08_initialize_cdc_baseline.sql`, **once**, right after this full load and before the first `PL_CDC_Load` run.

## Evidence

See `Screenshots/full_load.png` — ADF run output showing `ForEach1` and four successful `Copy_Table` activity runs (one per table), with duration and integration runtime (`SHIR-Local`) visible.
