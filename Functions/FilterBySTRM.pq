// FilterBySTRM
let
    FilterBySTRM = (InputTable as table, optional ColumnName as text) as table =>
    let
        col = if ColumnName = null then "STRM" else ColumnName,
        ValidSTRM = {
            "2104","2112","2113","2114","2122","2123","2124",
            "2132","2133","2134","2142","2143","2144",
            "2152","2153","2154","2162","2163","2164",
            "2172","2173"
        },
        FilteredTable = Table.SelectRows(InputTable, each 
            Record.Field(_, col) <> null and
            List.Contains(ValidSTRM, Record.Field(_, col)) and
            [VX_IR_EXTRACT_TYPE] = "F2"
        )
    in
        FilteredTable
in
    FilterBySTRM