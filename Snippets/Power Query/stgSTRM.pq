//DON'T USE: NEED TO UPDATE BASED ON NEW LOGIC FROM IR_STRM_TBL.pq

// @snippet.title: stgSTRM
// @snippet.description: Snippet for stgSTRM.
// @snippet.tags: auto-generated

let
    // ------------------------------------------------------------
    // Configuration:
    // This query is parameterless and keeps the most recent 10 completed academic years.
    // Effective date is always the current local date.
    // ------------------------------------------------------------
    YearsToKeep = 10,
    EffectiveAsOfDate = Date.From(DateTime.LocalNow()),
    // ------------------------------------------------------------
    // Source
    // ------------------------------------------------------------
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    IR_STRM_TBL = Source{[Schema = "dbo", Item = "IR_STRM_TBL"]}[Data],
    // Keep only credential career rows and narrow columns early.
    // These steps should remain foldable.
    CredCareerRows = Table.SelectRows(IR_STRM_TBL, each [ACAD_CAREER] = "CRED"),
    NarrowColumns = Table.SelectColumns(
        CredCareerRows, {"STRM", "DESCR", "DESCRSHORT", "TERM_BEGIN_DT", "TERM_END_DT"}
    ),
    EnsureDateTypes = Table.TransformColumnTypes(
        NarrowColumns, {{"TERM_BEGIN_DT", type date}, {"TERM_END_DT", type date}}
    ),
    // Buffer after foldable source filtering/narrowing.
    BufferedSource = Table.Buffer(EnsureDateTypes),
    // ------------------------------------------------------------
    // Build term attributes
    // ------------------------------------------------------------
    AddTermDescrLower = Table.AddColumn(
        BufferedSource, "TermDescrLower", each if [DESCR] <> null then Text.Lower([DESCR]) else null, type text
    ),
    AddCalendarYear = Table.AddColumn(
        AddTermDescrLower,
        "Calendar Year",
        each if [TERM_BEGIN_DT] <> null then Date.Year([TERM_BEGIN_DT]) else null,
        Int64.Type
    ),
    AddTermType = Table.AddColumn(
        AddCalendarYear,
        "Term Type",
        each
            if [TermDescrLower] <> null and Text.Contains([TermDescrLower], "fall") then
                "Fall"
            else if [TermDescrLower] <> null and Text.Contains([TermDescrLower], "spring") then
                "Spring"
            else if [TermDescrLower] <> null and Text.Contains([TermDescrLower], "summer") then
                "Summer"
            else
                null,
        type text
    ),
    // ------------------------------------------------------------
    // Build selected calendar fields for both LRCC and VCCS
    // ------------------------------------------------------------
    AddAcademicYearLRCC = Table.AddColumn(
        AddTermType,
        "Academic-Year LRCC",
        each
            let
                CY = [Calendar Year],
                TT = [Term Type]
            in
                if CY = null or TT = null then
                    null
                else if TT = "Fall" then
                    Text.From(CY) & "-" & Text.From(CY + 1)
                else if List.Contains({"Spring", "Summer"}, TT) then
                    Text.From(CY - 1) & "-" & Text.From(CY)
                else
                    null,
        type text
    ),
    AddAcademicYearVCCS = Table.AddColumn(
        AddAcademicYearLRCC,
        "Academic-Year VCCS",
        each
            let
                CY = [Calendar Year],
                TT = [Term Type]
            in
                if CY = null or TT = null then
                    null
                else if TT = "Fall" then
                    Text.From(CY) & "-" & Text.From(CY + 1)
                else if List.Contains({"Spring", "Summer"}, TT) then
                    Text.From(CY - 1) & "-" & Text.From(CY)
                else
                    null,
        type text
    ),
    AddSortOrderLRCC = Table.AddColumn(
        AddAcademicYearVCCS,
        "Sort Order LRCC",
        each
            if [Term Type] = "Fall" then
                1
            else if [Term Type] = "Spring" then
                2
            else if [Term Type] = "Summer" then
                3
            else
                null,
        Int64.Type
    ),
    AddSortOrderVCCS = Table.AddColumn(
        AddSortOrderLRCC,
        "Sort Order VCCS",
        each
            if [Term Type] = "Fall" then
                1
            else if [Term Type] = "Spring" then
                2
            else if [Term Type] = "Summer" then
                3
            else
                null,
        Int64.Type
    ),
    AddSTRMInt = Table.AddColumn(
        AddSortOrderVCCS, "STRM (int)", each try Number.FromText([STRM]) otherwise null, Int64.Type
    ),
    RenameDateColumns = Table.RenameColumns(
        AddSTRMInt, {{"TERM_BEGIN_DT", "Term Begin Date"}, {"TERM_END_DT", "Term End Date"}}
    ),
    RemoveWorkingColumns = Table.RemoveColumns(RenameDateColumns, {"DESCR", "DESCRSHORT", "TermDescrLower"}),
    // ------------------------------------------------------------
    // Determine most recent completed academic years
    // ------------------------------------------------------------
    RelevantRows = Table.SelectRows(
        RemoveWorkingColumns,
        each
            [#"Term End Date"] <> null
            and ([#"Academic-Year LRCC"] <> null or [#"Academic-Year VCCS"] <> null)
    ),
    AcademicYearSummaryLRCC = Table.Group(
        RelevantRows,
        {"Academic-Year LRCC"},
        {
            {
                "AcademicYearEnd",
                each
                    List.Max(
                        List.Transform(
                            Table.Column(_, "Academic-Year LRCC"), each
                                try Number.FromText(Text.End(_, 4)) otherwise null
                        )
                    ),
                Int64.Type
            },
            {"MaxTermEndDate", each List.Max(Table.Column(_, "Term End Date")), type nullable date}
        }
    ),
    CompleteAcademicYearsLRCC = Table.SelectRows(
        AcademicYearSummaryLRCC,
        each [#"Academic-Year LRCC"] <> null and [MaxTermEndDate] < EffectiveAsOfDate
    ),
    MostRecentAcademicYearsLRCC = Table.FirstN(
        Table.Sort(CompleteAcademicYearsLRCC, {{"AcademicYearEnd", Order.Descending}}),
        YearsToKeep
    ),
    ValidAcademicYearsLRCC = Table.Column(MostRecentAcademicYearsLRCC, "Academic-Year LRCC"),
    AcademicYearSummaryVCCS = Table.Group(
        RelevantRows,
        {"Academic-Year VCCS"},
        {
            {
                "AcademicYearEnd",
                each
                    List.Max(
                        List.Transform(
                            Table.Column(_, "Academic-Year VCCS"), each
                                try Number.FromText(Text.End(_, 4)) otherwise null
                        )
                    ),
                Int64.Type
            },
            {"MaxTermEndDate", each List.Max(Table.Column(_, "Term End Date")), type nullable date}
        }
    ),
    CompleteAcademicYearsVCCS = Table.SelectRows(
        AcademicYearSummaryVCCS,
        each [#"Academic-Year VCCS"] <> null and [MaxTermEndDate] < EffectiveAsOfDate
    ),
    MostRecentAcademicYearsVCCS = Table.FirstN(
        Table.Sort(CompleteAcademicYearsVCCS, {{"AcademicYearEnd", Order.Descending}}),
        YearsToKeep
    ),
    ValidAcademicYearsVCCS = Table.Column(MostRecentAcademicYearsVCCS, "Academic-Year VCCS"),
    FilteredTerms = Table.SelectRows(
        RelevantRows,
        each
            List.Contains(ValidAcademicYearsLRCC, [#"Academic-Year LRCC"])
            or List.Contains(ValidAcademicYearsVCCS, [#"Academic-Year VCCS"])
    ),
    // ------------------------------------------------------------
    // Final output
    // ------------------------------------------------------------
    SelectedColumns = Table.SelectColumns(
        FilteredTerms,
        {
            "STRM",
            "STRM (int)",
            "Term Begin Date",
            "Term End Date",
            "Calendar Year",
            "Term Type",
            "Academic-Year LRCC",
            "Academic-Year VCCS",
            "Sort Order LRCC",
            "Sort Order VCCS"
        }
    ),
    Final = Table.Sort(
        SelectedColumns,
        {{"Calendar Year", Order.Ascending}, {"Sort Order LRCC", Order.Ascending}, {"STRM (int)", Order.Ascending}}
    )
in
    Final
