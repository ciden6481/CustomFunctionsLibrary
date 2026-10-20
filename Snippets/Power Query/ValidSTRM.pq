// @snippet.title: ValidSTRM
// @snippet.description: Snippet for ValidSTRM.
// @snippet.tags: auto-generated

let
    fnValidTerms = (
        InputTable as table, Prefix as text, optional YearCount as nullable number, optional AsOfDate as nullable date
    ) as table =>
        let
            // Standardize prefix value
            CleanPrefix = Text.Upper(Text.Trim(Prefix)),
            // Must have "Sort Order" columns for each prefix to determine term order within academic year
            AvailablePrefixes = List.Transform(
                List.Select(Table.ColumnNames(InputTable), each Text.EndsWith(_, " Sort Order")),
                each Text.BeforeDelimiter(_, " Sort Order")
            ),
            ValidatePrefix =
                if not List.Contains(AvailablePrefixes, CleanPrefix) then
                    error
                        Error.Record(
                            "Missing Required Columns",
                            "InputTable is missing one or more required columns.",
                            [
                                MissingColumns = MissingColumns,
                                AvailableColumns = Table.ColumnNames(InputTable)
                            ]
                        )
                else
                    null,
            // Default to 10 academic years unless another value is supplied
            YearsToKeep = if YearCount = null then 10 else YearCount,
            // Default to today's date unless an as-of date is supplied
            EffectiveAsOfDate = if AsOfDate = null then Date.From(DateTime.LocalNow()) else AsOfDate,
            // Dynamically build prefix-specific column names
            AcademicYearColumn = CleanPrefix & " Academic-Year",
            YearColumn = CleanPrefix & " Year",
            SortOrderColumn = CleanPrefix & " Sort Order",
            // Common columns expected in the term table
            CommonColumns = {"STRM", "Term Begin Date", "Term End Date", "Calendar Year"},
            // Prefix-specific columns expected in the term table
            PrefixColumns = {AcademicYearColumn, YearColumn, SortOrderColumn},
            RequiredColumns = List.Combine({CommonColumns, PrefixColumns}),
            MissingColumns = List.Difference(RequiredColumns, Table.ColumnNames(InputTable)),
            ValidateColumns =
                if List.Count(MissingColumns) > 0 then
                    error
                        Error.Record(
                            "Missing Required Columns",
                            "InputTable is missing one or more required columns.",
                            [
                                MissingColumns = MissingColumns,
                                AvailableColumns = Table.ColumnNames(InputTable)
                            ]
                        )
                else
                    null,
            // Keep rows usable for academic-year completion logic
            RelevantRows = Table.SelectRows(
                InputTable, each Record.Field(_, YearColumn) <> null and Record.Field(_, "Term End Date") <> null
            ),
            // Summarize each academic year by its latest term end date
            AcademicYearSummary = Table.Group(
                RelevantRows,
                {YearColumn},
                {{"MaxTermEndDate", each List.Max(Table.Column(_, "Term End Date")), type nullable date}}
            ),
            // Academic year is complete only after its latest term end date has passed
            CompleteAcademicYears = Table.SelectRows(AcademicYearSummary, each [MaxTermEndDate] < EffectiveAsOfDate),
            // Sort completed years newest to oldest
            SortedCompleteAcademicYears = Table.Sort(CompleteAcademicYears, {{YearColumn, Order.Descending}}),
            // Keep the most recent N completed academic years
            MostRecentAcademicYears = Table.FirstN(SortedCompleteAcademicYears, YearsToKeep),
            ValidYearList = Table.Column(MostRecentAcademicYears, YearColumn),
            // Return all term rows belonging to the valid academic-year window
            FilteredTerms = Table.SelectRows(
                RelevantRows, each List.Contains(ValidYearList, Record.Field(_, YearColumn))
            ),
            // Return common columns plus selected prefix-specific columns
            SelectedColumns = Table.SelectColumns(FilteredTerms, RequiredColumns),
            // Sort oldest academic year to newest, then term order within year
            SortedTerms = Table.Sort(
                SelectedColumns,
                {{YearColumn, Order.Ascending}, {SortOrderColumn, Order.Ascending}, {"STRM", Order.Ascending}}
            )
        in
            SortedTerms
in
    fnValidTerms
