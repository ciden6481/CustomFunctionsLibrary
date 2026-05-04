let
    // Step 1: Parameter documentation metadata
    metaDocumentation = type function (
        colHispFlag as (
            type text meta [
                Documentation.FieldCaption = "Hispanic flag Column",
                Documentation.FieldDescription = "Column name that stores the Hispanic flag, such as VX_IR_ETHNIC_HISP.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_HISP"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colWhite as (
            type text meta [
                Documentation.FieldCaption = "White Column",
                Documentation.FieldDescription = "Column name that stores the White indicator, such as VX_IR_ETHNIC_1.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_1"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colBlack as (
            type text meta [
                Documentation.FieldCaption = "Black Column",
                Documentation.FieldDescription = "Column name that stores the Black or African American indicator, such as VX_IR_ETHNIC_2.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_2"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colHisp as (
            type text meta [
                Documentation.FieldCaption = "Hispanic Column",
                Documentation.FieldDescription = "Column name that stores the Hispanic indicator, such as VX_IR_ETHNIC_3.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_3"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colAsian as (
            type text meta [
                Documentation.FieldCaption = "Asian Column",
                Documentation.FieldDescription = "Column name that stores the Asian indicator, such as VX_IR_ETHNIC_4.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_4"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colAmInAlk as (
            type text meta [
                Documentation.FieldCaption = "American Indian/Alaskan Native Column",
                Documentation.FieldDescription = "Column name that stores the American Indian or Alaskan Native indicator, such as VX_IR_ETHNIC_5.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_5"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colNspec as (
            type text meta [
                Documentation.FieldCaption = "Not Specified Column",
                Documentation.FieldDescription = "Column name that stores the Not Specified indicator, such as VX_IR_ETHNIC_6.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_6"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        colHawPac as (
            type text meta [
                Documentation.FieldCaption = "Native Hawaiian/Pacific Islander Column",
                Documentation.FieldDescription = "Column name that stores the Native Hawaiian or Pacific Islander indicator, such as VX_IR_ETHNIC_7.",
                Documentation.SampleValues = {"VX_IR_ETHNIC_7"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        )
    ) as text
    // Step 2: Function-level documentation
    meta [
        Documentation.Name = "List.RaceRecode",
        Documentation.Author = "Win Iden",
        Documentation.LongDescription = "
            <p><b>List.RaceRecode</b></p>
            <li>Invoke with Table.AddColumnto determine race and ethnicity from indicator columns.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>colHispFlag</b>: Hispanic flag column name.</li>
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
                Code = "Table.AddColumn(""Source"", ""Race"", M[List.RaceRecode]([VX_IR_HISP], [VX_IR_ETHNIC_1], [VX_IR_ETHNIC_2], [VX_IR_ETHNIC_3], [VX_IR_ETHNIC_4], [VX_IR_ETHNIC_5], [VX_IR_ETHNIC_6], [VX_IR_ETHNIC_7]))",
                Result = """Returns SourceTable with a new Race column."""
            ]
        }
    ],
    // Step 3: Function implementation
    RaceRecode = (
        colHispFlag as text,
        colWhite as text,
        colBlack as text,
        colHisp as text,
        colAsian as text,
        colAmInAlk as text,
        colNspec as text,
        colHawPac as text
    ) =>
        let
            addedRace =
                if colHisp = "Y" or colHispFlag = "Y" then
                    "Hispanic"
                else if colNspec = "Y" then
                    "Not Specified"
                else if List.Count(List.Select({colWhite, colBlack, colAsian, colAmInAlk, colHawPac}, each _ = "Y")) > 1 then
                    "Two or more"
                else if colWhite = "Y" then
                    "White"
                else if colBlack = "Y" then
                    "Black/African American"
                else if colAsian = "Y" then
                    "Asian"
                else if colAmInAlk = "Y" then
                    "American Indian/Alaskan Native"
                else if colHawPac = "Y" then
                    "Native Hawaiian/Pacific Islander"
                else
                    "Unknown"
        in
            addedRace
in
    Value.ReplaceType(RaceRecode, metaDocumentation)
