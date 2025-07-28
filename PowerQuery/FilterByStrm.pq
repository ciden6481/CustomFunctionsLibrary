let
    FilterBySTRM = (InputTable as table, optional ColumnName as text) as table =>
        let
            col = if ColumnName = null then "STRM" else ColumnName,
            ValidSTRM = {
                "2263",
                "2262",
                "2254",
                "2253",
                "2252",
                "2244",
                "2243",
                "2242",
                "2234",
                "2233",
                "2232",
                "2224",
                "2223",
                "2222",
                "2214",
                "2213",
                "2212",
                "2204",
                "2203",
                "2202",
                "2194",
                "2193",
                "2192",
                "2184",
                "2183",
                "2182",
                "2174"
            },
            //HasCol = List.Contains(Table.ColumnNames(InputTable), col),
            HasExtract = List.Contains(Table.ColumnNames(InputTable), "VX_IR_EXTRACT_TYPE"),
            FilteredTable =
            //if HasCol then
            if HasExtract then
                Table.SelectRows(
                    InputTable,
                    each
                        Record.Field(_, col) <> null
                        and List.Contains(ValidSTRM, Record.Field(_, col))
                        and [VX_IR_EXTRACT_TYPE] = "F2"
                )
            else
                Table.SelectRows(
                    InputTable, each Record.Field(_, col) <> null and List.Contains(ValidSTRM, Record.Field(_, col))
                )
            //else
            //    InputTable
        in
            FilteredTable
in
    FilterBySTRM
