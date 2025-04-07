let
    //Select earliest term begin date from term table
    StartDate = Table.SelectRows(
        TermsTable, let earliest = List.Min(TermsTable[TERM_BEGIN_DT]) in each [TERM_BEGIN_DT] = earliest
    ){
        0
    }[TERM_BEGIN_DT],
    //Select latest term end date from term table
    EndDate = Table.SelectRows(
        TermsTable, let latest = List.Max(TermsTable[TERM_END_DT]) in each [TERM_END_DT] = latest
    ){
        0
    }[TERM_END_DT],
    //Find the number of days between the end date and the start date
    NumberOfDates = Duration.Days(EndDate - StartDate) + 1,
    //Generate a continuous list of dates from the start date to the end date
    DateList = List.Dates(StartDate, NumberOfDates, #duration(1, 0, 0, 0)),
    //Turn this list into a table
    TableFromList = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    //Caste the single column in the table to type date
    ChangedType = Table.TransformColumnTypes(TableFromList, {{"Date", type date}}),
    //Add custom columns for day of month, month number, year
    DayOfMonth = Table.AddColumn(ChangedType, "DayOfMonth", each Date.Day([Date])),
    MonthNumber = Table.AddColumn(DayOfMonth, "MonthOfYearNumber", each Date.Month([Date])),
    Year = Table.AddColumn(MonthNumber, "Year", each Date.Year([Date])),
    DayOfWeekNumber = Table.AddColumn(Year, "DayOfWeekNumber", each Date.DayOfWeek([Date]) + 1),
    //Since Power Query doesn't have functions to return day or month names,
    //use the lists created earlier for this
    MonthName = Table.AddColumn(DayOfWeekNumber, "MonthName", each Date.MonthName([Date])),
    DayName = Table.AddColumn(MonthName, "DayName", each Date.DayOfWeekName([Date])),
    //Add a column that returns true if the date on rows is the current date
    IsToday = Table.AddColumn(DayName, "IsToday", each Date.IsInCurrentDay([Date])),
    //Add a column that returns true if the date on rows is the current week
    IsThisWeek = Table.AddColumn(IsToday, "IsThisWeek", each Date.IsInCurrentWeek([Date])),
    //Add a column that returns true if the date on rows is the current month
    IsThisMonth = Table.AddColumn(IsThisWeek, "IsThisMonth", each Date.IsInCurrentMonth([Date])),
    //Add a column that returns true if the date on rows is the current year
    IsThisYear = Table.AddColumn(IsThisMonth, "IsThisYear", each Date.IsInCurrentYear([Date])),
    TermColumn = Table.AddColumn(IsThisYear, "Term", each Table.SelectRows(TermsTable, each [TERM_BEGIN_DT] <= [Date] and [TERM_END_DT] >= [Date)[Term])
in
    TermColumn
