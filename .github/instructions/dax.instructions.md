---
description: 'DAX formatting, authoring, and naming standards'
applyTo: '**/*.{dax,tmdl,bim}'
---

## DAX Standards

Use business-friendly measure names in Title Case with spaces.

Do not repeat the table name in a measure name unless needed for disambiguation.

Use these suffixes for time-intelligence variants:

- YTD
- QTD
- MTD
- YoY
- YoY %
- Rolling 12M

Use prefix m for measures only when the model uses it consistently everywhere.

Use camelCase for DAX variables.

Use meaningful variable names.

Do not use single-letter variable names.

Do not use a var prefix for variables.

Write one measure per definition block.

Use 4-space indentation.

Place RETURN on its own line.

Fully qualify every column reference as Table[Column].

Never qualify a measure reference with a table name.

Put all VAR declarations before RETURN.

Prefer measures over calculated columns for aggregations.

Avoid implicit measures.

Use DIVIDE() when a denominator can be zero.

Prefer boolean filters in CALCULATE over FILTER() table expressions.

Use FILTER() only for measure filters, cross-column logic, or OR logic.

Use KEEPFILTERS when a new filter must intersect existing filter context.

Use SWITCH(TRUE()) instead of deeply nested IF chains when it improves readability.

Do not convert BLANK to zero unless display logic explicitly requires it.

Use COALESCE for null handling when needed.

Use COUNTROWS(Table) for row counts.

Use SELECTEDVALUE(Table[Column]) when one scalar value is expected.

Keep time-intelligence logic centralized and reusable.

Use CROSSFILTER in a measure when ad-hoc cross-filtering is required.

Do not rely on permanent bi-directional relationships as a DAX workaround.

Populate measure descriptions for all published measures.

Assign a display folder to all published measures.

For complex measures, include business definition, grain, filter assumptions, and caveats in the description.

Use this standard layout template:

```dax
Measure Name =
VAR firstVariable = ...
VAR secondVariable = ...
RETURN
    ...
```

Use this division-safe pattern:

```dax
Net Sales YoY % =
VAR currentSales = [Net Sales]
VAR priorYearSales = [Net Sales PY]
RETURN
    DIVIDE(currentSales - priorYearSales, priorYearSales)
```
