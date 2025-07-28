let
    fx_FilterBySTRM = (
        InputTable as table,
        optional ColumnName as nullable text,
        optional UseDynamicSTRM as nullable logical,
        optional RequireExtractF2 as nullable logical
    ) as table =>
        let
            // Handle optional parameters with defaults
            col = if ColumnName <> null then ColumnName else "STRM",
            useDynamic = if UseDynamicSTRM <> null then UseDynamicSTRM else true,
            requireF2 = if RequireExtractF2 <> null then RequireExtractF2 else true,
            // Fallback static STRM list
            StaticSTRMList = {
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
            // Try to get dynamic STRM list, fallback to static
            ValidSTRM = if useDynamic then try List.Buffer(DimSTRM[STRM]) otherwise StaticSTRMList else StaticSTRMList,
            // Check for the extract column
            HasExtract = List.Contains(Table.ColumnNames(InputTable), "VX_IR_EXTRACT_TYPE"),
            // Perform filtering
            FilteredTable =
                if requireF2 and HasExtract then
                    Table.SelectRows(
                        InputTable,
                        each
                            Record.Field(_, col) <> null
                            and List.Contains(ValidSTRM, Record.Field(_, col))
                            and [VX_IR_EXTRACT_TYPE] = "F2"
                    )
                else
                    Table.SelectRows(
                        InputTable,
                        each Record.Field(_, col) <> null and List.Contains(ValidSTRM, Record.Field(_, col))
                    )
        in
            FilteredTable
in
    fx_FilterBySTRM
