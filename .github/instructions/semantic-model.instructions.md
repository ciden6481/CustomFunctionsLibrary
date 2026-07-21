---
description: 'Semantic model design, relationships, and metadata standards'
applyTo: '**/*.{tmdl,bim}'
---

## Semantic Model Standards

Use star schema by default with one fact table surrounded by denormalized dimensions.

Use PascalCase table names.

Use singular dimension names such as DimCustomer, not DimCustomers.

Use integer surrogate keys for all relationship columns.

Avoid natural keys for relationships.

Expose these dimension columns:

- DimensionCode as integer surrogate key.
- Dimension as display label.

Name fact table foreign keys as DimensionCode so they exactly match the related dimension key column.

Default relationships to single-direction filter propagation from dimension to fact.

Use bi-directional relationships only in these cases:

- One-to-one relationships.
- The bridge-table leg of a many-to-many dimension pattern.

Use CROSSFILTER in DAX for measure-scoped cross-filter behavior instead of permanent bi-directional relationships.

Collapse snowflake chains into denormalized dimensions in Power Query.

Retain snowflake structures only when a dimension is very large or independently required for reporting.

Use a dedicated Date table.

Require all Date table conditions:

- Unique dates with no BLANK values.
- Contiguous dates with no gaps.
- Full calendar year coverage.
- Table formally marked as a Date table.

Disable Auto date/time when a dedicated Date table is used.

For role-playing dimensions, use one of these approaches:

- Keep one active relationship and use USERELATIONSHIP for alternate roles.
- Use cloned role-specific dimension tables when simultaneous role filtering is required.

Rename columns in role-specific tables to self-describing names such as ShipYear and ShipMonth.

Assign all published measures to display folders.

Use these top-level display folders:

- Core Metrics
- Time Intelligence
- Financial
- Operational
- Ratios
- Diagnostic

Set data category for geographic fields.

Set consistent format strings for currency, percentage, and decimal metrics.

Use locale-appropriate formatting consistently.

Set Summarize By to Don't summarize for non-additive columns such as rates, percentages, IDs, keys, and unit prices.

Hide additive raw columns when explicit measures exist.

Hide technical key columns from report view unless required.

Populate table descriptions for all model tables.

Populate column descriptions for business-critical fields.

Populate descriptions for all published measures, including metric definition, calculation summary, included or excluded data, grain, and filters.
