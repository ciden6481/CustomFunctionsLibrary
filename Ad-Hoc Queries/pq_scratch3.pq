let
    Source = AllMatchTest,
    NonEMPLIDCols = List.Buffer(List.RemoveItems(Table.ColumnNames(Source), {"EMPLID"})),
    NonMatchCols = List.Buffer(
        List.Select(NonEMPLIDCols, (col) => List.AnyTrue(List.Transform(Table.Column(Source, col), each _ > 0)))
    ),
    NonMatchTable = Table.SelectColumns(Source, {"EMPLID"} & NonMatchCols, MissingField.Ignore),
    AddedTotal = Table.AddColumn(
        NonMatchTable,
        "Total",
        each
            if List.IsEmpty(NonMatchCols) then
                0
            else
                List.Sum(Record.ToList(Record.SelectFields(_, NonMatchCols, MissingField.UseNull))),
        Int64.Type
    ),
    FilteredRows = Table.SelectRows(AddedTotal, each [Total] > 0),
    SasSlim = Table.SelectColumns(sas, {"EMPLID"} & NonMatchCols, MissingField.UseNull),
    SqlSlim = Table.SelectColumns(sql, {"EMPLID"} & NonMatchCols, MissingField.UseNull),
    MergedSas = Table.NestedJoin(FilteredRows, {"EMPLID"}, SasSlim, {"EMPLID"}, "sas", JoinKind.LeftOuter),
    MergedSql = Table.NestedJoin(MergedSas, {"EMPLID"}, SqlSlim, {"EMPLID"}, "sql", JoinKind.LeftOuter),
    SqlOutNames = List.Transform(NonMatchCols, each "sql." & _),
    SasOutNames = List.Transform(NonMatchCols, each "sas." & _),
    ExpandedSql = Table.ExpandTableColumn(MergedSql, "sql", NonMatchCols, SqlOutNames),
    ExpandedSas = Table.ExpandTableColumn(ExpandedSql, "sas", NonMatchCols, SasOutNames),
    ReorderedColumns = Table.ReorderColumns(
        ExpandedSas,
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
        },
        MissingField.Ignore
    )
in
    ReorderedColumns
