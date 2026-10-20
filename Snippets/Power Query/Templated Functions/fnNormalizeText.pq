// @snippet.title: fnNormalizeText
// @snippet.description: Snippet for fnNormalizeText.
// @snippet.tags: auto-generated

let
    metaDocumentation =
        type function (
            tbl as (type table meta [
                Documentation.FieldCaption = "Input table",
                Documentation.FieldDescription = "Table to transform.",
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]),
            optional Columns as (type nullable list meta [
                Documentation.FieldCaption = "Columns (optional)",
                Documentation.FieldDescription = "List of column names to normalize. If omitted, text columns are auto-detected.",
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]),
            optional BlankToNull as (type nullable logical meta [
                Documentation.FieldCaption = "BlankToNull (optional)",
                Documentation.FieldDescription = "True (default) converts blank strings to null. False preserves blanks.",
                Documentation.SampleValues = {true, false},
                Documentation.AllowedValues = {true, false},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]),
            optional IncludeAnyColumns as (type nullable logical meta [
                Documentation.FieldCaption = "IncludeAnyColumns (optional)",
                Documentation.FieldDescription = "True (default) includes Any columns when auto-detecting target columns. False includes only Text columns.",
                Documentation.SampleValues = {true, false},
                Documentation.AllowedValues = {true, false},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ])
        ) as table
        meta [
            Documentation.Name = "Table.NormalizeText",
            Documentation.Author = "CustomFunctionsLibrary"
        ],

    fxNormalizeText = (
        tbl as table,
        optional Columns as nullable list,
        optional BlankToNull as nullable logical,
        optional IncludeAnyColumns as nullable logical
    ) as table =>
        let
            OriginalType = Value.Type(tbl),

            ConvertBlanksToNull = BlankToNull ?? true,
            IncludeAny = IncludeAnyColumns ?? true,

            NormalizeValue = (v as any) as any =>
                if v = null then
                    null
                else if Value.Is(v, type text) then
                    let
                        CleanedText =
                            Text.Replace(
                                Text.Replace(
                                    Text.Clean(v),
                                    Character.FromNumber(160),
                                    " "
                                ),
                                Character.FromNumber(9),
                                " "
                            ),

                        NormalizedText =
                            Text.Combine(
                                List.Select(
                                    Text.Split(
                                        Text.Trim(CleanedText),
                                        " "
                                    ),
                                    each _ <> ""
                                ),
                                " "
                            )
                    in
                        if ConvertBlanksToNull and NormalizedText = ""
                        then null
                        else NormalizedText
                else
                    v,

            TargetColumns =
                if Columns <> null then
                    Columns
                else
                    let
                        SchemaTable = Table.Schema(tbl),
                        FilteredSchema =
                            Table.SelectRows(
                                SchemaTable,
                                each [Kind] = "text"
                                    or (IncludeAny and [Kind] = "any")
                            )
                    in
                        FilteredSchema[Name],

            Transformed =
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
                Value.ReplaceType(
                    Transformed,
                    OriginalType
                )
        in
            Result
in
    Value.ReplaceType(
        fxNormalizeText,
        metaDocumentation
    )