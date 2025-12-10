<!-- Source: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-date-tables -->
# Set and use date tables in Power BI Desktop (summary)

Power BI can auto-generate hidden date tables, but for reliable time intelligence you may want to create and `Mark as date table` a dedicated date table.

When you set a date table, Power BI validates that the date column:
- Contains unique values
- Contains no nulls
- Contains contiguous date values

You must `Mark as date table` when using classic time intelligence functions or when relationships use surrogate key date columns.

Full doc: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-date-tables
