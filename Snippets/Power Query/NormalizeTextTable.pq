// @snippet.title: NormalizeTextTable
// @snippet.description: Snippet for NormalizeTextTable.
// @snippet.tags: auto-generated

let
    NormalizeTextTable =
        (
            tbl as table,
            optional Columns as nullable list,
            optional BlankToNull as nullable logical,
            optional IncludeAnyColumns as nullable logical
        ) as table =>

        let
            ConvertBlanksToNull = BlankToNull ?? true,
            IncludeAny = IncludeAnyColumns ?? true,

            NormalizeValue =
                (v as any) as any =>
                    if v = null then
                        null
                    else if Value.Is(v, type text) then
                        let
                            Cleaned =
                                Text.Replace(
                                    Text.Replace(
                                        Text.Clean(v),
                                        Character.FromNumber(160),
                                        " "
                                    ),
                                    Character.FromNumber(9),
                                    " "
                                )
                        in
                            Text.Combine(
                                List.Select(
                                    Text.Split(
                                        Text.Trim(Cleaned),
                                        " "
                                    ),
                                    each _ <> ""
                                ),
                                " "
                            )
                    else
                        v,

            TargetColumns =
                if Columns <> null then
                    Columns
                else
                    let
                        Schema = Table.Schema(tbl)
                    in
                        Table.SelectRows(
                            Schema,
                            each
                                [Kind] = "text"
                                or (IncludeAny and [Kind] = "any")
                        )[Name],

           NormalizedTable =
                if List.Count(TargetColumns) = 0 then
                    tbl
                else
                    Table.TransformColumns(
                        tbl,
                        List.Transform(
                            TargetColumns,
                            each {_, NormalizeValue}
                        )
                    ),

            Result =
                if ConvertBlanksToNull and List.Count(TargetColumns) > 0 then
                    Table.ReplaceValue(
                        NormalizedTable,
                        "",
                        null,
                        Replacer.ReplaceValue,
                        TargetColumns
                    )
                else
                    NormalizedTable
        in
            Result 
in
    NormalizeTextTable