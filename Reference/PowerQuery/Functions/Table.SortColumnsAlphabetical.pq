// Sorts a table's columns alphabetically while preserving all row values.
let
    output =
    (
        inputTable as table,
        optional sortOrder as nullable number
    )
    as table =>
        let
            normalizedSortOrder = if sortOrder = Order.Descending then Order.Descending else Order.Ascending,
            sortedColumnNames = List.Sort(Table.ColumnNames(inputTable), normalizedSortOrder),
            result = Table.ReorderColumns(inputTable, sortedColumnNames)
        in
            result,
    documentation = [
        Documentation.Name = "Table.SortColumnsAlphabetical",
        Documentation.Description = "Returns a table with the same rows and values, but with columns reordered alphabetically.",
        Documentation.Source = "CustomFunctionsLibrary",
        Documentation.Version = "1.0.0",
        Documentation.Author = "GitHub Copilot",
        Documentation.Examples = {
            [
                Description = "Sort columns ascending (A to Z).",
                Code = "Table.SortColumnsAlphabetical(#table({""B"",""A""}, {{1,2}}))",
                Result = "#table({""A"",""B""}, {{2,1}})"
            ],
            [
                Description = "Sort columns descending (Z to A).",
                Code = "Table.SortColumnsAlphabetical(#table({""B"",""A""}, {{1,2}}), Order.Descending)",
                Result = "#table({""B"",""A""}, {{1,2}})"
            ]
        }
    ]
in
    Value.ReplaceType(
        output,
        Value.ReplaceMetadata(
            Value.Type(output),
            documentation
        )
    )
