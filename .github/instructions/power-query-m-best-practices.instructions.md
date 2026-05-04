---
description: 'Power Query M syntax and best practices based on Microsoft guidance for writing correct, maintainable, and folding-friendly .pq and .m files.'
applyTo: '**/*.{pq,m}'
---

# Power Query M Best Practices

## Overview
Use these instructions when writing or editing Power Query M in `.pq` and `.m` files. Favor official Power Query syntax, explicit typing, folding-friendly transformations, and reusable functions that fit this repository's conventions.

## Core Syntax Rules

- Write queries with a valid `let ... in ...` structure.
- Treat M as case-sensitive. Do not change the casing of function names, step names, column names, or identifiers casually.
- Use one binding per step inside `let`, and make each step reference an earlier step or a local expression.
- Return the final step or expression in the `in` clause.
- Use quoted identifiers like `#"Renamed Columns"` only when the identifier contains spaces or special characters.
- Prefer simple authored step names such as `Source`, `FilteredRows`, `TypedColumns`, `MergedData`, or `Result`.
- Do not default to UI-style quoted step names such as `#"Filtered Rows"` or `#"Changed Type"` in hand-written code unless you are preserving existing generated code or matching an applied-steps workflow intentionally.

### String Literals and Escaping

- Use double quotes for text literals in M, for example `"Sales"`.
- Escape embedded double quotes by doubling them, not with backslashes.
- Do not use C-style escapes such as `\"` in M string literals.

### Preferred Escaping Pattern

```powerquery
let
    ExampleText = "Table.SortColumnsAlphabetical(#table({""B"",""A""}, {{1,2}}))"
in
    ExampleText
```

### Avoid Invalid Escaping

```powerquery
let
    ExampleText = "Table.SortColumnsAlphabetical(#table({\"B\",\"A\"}, {{1,2}}))"
in
    ExampleText
```

### Preferred Query Shape

```powerquery
let
    Source = Sql.Database(ServerName, DatabaseName),
    Customer = Source{[Schema = "dbo", Item = "Customer"]}[Data],
    FilteredRows = Table.SelectRows(Customer, each [IsActive] = true),
    SelectedColumns = Table.SelectColumns(FilteredRows, {"CustomerID", "CustomerName", "CreatedDate"}),
    TypedColumns = Table.TransformColumnTypes(SelectedColumns, {{"CreatedDate", type date}})
in
    TypedColumns
```

### Avoid Invalid or Brittle Structure

```powerquery
let
    Source = Sql.Database("server", "db")
    ChangedType = Table.TransformColumnTypes(Source, {{"CreatedDate", type date}})
in
    Source
```

- Do not omit commas between `let` bindings.
- Do not return an earlier step when the final transformed step should be returned.

## Typing and Schema

- Set correct data types explicitly before using type-specific logic.
- Prefer `Table.TransformColumnTypes` for column typing and use an explicit table type when building tables from scratch.
- Convert values to `date`, `datetime`, `number`, `text`, and other required types before calling functions that depend on those types.
- In this repository, watch for the common error of calling functions such as `Date.Year(...)` before converting the source column to `type date`.
- When locale matters, pass the locale argument explicitly to `Table.TransformColumnTypes`.

### Preferred Typing Pattern

```powerquery
let
    Source = Csv.Document(File.Contents(FilePath), [Delimiter = ",", Encoding = 65001]),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    TypedColumns = Table.TransformColumnTypes(
        PromotedHeaders,
        {{"OrderDate", type date}, {"Amount", Currency.Type}, {"CustomerID", type text}}
    )
in
    TypedColumns
```

### Avoid Type-Unsafe Logic

```powerquery
let
    Source = SomeTable,
    AddedYear = Table.AddColumn(Source, "OrderYear", each Date.Year([OrderDate]), Int64.Type)
in
    AddedYear
```

- Do not assume source columns already have the expected types unless the connector guarantees them and the schema is stable.

## Query Folding and Performance

- Prefer the best native connector for the source. For example, use SQL Server or Oracle connectors instead of generic ODBC/OLEDB when a native connector exists.
- Filter early whenever the connector supports folding.
- Remove unneeded columns early to reduce data volume.
- Perform expensive non-streaming operations such as sort, distinct, group, join expansions with large payloads, and buffering as late as practical.
- Preserve folding as long as possible for database-backed queries.
- Use query folding indicators and diagnostics when performance matters.
- Use `Value.NativeQuery` only when necessary, and preserve folding only when the connector supports it.
- Do not add `Table.Buffer` or `List.Buffer` by default. Use them only when there is a proven evaluation or performance reason.

### Preferred Folding-Friendly Pattern

```powerquery
let
    Source = Sql.Database(ServerName, DatabaseName),
    Sales = Source{[Schema = "dbo", Item = "Sales"]}[Data],
    FilteredRows = Table.SelectRows(Sales, each [OrderDate] >= StartDate and [OrderDate] < EndDate),
    SelectedColumns = Table.SelectColumns(FilteredRows, {"OrderDate", "CustomerID", "Amount"}),
    TypedColumns = Table.TransformColumnTypes(SelectedColumns, {{"OrderDate", type date}, {"Amount", type number}})
in
    TypedColumns
```

