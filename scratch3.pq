let
    Source = (filename as text) as any =>
        let
            Source = Pdf.Tables(PASFiles{[Name=filename]}[Content], [Implementation="1.3"]),
            Pages = Table.SelectRows(Source, each [Kind] = "Page"),
            CombinedTables = Table.Combine(Pages[Data]),
            RemoveEmpties = (inputTable as table) as table =>
                let
                    RowCount = Table.RowCount(inputTable),
            ColumnNames = Table.ColumnNames(inputTable),
            NullCounts = List.Transform(
                ColumnNames, 
                each {_, List.Count(List.Select(Table.Column(inputTable, _), each _ = null))}
            ),
            ColumnsToKeep = List.Transform(
                List.Select(NullCounts, each _{1} <= RowCount / 2), 
                each _{0}
            ),
            CleanedTable = Table.SelectColumns(inputTable, ColumnsToKeep)
        in
            CleanedTable,

            RemoveBadRows = RemoveEmpties(Source),
            #"Replaced Value" = Table.ReplaceValue(
                RemoveBadRows,
                null,
                each if [Column2] = "De Arment-Don, DC FT" or [Column2] = "Van Dyke Simm, TA PT" then [Column2] else "b",
                Replacer.ReplaceValue,
                {"Column1"}
            ),
            #"Filtered Rows" = Table.SelectRows(
                #"Replaced Value", each ([Column1] <> "b" and [Column1] <> "OCTOBER 15, 2025")
            ),
            #"Replaced Value1" = Table.ReplaceValue(
                #"Filtered Rows", "Van Dyke Simm, TA PT", "PT", Replacer.ReplaceText, {"Column2"}
            ),
            #"Replaced Value2" = Table.ReplaceValue(
                #"Replaced Value1", "De Arment-Don, DC FT", "FT", Replacer.ReplaceText, {"Column2"}
            ),
            #"Renamed Columns" = Table.RenameColumns(
                #"Replaced Value2",
                {
                    {"Column1", "Name"},
                    {"Column2", "FT/PT"},
                    {"Column3", "DistRatio(CR/HR)"},
                    {"Column4", "DistRatio(ST/HR)"},
                    {"Column5", "CrsCredHrLd(CR/HR)"},
                    {"Column6", "CrsCredHrLd(FTEF)"},
                    {"Column9", "StudHrsGen(ST/HR)"},
                    {"Column10", "StudHrsGen(FTEF)"},
                    {"Column13", "Preparations"},
                    {"Column15", "ContactHrs"}
                }
            ),
            #"Changed Type" = Table.TransformColumnTypes(
                #"Renamed Columns",
                {
                    {"ContactHrs", type number},
                    {"Preparations", type number},
                    {"StudHrsGen(FTEF)", type number},
                    {"StudHrsGen(ST/HR)", type number},
                    {"CrsCredHrLd(FTEF)", type number},
                    {"CrsCredHrLd(CR/HR)", type number},
                    {"DistRatio(ST/HR)", type number},
                    {"DistRatio(CR/HR)", type number}
                }
            )
        in
            #"Changed Type"
in
    Source
