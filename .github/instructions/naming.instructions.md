---
description: 'Cross-layer naming and prefix standards for Power BI artifacts'
applyTo: '**'
---

## Naming Standards

Use these case styles for each object type:

| Object Type | Required Case Style |
|---|---|
| Workspaces | Title Case |
| Reports | Title Case |
| Semantic Models | Title Case |
| Tables | PascalCase with no spaces |
| Columns | PascalCase with no spaces |
| Measures | Title Case with spaces |
| DAX variables | camelCase |
| Power Query queries | PascalCase |
| Power Query steps | PascalCase or concise action names with no spaces |
| Parameters | PascalCase with prefix p |

Use letters and numbers only where possible.

Avoid special characters except underscore when needed for approved technical prefixes.

Do not use leading or trailing spaces.

Avoid abbreviations unless they are organization-approved.

Use prefixes only when they add clear semantic value.

If a prefix is adopted in a model, apply it consistently in that model.

Use these approved prefixes:

| Prefix | Applies To |
|---|---|
| m (optional) | DAX measures |
| c | Calculated columns |
| t | Calculated tables |
| p | Parameters |
| Is or Has | Boolean columns |
| fx | Power Query functions |

Use these key and display naming patterns for dimensions:

- Use DimensionCode for the relationship key column and keep it as an integer number.
- Use Dimension for the display label column.

Use purpose-based names for report interaction artifacts:

- Name visuals as visPurposeName.
- Name bookmarks as bmPurposeName.

Use these examples as guidance:

| Good | Avoid |
|---|---|
| SalesOrder | sales_order |
| OrderDate | order date |
| Net Sales | NET_SALES |
| priorYearSales | varPriorYear |
| StagedSales | Query1 |
| FilterActiveRows | #"Filtered Rows" |
| pStartDate | StartDate |
| visSalesTrendByMonth | Chart 1 |
| bmOpenDetailsPanel | Bookmark1 |
