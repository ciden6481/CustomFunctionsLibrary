// @snippet.title: FilterValidSTRM
// @snippet.description: Snippet for FilterValidSTRM.
// @snippet.tags: auto-generated

let
    Source = (srcTbl as table, optional strmTbl as nullable table) =>
let
    EffectiveStrmTbl =
        if strmTbl <> null then
            strmTbl
        else
            try
                Record.Field(#shared, "stgSTRM")
            otherwise
                error "strmTbl was not provided and stgSTRM was not found.",
    STRMList = List.Buffer(EffectiveStrmTbl[STRM]),
    HasExtractType = List.Contains(Table.ColumnNames(srcTbl), "VX_IR_EXTRACT_TYPE"),
    Result =
        if HasExtractType then
            Table.RemoveColumns(
                Table.SelectRows(
                    srcTbl,
                    each List.Contains(STRMList, [STRM]) and [VX_IR_EXTRACT_TYPE] = "F2"
                ),
            {"VX_IR_EXTRACT_TYPE"}
            )
        else
            Table.SelectRows(
                srcTbl,
                each List.Contains(STRMList, [STRM])
            )
in
    Result
in
    Source