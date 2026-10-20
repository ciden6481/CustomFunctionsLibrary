// @snippet.title: IR STRM TBL (LRCC only)
// @snippet.description: Adapted from IR_STRM_TBL.pq to produce only LRCC academic years, simplifies query for folding downstream.
// @snippet.tags: auto-generated
// IR_STRM_TBL
let
    // ------------------------------------------------------------
    // Configuration:
    // This query produces a valid STRM table for summer-trailing academic years and maintains folding to source.
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
        CredCareerRows, {"STRM", "DESCR", "TERM_BEGIN_DT", "TERM_END_DT", "ACAD_YEAR"}
    ),
    AddCalendarYear = Table.AddColumn(NarrowColumns, "Calendar Year", each Date.Year([TERM_BEGIN_DT]), type number),
    // ------------------------------------------------------------
    // Build selected calendar fields for LRCC
    // Folding limitations mean we need to build the academic year-start and year-end
    // separately as integers, then change type to text, and then combine in separate steps.
    // ------------------------------------------------------------
    // Add integer column for AY end
    AddYearEndColumnLRCC = Table.AddColumn(
        AddCalendarYear,
        "YearEndLRCC",
        each if Text.End([STRM], 1) = "4" then [Calendar Year] + 1 else [Calendar Year],
        type number
    ),
    AddYearEndColumnVCCS = Table.AddColumn(
        AddYearEndColumnLRCC,
        "YearEndVCCS",
        each if Text.End([STRM], 1) = "3" then [Calendar Year] else [Calendar Year] + 1,
        type number
    ),
    //Add integer columns for AY start and end
    AddYearStartColumnLRCC = Table.AddColumn(AddYearEndColumnVCCS, "YearStartLRCC", each [YearEndLRCC] - 1),
    AddYearStartColumnVCCS = Table.AddColumn(AddYearStartColumnLRCC, "YearStartVCCS", each [YearEndVCCS] - 1),
    //Transform the integer columns to text
    TransformYearColumnsToText = Table.TransformColumnTypes(
        AddYearStartColumnVCCS,
        {
            {"YearEndLRCC", type text},
            {"YearStartLRCC", type text},
            {"YearEndVCCS", type text},
            {"YearStartVCCS", type text}
        }
    ),
    CombineYearLRCCColumns = Table.AddColumn(
        TransformYearColumnsToText, "Academic-Year LRCC", each [YearStartLRCC] & "-" & [YearEndLRCC], type text
    ),
    CombineYearVCCSColumns = Table.AddColumn(
        CombineYearLRCCColumns, "Academic-Year VCCS", each [YearStartVCCS] & "-" & [YearEndVCCS], type text
    ),
    RemoveWorkingColumns = Table.RemoveColumns(
        CombineYearVCCSColumns, {"DESCR", "ACAD_YEAR", "YearEndLRCC", "YearStartLRCC", "YearEndVCCS", "YearStartVCCS"}
    ),
    RenameDateColumns = Table.RenameColumns(
        RemoveWorkingColumns, {{"TERM_BEGIN_DT", "Term Begin Date"}, {"TERM_END_DT", "Term End Date"}}
    )
in
    RenameDateColumns
