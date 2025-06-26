let
    StartDate = CalendarStart,
    EndDate = CalendarEnd,
    // Find the number of days between the end date and the start date
    NumberOfDates = Duration.Days(EndDate - StartDate) + 1,
    // Generate a continuous list of dates from the start date to the end date
    DateList = List.Dates(StartDate, NumberOfDates, #duration(1, 0, 0, 0)),
    // Turn this list into a table
    TableFromList = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),
    DateColToDateType = Table.TransformColumnTypes(TableFromList, {{"Date", type date}}),
    // Add custom columns for day of month, month number, year
    AddDayOfMonth = Table.AddColumn(DateColToDateType, "DayOfMonth", each Date.Day([Date]), type text),
    AddMonthNumber = Table.AddColumn(AddDayOfMonth, "MonthNumber", each Date.Month([Date]), type text),
    AddYear = Table.AddColumn(AddMonthNumber, "Year", each Date.Year([Date]), type text),
    AddMonthName = Table.AddColumn(AddYear, "MonthName", each Date.MonthName([Date]), type text),
    AddWeekdayName = Table.AddColumn(AddMonthName, "WeekdayName", each Date.DayOfWeekName([Date]), type text),
    // Add a column that returns true if the date on rows is the current date
    AddIsToday = Table.AddColumn(AddWeekdayName, "IsToday", each Date.IsInCurrentDay([Date]), type text),
    //Look up STRM based on whether date falls between TERM_BEGIN_DT and TERM_END_DT
    AddSTRM = Table.TransformColumnTypes(
        Table.AddColumn(
            AddIsToday,
            "STRM",
            each
                let
                    currentDate = [Date],
                    matchedRow = Table.SelectRows(
                        IR_STRM_TBL, each currentDate >= [TERM_BEGIN_DT] and currentDate <= [TERM_END_DT]
                    ),
                    result = if Table.IsEmpty(matchedRow) then null else matchedRow{0}[STRM]
                in
                    result
        ),
        {{"STRM", type text}}
    ),
    MergedSTRMtbl = Table.NestedJoin(AddSTRM, {"STRM"}, IR_STRM_TBL, {"STRM"}, "IR_STRM_TBL", JoinKind.LeftOuter),
    ExpandSTRMTbl = Table.ExpandTableColumn(
        MergedSTRMtbl,
        "IR_STRM_TBL",
        {"DESCR", "TERM_BEGIN_DT", "TERM_END_DT", "ACAD_YEAR"},
        {"TermDescription", "TermBeginDate", "TermEndDate", "Academic Year"}
    ),
    AddSemester = Table.AddColumn(
        ExpandSTRMTbl,
        "Semester",
        each if [STRM] = null then null else Text.End([TermDescription], Text.Length([TermDescription]) - 5),
        type text
    ),
    AddAcademicYear = Table.TransformColumnTypes(
        Table.AddColumn(
            AddSemester, "Academic-Year", each Text.From(Number.From([Academic Year]) - 1) & "-" & [Academic Year]
        ),
        {{"Academic-Year", type text}}
    ),
    AddIsCurrentTerm = Table.AddColumn(
        AddAcademicYear,
        "IsCurrentTerm",
        each
            let
                currentDate = Date.From(DateTime.FixedLocalNow())
            in
                if [STRM] <> null and currentDate >= [TermBeginDate] and currentDate <= [TermEndDate] then
                    "TRUE"
                else
                    "FALSE",
        type text
    ),
    AddIsTermStart = Table.AddColumn(
        AddIsCurrentTerm,
        "IsTermStart",
        each if [STRM] <> null and [Date] = [TermBeginDate] then "TRUE" else "FALSE",
        type text
    ),
    AddWeeksFromTermStart = Table.AddColumn(
        AddIsTermStart,
        "WeeksFromTermStart",
        each
            if [STRM] <> null and [Date] >= [TermBeginDate] then
                Number.IntegerDivide(Duration.Days([Date] - [TermBeginDate]), 7)
            else
                null,
        type number
    ),
    AddDaysFromTermStart = Table.AddColumn(
        AddWeeksFromTermStart,
        "DaysFromTermStart",
        each if [STRM] <> null and [Date] >= [TermBeginDate] then Duration.Days([Date] - [TermBeginDate]) else null,
        type number
    ),
    TermTable = IR_STRM_TBL,
    AddNextSTRM = Table.AddColumn(
        AddDaysFromTermStart,
        "NextSTRM",
        each
            let
                currentDate = [Date],
                futureTerms = Table.SelectRows(TermTable, each [TERM_BEGIN_DT] > currentDate),
                sortedTerms = Table.Sort(futureTerms, {"TERM_BEGIN_DT", Order.Ascending}),
                nextSTRM = if Table.RowCount(sortedTerms) > 0 then sortedTerms{0}[STRM] else null
            in
                nextSTRM,
        type text
    ),
    AddWeeksFromNextTermStart = Table.AddColumn(
        AddNextSTRM,
        "WeeksFromNextTermStart",
        each
            let
                currentDate = [Date],
                futureTerms = Table.SelectRows(TermTable, each [TERM_BEGIN_DT] > currentDate),
                sortedTerms = Table.Sort(futureTerms, {"TERM_BEGIN_DT", Order.Ascending}),
                weeksFromStart =
                    if Table.RowCount(sortedTerms) > 0 then
                        Number.IntegerDivide(Duration.Days([Date] - sortedTerms{0}[TERM_BEGIN_DT]), 7)
                    else
                        null
            in
                weeksFromStart,
        type number
    ),
    AddDaysFromNextTermStart = Table.AddColumn(
        AddWeeksFromNextTermStart,
        "DaysFromNextTermStart",
        each
            let
                currentDate = [Date],
                futureTerms = Table.SelectRows(TermTable, each [TERM_BEGIN_DT] > currentDate),
                sortedTerms = Table.Sort(futureTerms, {"TERM_BEGIN_DT", Order.Ascending}),
                daysFromStart =
                    if Table.RowCount(sortedTerms) > 0 then
                        Duration.Days([Date] - sortedTerms{0}[TERM_BEGIN_DT])
                    else
                        null
            in
                daysFromStart,
        type number
    )
in
    AddDaysFromNextTermStart
