// @snippet.title: IR STRM TBL
// @snippet.description: Snippet for IR_STRM_TBL.
// @snippet.tags: auto-generated

// IR_STRM_TBL
let
    // ------------------------------------------------------------
    // Configuration:
    // This query produces a valid STRM table for both summer-leading and summer-trailing academic years and maintains folding to source.   
    // ------------------------------------------------------------
    // ------------------------------------------------------------
    // Source
    // ------------------------------------------------------------
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    IR_STRM_TBL = Source{[Schema = "dbo", Item = "IR_STRM_TBL"]}[Data],
    // Keep only credential career rows and narrow columns early.
    // These steps should remain foldable.
    CredCareerRows = Table.SelectRows(IR_STRM_TBL, each [ACAD_CAREER] = "CRED"),
    NarrowColumns = Table.SelectColumns(
        CredCareerRows, {"STRM", "DESCR",  "TERM_BEGIN_DT", "TERM_END_DT", "ACAD_YEAR"}
    ),
    EnsureDateTypes = Table.TransformColumnTypes(
        NarrowColumns, {{"TERM_BEGIN_DT", type date}, {"TERM_END_DT", type date}}
    ),
    // ------------------------------------------------------------
    // Build term attributes
    // ------------------------------------------------------------
    AddTermDescrLower = Table.AddColumn(
        EnsureDateTypes, "TermDescrLower", each if [DESCR] <> null then Text.Lower([DESCR]) else null, type text
    ),
    AddCalendarYear = Table.AddColumn(
        AddTermDescrLower,
        "Calendar Year",
        each if [TERM_BEGIN_DT] <> null then Date.Year([TERM_BEGIN_DT]) else null,
        type number
    ),
    AddTermType = Table.TransformColumns(AddCalendarYear, {{"DESCR", each Text.Range(_, 5), type text}}),
    RenameDescCol = Table.RenameColumns(AddTermType, {{"DESCR", "Term Type"}}),
    // ------------------------------------------------------------
    // Build term attributes
    // ------------------------------------------------------------

    // ------------------------------------------------------------
    // Build selected calendar fields for both LRCC and VCCS
    // ------------------------------------------------------------
    AddAcademicYearLRCC = Table.AddColumn(
        RenameDescCol,
        "Academic-Year LRCC",
        each
            if [Term Type] = "Fall" then
                Text.From([Calendar Year]) & "-" & Text.From([Calendar Year] + 1)
            else
                Text.From([Calendar Year] - 1) & "-" & Text.From([Calendar Year]),
        type text
    ),
    AddAcademicYearVCCS = Table.AddColumn(
        AddAcademicYearLRCC,
        "Academic-Year VCCS",
        each
            if [Term Type] = "Spring" then
                Text.From([Calendar Year] - 1) & "-" & Text.From([Calendar Year])
            else
                Text.From([Calendar Year]) & "-" & Text.From([Calendar Year] + 1),
        type text
    ),
    AddSortOrderLRCC = Table.AddColumn(
        AddAcademicYearVCCS,
        "Sort Order LRCC",
        each if [Term Type] = "Fall" then 1 else if [Term Type] = "Spring" then
            2
        else if [Term Type] = "Summer" then
            3
        else
            null,
        type number
    ),
    AddSortOrderVCCS = Table.AddColumn(
        AddSortOrderLRCC,
        "Sort Order VCCS",
        each if [Term Type] = "Summer" then 1 else if [Term Type] = "Fall" then
            2
        else if [Term Type] = "Spring" then
            3
        else
            null,
        type number
    ),
    RenameDateColumns = Table.RenameColumns(
        AddSortOrderVCCS, {{"TERM_BEGIN_DT", "Term Begin Date"}, {"TERM_END_DT", "Term End Date"}}
    ),
    RemoveWorkingColumns = Table.RemoveColumns(RenameDateColumns, {"DESCR", "ACAD_YEAR", "TermDescrLower"})
in
    RemoveWorkingColumns