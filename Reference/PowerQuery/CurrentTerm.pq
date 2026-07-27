let
    /*
        GetCurrentSTRM()

        Returns the active academic term code (STRM) from the IR_STRM_TBL term table.

        Notes:
        - No input parameters.
        - If no active term row exists the final indexing step will error; consider using `try GetCurrentSTRM()`
          or replacing the final lookup with a safe-first-value pattern (`Table.FirstValue`).
    */
    GetCurrentSTRM = () =>
        let
            // Capture current local datetime once for consistent comparisons
            now = DateTime.FixedLocalNow(),
            // Connect to the SQL Server database instance (environment-specific)
            Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
            // Access the "IR_STRM_TBL" table in the "dbo" schema
            dbo_IR_STRM_TBL = Source{[Schema = "dbo", Item = "IR_STRM_TBL"]}[Data],
            // Keep only rows where ACAD_CAREER indicates credit-bearing terms
            FilteredCred = Table.SelectRows(dbo_IR_STRM_TBL, each ([ACAD_CAREER] = "CRED")),
            // Find rows where the current datetime lies between TERM_BEGIN_DT and TERM_END_DT
            CurrentTermRows = Table.SelectRows(FilteredCred, each [TERM_BEGIN_DT] < now and [TERM_END_DT] > now),
            // Keep only the STRM column
            STRMTable = Table.SelectColumns(CurrentTermRows, {"STRM"}),
            // Retrieve the first STRM value (will error if table is empty)
            ResultSTRM = STRMTable{0}[STRM]
        in
            ResultSTRM,

    // Documentation metadata attached to the function for editor/help surfaces
    documentation = [
        Documentation.Name = "GetCurrentSTRM",
        Documentation.LongDescription = "Connects to the datamart term table and returns the active academic term code (STRM) where the current local datetime lies between TERM_BEGIN_DT and TERM_END_DT. Filters to ACAD_CAREER = \"CRED\".",
        Documentation.Description = "Fetches the current 'STRM' value from IR_STRM_TBL based on the current date/time.",
        Documentation.Category = "Date/Time",
        Documentation.Source = "IR_STRM_TBL",
        Documentation.Examples = {
            [
                Description = "Return the current STRM value.",
                Code = "CurrentSTRM = GetCurrentSTRM()",
                Result = "2201"
            ]
        },
        Documentation.Notes = "If no active term is found the function will error when attempting to index the first row; consider using `try GetCurrentSTRM()` or using `Table.FirstValue(STRMTable, null)` to return null instead of an error."
    ]
in
    Value.ReplaceType(
        GetCurrentSTRM,
        Value.ReplaceMetadata(
            Value.Type(GetCurrentSTRM),
            documentation
        )
    )
