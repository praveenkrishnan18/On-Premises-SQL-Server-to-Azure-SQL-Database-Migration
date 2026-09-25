# ADF Build Notes — Linked Services & Datasets

These are shared across all three pipelines (`PL_Full_Load`, `PL_Incremental_Load`, `PL_CDC_Load`).

## Linked Services

| Name | Connects to | Integration Runtime |
|---|---|---|
| `LS_SQLServer_OnPrem` | `MigrationSourceDB` (on-prem SQL Server) | Self-Hosted IR (`SHIR-Local`) |
| `LS_AzureSQL` | `SalesDB` (Azure SQL Database) | Azure-managed / default (AutoResolveIntegrationRuntime) |

No credentials, connection strings, firewall IPs, or SHIR authentication keys are stored in this repository — they belong in Azure Key Vault / ADF's own connection configuration, not in source control.

## Self-Hosted Integration Runtime (SHIR-Local)

Installed on the machine hosting the on-prem SQL Server. It is the only path ADF has to reach `MigrationSourceDB` — Azure cannot connect to it directly. `LS_SQLServer_OnPrem` and any activity that queries the source (Lookups, CDC net-changes reads, the source side of Copy activities) all route through it.

## Datasets

**`DS_SQLServer_OnPrem`**
- Linked service: `LS_SQLServer_OnPrem`
- No fixed table — queries are supplied dynamically per activity (Lookup queries, CDC net-changes SELECTs, watermark-filtered copy queries).

**`DS_AzureSQL`**
- Linked service: `LS_AzureSQL`
- Parameters: `SchemaName` (String), `TableName` (String)
- Connection properties: `Schema = @dataset().SchemaName`, `Table = @dataset().TableName`
- One parameterized dataset is reused for `dbo.*`, `stg.*`, and `dbo.ETL_Control` targets across all three pipelines, driven by the `ForEach` item's schema/table.

## Retry Configuration

- Copy activity retry: **1**
- Retry interval: **30 seconds**
- This handles transient failures (network blips, momentary throttling) within a single run. It is **not** the mechanism that makes reruns safe — see `README.md` → "Retry and Recovery" for how checkpoint-based recovery and MERGE idempotency work together with this retry setting.