### Avoid Premature Local Work

```powerquery
let
    Source = Sql.Database(ServerName, DatabaseName),
    Sales = Source{[Schema = "dbo", Item = "Sales"]}[Data],
    Buffered = Table.Buffer(Sales),
    SortedRows = Table.Sort(Buffered, {{"OrderDate", Order.Descending}}),
    FilteredRows = Table.SelectRows(SortedRows, each [OrderDate] >= StartDate)
in
    FilteredRows
```

## Resilience and Future-Proofing

- Define the intended scope of the query: expected columns, key filters, row exclusions, and type assumptions.
- Prefer selecting required columns instead of relying on a changing full schema.
- Use `Table.UnpivotOtherColumns` when the kept columns are fixed and the changing columns are the ones to reshape.
- Use row-position operations such as removing bottom rows when the source has dynamic data rows but fixed footer rows.
- Handle missing fields intentionally with options such as `MissingField.Ignore` or `MissingField.UseNull` when schema drift is expected.
- Remove or isolate rows that produce data conversion errors when the business rule allows it.

## Functions, Parameters, and Reuse

- Prefer reusable functions when the same transformation logic is applied in multiple places.
- Give function parameters explicit types whenever practical.
- Give function outputs explicit types for table, list, record, scalar, or nullable results.
- In this repository, inject external dependencies as function parameters instead of using `#shared` lookups.
- Use parameters for environment-specific values such as server, database, schema, file paths, term filters, and dates.
- Treat connection names as environment-specific. Do not hardcode credentials.
- As a best practice for reusable or shared functions, attach metadata with `Value.ReplaceType` and documentation fields to improve discoverability and IntelliSense.
- For one-off scratch queries, simple local helpers do not need full documentation metadata unless they are being promoted into reusable library code.

### Preferred Function Pattern

```powerquery
let
    GetActiveStudents =
        (
            SourceTable as table,
            TermCode as text
        )
        as table =>
        let
            FilteredRows = Table.SelectRows(SourceTable, each [STRM] = TermCode and [EnrollmentStatus] = "A"),
            SelectedColumns = Table.SelectColumns(FilteredRows, {"EMPLID", "STRM", "EnrollmentStatus"})
        in
            SelectedColumns
in
    GetActiveStudents
```

## Step Naming and Readability

- Use descriptive step names that explain the transformation, not just the data source.
- Prefer short, simple step names over verbose UI-generated names.
- Prefer names such as `FilteredRows`, `SelectedColumns`, `ExpandedDetails`, `TypedColumns`, and `AddedFiscalYear`.
- Keep each step focused on one logical transformation when practical.
- Split long or multi-phase logic into referenced queries or helper functions when a single query becomes hard to read.
- Add brief comments only when the intent is not obvious from the code.

## Error Handling

- Use `try ... otherwise` only where data quality issues are expected and a fallback is truly required.
- Do not use broad `try ... otherwise null` patterns that hide structural or business-critical failures.
- Validate required columns before calling `Record.Field`, `Table.SelectColumns`, or expansion logic when the source shape may vary.
- Raise clear errors for missing required inputs or missing required columns.

### Preferred Error Pattern

```powerquery
let
    RequiredColumns = {"EMPLID", "STRM"},
    MissingColumns = List.Difference(RequiredColumns, Table.ColumnNames(SourceTable)),
    ValidatedTable =
        if List.IsEmpty(MissingColumns) then
            SourceTable
        else
            error Text.Format(
                "Missing required columns: #{0}",
                {Text.Combine(MissingColumns, ", ")}
            )
in
    ValidatedTable
```

## Official-Language Patterns to Prefer

- Use `Table.SelectRows` for row filtering.
- Use `Table.SelectColumns` or `Table.RemoveColumns` to define the working shape early.
- Use `Table.TransformColumnTypes` for explicit typing.
- Use `Table.TransformColumns` when transforming values with functions.
- Use `Table.AddColumn` with an explicit output type when adding derived columns.
- Use `Table.NestedJoin` and explicit expansion steps for joins.
- Use `Table.FromRecords`, `#table`, records, and lists with explicit types when constructing sample or helper data.

## Repository-Specific Conventions

- Prefer `.pq` for Power Query source files, while still applying these rules to `.m` files.
- Keep scratch work in `ScratchFiles/` when iterating on external queries, then refine it into reusable library or function code if it becomes stable.
- For SQL-based sources such as `Sql.Database("IAAS-INSTANTID\\CARDS", "DATA")`, treat server and database names as configurable inputs where possible.
- Preserve existing public function names and signatures unless the change explicitly requires a breaking update.

## Validation Checklist

- The query parses as valid M with a correct `let ... in ...` structure.
- Type conversions happen before type-specific functions.
- Early steps preserve folding for supported connectors.
- Hardcoded environment-specific values are parameterized when practical.
- Required columns and schema assumptions are explicit.
- The final `in` returns the intended result step.

## References

- Microsoft Learn: Power Query M language quick tour
- Microsoft Learn: Power Query M language specification
- Microsoft Learn: Best practices when working with Power Query
- Microsoft Learn: Overview of query evaluation and query folding in Power Query
- Microsoft Learn: Power Query M function reference