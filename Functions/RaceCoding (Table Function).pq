// Recode VX_IR_ETHNIC_* flags into a single `Race` column.
// Usage: RecodeRace(InputTable as table, optional ColumnName as text, optional RaceCol1Name as text, optional RaceCol2Name as text, optional RaceCol3Name as text, optional RaceCol4Name as text, optional RaceCol5Name as text, optional RaceCol6Name as text, optional RaceCol7Name as text) as table
let
    RecodeRace = (
        InputTable as table,
        optional ColumnName as nullable text,
        optional RaceCol1Name as nullable text,
        optional RaceCol2Name as nullable text,
        optional RaceCol3Name as nullable text,
        optional RaceCol4Name as nullable text,
        optional RaceCol5Name as nullable text,
        optional RaceCol6Name as nullable text,
        optional RaceCol7Name as nullable text
    ) as table =>
        let
            // output column name (default: "Race")
            outCol = if ColumnName = null then "Race" else ColumnName,
            // resolve column names (fallback to defaults when not provided)
            r_col1 = if RaceCol1Name = null then "VX_IR_ETHNIC_1" else RaceCol1Name,
            r_col2 = if RaceCol2Name = null then "VX_IR_ETHNIC_2" else RaceCol2Name,
            r_col3 = if RaceCol3Name = null then "VX_IR_ETHNIC_3" else RaceCol3Name,
            r_col4 = if RaceCol4Name = null then "VX_IR_ETHNIC_4" else RaceCol4Name,
            r_col5 = if RaceCol5Name = null then "VX_IR_ETHNIC_5" else RaceCol5Name,
            r_col6 = if RaceCol6Name = null then "VX_IR_ETHNIC_6" else RaceCol6Name,
            r_col7 = if RaceCol7Name = null then "VX_IR_ETHNIC_7" else RaceCol7Name,
            // normalize various "yes" values to 1, else 0
            IsYes = (v) =>
                let
                    s = if v = null then "" else Text.Upper(Text.Trim(Text.From(v)))
                in
                    if List.Contains({"Y", "1", "TRUE", "YES", "T"}, s) then
                        1
                    else
                        0,
            // add numeric flag columns (0/1) for each VX_IR_ETHNIC_* field
            Add_f1 = Table.AddColumn(
                InputTable, "_f1", each IsYes(try Record.Field(_, r_col1) otherwise null), type number
            ),
            Add_f2 = Table.AddColumn(
                Add_f1, "_f2", each IsYes(try Record.Field(_, r_col2) otherwise null), type number
            ),
            Add_f3 = Table.AddColumn(
                Add_f2, "_f3", each IsYes(try Record.Field(_, r_col3) otherwise null), type number
            ),
            Add_f4 = Table.AddColumn(
                Add_f3, "_f4", each IsYes(try Record.Field(_, r_col4) otherwise null), type number
            ),
            Add_f5 = Table.AddColumn(
                Add_f4, "_f5", each IsYes(try Record.Field(_, r_col5) otherwise null), type number
            ),
            Add_f6 = Table.AddColumn(
                Add_f5, "_f6", each IsYes(try Record.Field(_, r_col6) otherwise null), type number
            ),
            Add_f7 = Table.AddColumn(
                Add_f6, "_f7", each IsYes(try Record.Field(_, r_col7) otherwise null), type number
            ),
            // multi-race count: per spec, count only 1,2,4,5,7 (exclude 3 and 6)
            Add_sumMulti = Table.AddColumn(
                Add_f7, "_sumMulti", each List.Sum({[_f1], [_f2], [_f4], [_f5], [_f7]}), type number
            ),
            // any presence among 1,2,4,5,6,7 (used to detect no Y)
            Add_any = Table.AddColumn(
                Add_sumMulti, "_any", each List.Sum({[_f1], [_f2], [_f4], [_f5], [_f6], [_f7]}), type number
            ),
            // final Race column logic
            // - Hispanic (VX_IR_ETHNIC_3) prioritized
            // - If more than one flag present among 1,2,4,5,7 -> "Two or More Races"
            // - If no flags present among 1,2,4,5,6,7 -> "Unknown"
            // - If only one flag present -> that race (VX_IR_ETHNIC_6 -> "Not Specified", VX_IR_ETHNIC_7 -> Hawaiian)
            Add_Race = Table.AddColumn(
                Add_any,
                outCol,
                each
                    if [_f3] = 1 then
                        "Hispanic"
                    else if [_sumMulti] > 1 then
                        "Two or More Races"
                    else if [_any] < 1 then
                        "Unknown"
                    else if [_f1] = 1 then
                        "White"
                    else if [_f2] = 1 then
                        "Black/African American"
                    else if [_f4] = 1 then
                        "Asian"
                    else if [_f5] = 1 then
                        "American Indian/Alaskan Native"
                    else if [_f6] = 1 then
                        // Not Specified preserved separately
                        "Not Specified"
                    else if [_f7] = 1 then
                        "Native Hawaiian/Pacific Islander"
                    else
                        "Unknown",
                type text
            ),
            // remove temporary helper columns
            RemoveTemps = Table.RemoveColumns(Add_Race, {"_f1", "_f2", "_f3", "_f4", "_f5", "_f6", "_f7", "_sumMulti", "_any"})
        in
            RemoveTemps
in
    RecodeRace
