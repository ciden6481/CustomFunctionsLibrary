---
description: 'Power Query query layering, step naming, and M code style standards'
applyTo: '**/*.{m,pq,tmdl}'
---

## Power Query Standards

Use PascalCase for all query names.

Use these query layer naming patterns:

| Query Type | Pattern | Example |
|---|---|---|
| Source query | SrcEntityName | SrcSales |
| Staging query | StgEntityName | StgSales |
| Final load query | DimEntityName or FactEntityName | DimCustomer, FactSales |
| Reference helper | RefPurpose | RefFiscalCalendar |
| Function | fxFunctionName | fxNormalizeDate |
| Parameter | pParameterName | pStartDate |

Do not keep default names such as Query1.

Prefer simple authored step names over verbose UI-generated quoted names.

Use concise action-oriented step names in PascalCase.

Avoid quoted step names with spaces when practical.

Use these step naming preferences:

| Prefer | Avoid |
|---|---|
| FilterActiveRows | #"Filtered Rows" |
| KeepNeededColumns | #"Removed Other Columns" |
| AddFiscalYear | #"Added Custom" |
| ChangeTypes | #"Changed Column Type" |
| Source | Single-word Source is acceptable |

Keep one transformation intent per step.

Avoid deeply chained one-liners when multiple steps improve readability.

Rename columns early to align with model naming standards.

Apply type changes explicitly.

Do not rely on inferred types.

Push filters and column pruning as early as possible.

Prefix reusable functions with fx.

Include parameter type annotations where practical.

Use Value.ReplaceType metadata for reusable or shared functions.

Treat function metadata as optional for scratch or one-off queries.

Disable load for Stg and Ref queries unless intentionally exposed.

Load only final Dim and Fact business entities where possible.

Avoid circular dependencies and unnecessary query reference chains.

Use this standard template:

```m
let
    Source = Sql.Database("server", "database"),
    RawEntity = Source{[Schema="dbo", Item="Entity"]}[Data],
    KeepNeededColumns = Table.SelectColumns(RawEntity, {"Id", "Code", "Name"}),
    FilterActiveRows = Table.SelectRows(KeepNeededColumns, each [IsActive] = true),
    ChangeTypes = Table.TransformColumnTypes(FilterActiveRows, {
        {"Id", Int64.Type},
        {"Code", Int64.Type},
        {"Name", type text}
    })
in
    ChangeTypes
```
