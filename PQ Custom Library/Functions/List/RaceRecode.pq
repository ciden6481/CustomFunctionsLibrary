let
    // Step 1: Parameter documentation metadata
    metaDocumentation = type function (
        InputTable as (type table meta [
            Documentation.FieldCaption = "Input Table",
            Documentation.FieldDescription = "The table that contains race and ethnicity indicator columns.",
            Documentation.SampleValues = {"Table with VX_IR_ETHNIC_* fields"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colWhite as (type text meta [
            Documentation.FieldCaption = "White Column",
            Documentation.FieldDescription = "Column name that stores the White indicator, such as VX_IR_ETHNIC_1.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_1"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colBlack as (type text meta [
            Documentation.FieldCaption = "Black Column",
            Documentation.FieldDescription = "Column name that stores the Black or African American indicator, such as VX_IR_ETHNIC_2.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_2"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colHisp as (type text meta [
            Documentation.FieldCaption = "Hispanic Column",
            Documentation.FieldDescription = "Column name that stores the Hispanic indicator, such as VX_IR_ETHNIC_3.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_3"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colAsian as (type text meta [
            Documentation.FieldCaption = "Asian Column",
            Documentation.FieldDescription = "Column name that stores the Asian indicator, such as VX_IR_ETHNIC_4.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_4"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colAmInAlk as (type text meta [
            Documentation.FieldCaption = "American Indian/Alaskan Native Column",
            Documentation.FieldDescription = "Column name that stores the American Indian or Alaskan Native indicator, such as VX_IR_ETHNIC_5.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_5"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colNspec as (type text meta [
            Documentation.FieldCaption = "Not Specified Column",
            Documentation.FieldDescription = "Column name that stores the Not Specified indicator, such as VX_IR_ETHNIC_6.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_6"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        colHawPac as (type text meta [
            Documentation.FieldCaption = "Native Hawaiian/Pacific Islander Column",
            Documentation.FieldDescription = "Column name that stores the Native Hawaiian or Pacific Islander indicator, such as VX_IR_ETHNIC_7.",
            Documentation.SampleValues = {"VX_IR_ETHNIC_7"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as table
    // Step 2: Function-level documentation
    meta [
        Documentation.Name = "List.RaceRecode",
        Documentation.Author = "CustomFunctionsLibrary",
        Documentation.LongDescription = "
            <p><b>List.RaceRecode</b></p>
            <li>Determines race and ethnicity from indicator columns and adds a new <code>Race</code> column.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>InputTable</b>: Source table with race and ethnicity indicator columns.</li>
                <li><b>colWhite</b>: White indicator column name.</li>
                <li><b>colBlack</b>: Black/African American indicator column name.</li>
                <li><b>colHisp</b>: Hispanic indicator column name.</li>
                <li><b>colAsian</b>: Asian indicator column name.</li>
                <li><b>colAmInAlk</b>: American Indian/Alaskan Native indicator column name.</li>
                <li><b>colNspec</b>: Not Specified indicator column name.</li>
                <li><b>colHawPac</b>: Native Hawaiian/Pacific Islander indicator column name.</li>
            </ul>
            <b>Returns:</b> Table with all original columns plus a new <code>Race</code> text column.
        ",
        Documentation.Examples = {
            [
                Description = "Add a Race column using standard VX_IR_ETHNIC indicator fields.",
                Code = "List.RaceRecode(SourceTable, \"VX_IR_ETHNIC_1\", \"VX_IR_ETHNIC_2\", \"VX_IR_ETHNIC_3\", \"VX_IR_ETHNIC_4\", \"VX_IR_ETHNIC_5\", \"VX_IR_ETHNIC_6\", \"VX_IR_ETHNIC_7\")",
                Result = """Returns SourceTable with a new Race column."""
            ]
        }
    ],

    // Step 3: Function implementation
    RaceRecode = (
        InputTable as table,
        colWhite as text,
        colBlack as text,
        colHisp as text,
        colAsian as text,
        colAmInAlk as text,
        colNspec as text,
        colHawPac as text
    ) as table =>
        let
            requiredColumns = {colWhite, colBlack, colHisp, colAsian, colAmInAlk, colNspec, colHawPac},
            missingColumns = List.Difference(requiredColumns, Table.ColumnNames(InputTable)),
            validatedTable =
                if List.IsEmpty(missingColumns) then
                    InputTable
                else
                    error Text.Format(
                        "Missing required columns in InputTable: #{0}",
                        {Text.Combine(missingColumns, ", ")}
                    ),
            isYes = (value as any) as logical =>
                if value = null then
                    false
                else
                    Text.Upper(Text.From(value)) = "Y",
            isNo = (value as any) as logical =>
                if value = null then
                    false
                else
                    Text.Upper(Text.From(value)) = "N",
            addedRace = Table.AddColumn(
                validatedTable,
                "Race",
                each
                    let
                        whiteYes = isYes(Record.FieldOrDefault(_, colWhite, null)),
                        blackYes = isYes(Record.FieldOrDefault(_, colBlack, null)),
                        hispYes = isYes(Record.FieldOrDefault(_, colHisp, null)),
                        asianYes = isYes(Record.FieldOrDefault(_, colAsian, null)),
                        amInAlkYes = isYes(Record.FieldOrDefault(_, colAmInAlk, null)),
                        nspecYes = isYes(Record.FieldOrDefault(_, colNspec, null)),
                        hawPacYes = isYes(Record.FieldOrDefault(_, colHawPac, null)),

                        whiteNo = isNo(Record.FieldOrDefault(_, colWhite, null)),
                        blackNo = isNo(Record.FieldOrDefault(_, colBlack, null)),
                        hispNo = isNo(Record.FieldOrDefault(_, colHisp, null)),
                        asianNo = isNo(Record.FieldOrDefault(_, colAsian, null)),
                        amInAlkNo = isNo(Record.FieldOrDefault(_, colAmInAlk, null)),
                        hawPacNo = isNo(Record.FieldOrDefault(_, colHawPac, null)),

                        markedCount = List.Sum(List.Transform({whiteYes, blackYes, asianYes, amInAlkYes, nspecYes, hawPacYes}, each if _ then 1 else 0)),
                        noRaceSelected = whiteNo and blackNo and hispNo and asianNo and amInAlkNo and hawPacNo
                    in
                        if hispYes then
                            "Hispanic"
                        else if noRaceSelected then
                            "Unknown"
                        else if nspecYes then
                            "Not Specified"
                        else if markedCount >= 2 then
                            "Two or more"
                        else if whiteYes then
                            "White"
                        else if blackYes then
                            "Black/African American"
                        else if asianYes then
                            "Asian"
                        else if amInAlkYes then
                            "American Indian/Alaskan Native"
                        else if hawPacYes then
                            "Native Hawaiian/Pacific Islander"
                        else
                            "Unknown",
                type text
            )
        in
            addedRace
in
    Value.ReplaceType(RaceRecode, metaDocumentation)
