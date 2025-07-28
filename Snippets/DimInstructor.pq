let
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    dbo_IR_CLS_INSTR = Source{[Schema = "dbo", Item = "IR_CLS_INSTR"]}[Data],
    dbo_IR_FAC_INFO = Source{[Schema = "dbo", Item = "IR_FAC_INFO"]}[Data],
    // Get buffered list of valid STRM values
    ValidSTRM = fx_GetValidSTRMList(),
    //Apply STRM + ExtractType filter inline (preserves folding)
    FilteredTable = Table.SelectRows(
        dbo_IR_CLS_INSTR, each [STRM] <> null and List.Contains(ValidSTRM, [STRM]) and [VX_IR_EXTRACT_TYPE] = "F2"
    ),
    #"Removed Columns" = Table.RemoveColumns(
        FilteredTable, {"INSTITUTION", "ACAD_CAREER", "RUNDATE", "VX_IR_EXTRACT_TYPE"}
    ),
    #"Merged Queries" = Table.NestedJoin(
        #"Removed Columns", {"EMPLID"}, dbo_IR_FAC_INFO, {"EMPLID"}, "IR_FAC_INFO", JoinKind.LeftOuter
    ),
    #"Expanded IR_FAC_INFO" = Table.ExpandTableColumn(
        #"Merged Queries", "IR_FAC_INFO", {"LAST", "FIRST"}, {"LAST", "FIRST"}
    ),
    #"Added Custom" = Table.AddColumn(#"Expanded IR_FAC_INFO", "strm-class key", each [STRM] & "-" & [EMPLID]),
    #"Renamed Columns" = Table.RenameColumns(#"Added Custom", {{"LAST", "InstLast"}, {"FIRST", "InstFirst"}}),
    #"Changed Type" = Table.TransformColumnTypes(
        #"Renamed Columns", {{"CLASS_NBR", type text}, {"strm-class key", type text}}
    ),
    #"Filtered Rows1" = Table.SelectRows(#"Changed Type", each ([INSTR_ROLE] = "PI"))
in
    #"Filtered Rows1"
