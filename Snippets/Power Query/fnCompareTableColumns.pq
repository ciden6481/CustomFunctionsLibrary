// @snippet.title: fnCompareTableColumns
// @snippet.description: Compare columns across multiple tables to determine which columns are shared and which are unique.
// @snippet.tags: auto-generated

(TableNames as list) as table =>
let
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),

    // Get column lists for all requested tables
    TableColumns =
        List.Transform(
            TableNames,
            each [
                TableName = _,
                Columns =
                    Table.ColumnNames(
                        Source{[Schema = "dbo", Item = _]}[Data]
                    )
            ]
        ),

    // Get all unique column names across all tables
    AllColumns =
        List.Sort(
            List.Distinct(
                List.Combine(
                    List.Transform(
                        TableColumns,
                        each [Columns]
                    )
                )
            )
        ),

    // Build one record per column
    Records =
        List.Transform(
            AllColumns,
            (CurrentColumn) =>
                let
                    Presence =
                        List.Transform(
                            TableColumns,
                            each
                                if List.Contains([Columns], CurrentColumn)
                                then "X"
                                else null
                        ),

                    CountPresent =
                        List.Count(
                            List.RemoveNulls(Presence)
                        )
                in
                    Record.Combine({
                        [
                            ColumnName = CurrentColumn,
                            TableCount = CountPresent
                        ],
                        Record.FromList(
                            Presence,
                            List.Transform(
                                TableColumns,
                                each [TableName]
                            )
                        )
                    })
        ),

    Result =
        Table.Sort(
            Table.FromRecords(Records),
            {
                {"TableCount", Order.Descending},
                {"ColumnName", Order.Ascending}
            }
        )
in
    Result