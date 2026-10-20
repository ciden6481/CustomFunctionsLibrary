// IR_STRM_TBL
let
    Source = IR_STRM_VW,
    CredRows = Table.SelectRows(Source, each [ACAD_CAREER] = "CRED"),
    DateTimeToDate = Table.TransformColumnTypes(CredRows, {{"TERM_BEGIN_DT", type date}, {"TERM_END_DT", type date}}),
    FilterOnlyCompletedTerms = Table.SelectRows(
        DateTimeToDate, each [TERM_END_DT] < Date.From(DateTime.FixedLocalNow())
    ),
    RemoveUnusedCols = Table.SelectColumns(
        FilterOnlyCompletedTerms, {"STRM", "DESCR", "ACAD_YEAR", "YEAR_CALC", "TERM_CODE", "TERM_BEGIN_DT"}
    ),
    AddAcadYearCol = Table.AddColumn(
        RemoveUnusedCols,
        "Academic-Year",
        each
            if [TERM_CODE] = 2 then
                Text.From([YEAR_CALC]) & "-" & [ACAD_YEAR]
            else
                Text.From([YEAR_CALC] - 1) & "-" & [ACAD_YEAR],
        type text
    ),
    AddAcadYearNumCol = Table.AddColumn(
        AddAcadYearCol, "Academic Year (int)", each if [TERM_CODE] = 4 then [YEAR_CALC] + 1 else [YEAR_CALC], type number
    ),
    FallYears = Table.SelectRows(AddAcadYearNumCol, each [TERM_CODE] = 4),
    SpringYears = Table.SelectRows(AddAcadYearNumCol, each [TERM_CODE] = 2),
    SummerYears = Table.SelectRows(AddAcadYearNumCol, each [TERM_CODE] = 3),
    JoinFallSpring = Table.NestedJoin(
        FallYears, {"Academic-Year"}, SpringYears, {"Academic-Year"}, "SpringYears", JoinKind.LeftSemi
    ),
    RemoveNestedSpring = Table.RemoveColumns(JoinFallSpring, {"SpringYears"}),
    JoinFallSummer = Table.NestedJoin(
        RemoveNestedSpring, {"Academic-Year"}, SummerYears, {"Academic-Year"}, "SummerYears", JoinKind.LeftSemi
    ),
    JoinFullYears = Table.NestedJoin(
        AddAcadYearNumCol, {"Academic-Year"}, JoinFallSummer, {"Academic-Year"}, "FullYears", JoinKind.LeftSemi
    ),
    RemoveNestedFall = Table.RemoveColumns(JoinFullYears, {"FullYears"}),
    FilterToReportYears = Table.SelectRows(
        RemoveNestedFall, each [#"Academic Year (int)"] <= LatestYear and [#"Academic Year (int)"] >= EarliestYear
    )
in
    FilterToReportYears
