let
    // ─── Step 1: Parameter documentation metadata ────────────────────────────
    metaDocumentation = type function (
        dateValue as (type date meta [
            Documentation.FieldCaption = "Date",
            Documentation.FieldDescription = "The date for which to compute the fiscal quarter label.",
            Documentation.SampleValues = {#date(2026, 3, 15)},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional fiscalYearStartMonth as (type nullable number meta [
            Documentation.FieldCaption = "Fiscal Year Start Month",
            Documentation.FieldDescription = "Month number (1-12) where the fiscal year begins. Defaults to 7 (July).",
            Documentation.SampleValues = {7},
            Documentation.AllowedValues = {1,2,3,4,5,6,7,8,9,10,11,12},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as text
    // ─── Step 2: Function-level documentation ────────────────────────────────
    meta [
        Documentation.Name = "Date.QuarterLabel",
        Documentation.Author = "CustomFunctionsLibrary",
        Documentation.LongDescription = "
            <p><b>Date.QuarterLabel</b></p>
            <li>Returns a fiscal quarter label string such as <code>Q1 FY2026</code>.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>dateValue</b>: The input date.</li>
                <li><b>fiscalYearStartMonth</b> (optional): Month the fiscal year begins (default 7 = July).</li>
            </ul>
            <b>Returns:</b> Text — e.g. <code>Q2 FY2026</code>
        ",
        Documentation.Examples = {
            [
                Description = "Get fiscal quarter label for March 2026 with July fiscal year start.",
                Code = "Date.QuarterLabel(#date(2026, 3, 15), 7)",
                Result = """Q3 FY2026"""
            ]
        }
    ],

    // ─── Step 3: Function implementation ─────────────────────────────────────
    QuarterLabel = (dateValue as date, optional fiscalYearStartMonth as nullable number) =>
        let
            fyStart      = fiscalYearStartMonth ?? 7,
            m            = Date.Month(dateValue),
            y            = Date.Year(dateValue),
            fiscalMonth  = Number.Mod(m - fyStart + 12, 12) + 1,
            quarter      = Number.IntegerDivide(fiscalMonth - 1, 3) + 1,
            fiscalYear   = if m >= fyStart then y + 1 else y,
            label        = "Q" & Number.ToText(quarter) & " FY" & Number.ToText(fiscalYear)
        in
            label
in
    Value.ReplaceType(QuarterLabel, metaDocumentation)
