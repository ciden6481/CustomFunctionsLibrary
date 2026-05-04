let
    Source = AllMatchTest,
    NonEMPLIDCols = List.RemoveItems(Table.ColumnNames(Source), {"EMPLID"}),
    // AnyTrue can short-circuit once a non-zero value is found in a column.
    NonMatchCols = List.Select(
        NonEMPLIDCols,
        (col) => List.AnyTrue(List.Transform(Table.Column(Source, col), each _ <> null and _ > 0))
    ),
    NonMatchTable = Table.SelectColumns(Source, {"EMPLID"} & NonMatchCols),
    #"Added Custom" = Table.AddColumn(
        NonMatchTable,
        "Total",
        each if List.IsEmpty(NonMatchCols) then 0 else List.Sum(List.RemoveNulls(Record.ToList(Record.SelectFields(_, NonMatchCols)))),
        type number
    ),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom", each [Total] > 0),
    #"Merged Queries" = Table.NestedJoin(#"Filtered Rows", {"EMPLID"}, sas, {"EMPLID"}, "sas", JoinKind.LeftOuter),
    #"Merged Queries1" = Table.NestedJoin(#"Merged Queries", {"EMPLID"}, sql, {"EMPLID"}, "sql", JoinKind.LeftOuter),
    Expandsql = Table.ExpandTableColumn(
        #"Merged Queries1", "sql", NonMatchCols, List.Transform(NonMatchCols, each Text.Insert(_, 0, "sql."))
    ),
    #"Expanded sas" = Table.ExpandTableColumn(
        Expandsql, "sas", NonMatchCols, List.Transform(NonMatchCols, each Text.Insert(_, 0, "sas."))
    ),
    #"Reordered Columns" = Table.ReorderColumns(
        #"Expanded sas",
        {
            "EMPLID",
            "ACADPLAN",
            "sas.ACADPLAN",
            "sql.ACADPLAN",
            "FICE",
            "sas.FICE",
            "sql.FICE",
            "FICE_EXTORG_DESC",
            "sas.FICE_EXTORG_DESC",
            "sql.FICE_EXTORG_DESC",
            "FNAME",
            "sas.FNAME",
            "sql.FNAME",
            "LNAME",
            "sas.LNAME",
            "sql.LNAME",
            "LPCC",
            "sas.LPCC",
            "sql.LPCC",
            "MNAME",
            "sas.MNAME",
            "sql.MNAME",
            "PELLELIG",
            "sas.PELLELIG",
            "sql.PELLELIG",
            "Total"
        }
    )
in
    #"Reordered Columns"
