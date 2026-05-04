let
    // Function to retrieve the current STRM value from the database
    output = () =>
        let
            // Connect to the SQL Server database instance
            Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
            // Access the "IR_STRM_TBL" table in the "dbo" schema
            dbo_IR_STRM_TBL = Source{[Schema = "dbo", Item = "IR_STRM_TBL"]}[Data],
            // Filter rows where "ACAD_CAREER" equals "CRED"
            #"Filtered Rows" = Table.SelectRows(dbo_IR_STRM_TBL, each ([ACAD_CAREER] = "CRED")),
            // Further filter rows where the current date is between "TERM_BEGIN_DT" and "TERM_END_DT"
            #"Filtered Rows1" = Table.SelectRows(
                #"Filtered Rows",
                each [TERM_BEGIN_DT] < DateTime.FixedLocalNow() and [TERM_END_DT] > DateTime.FixedLocalNow()
            ),
            // Select only the "STRM" column from the filtered rows
            #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows1", {"STRM"}),
            // Retrieve the first value from the "STRM" column
            STRM1 = #"Removed Other Columns"{0}[STRM]
        in
            // Return the "STRM" value
            STRM1,
    // Documentation metadata
    documentation = [
        Documentation.Name = "GetCurrentSTRM",
        Documentation.LongDescription = "This function connects to the datamart term table,  filters based on the current date, and retrieves the current 'STRM' value.",
        Documentation.Examples = {
            [
                Description = "Retrieve the current 'STRM' value from the database.",
                Code = "CurrentSTRM = GetCurrentSTRM()",
                Result = "E.g., 2201"
            ]
        },
        //Documentation.Author = "Your Name",
        //Documentation.Version = "1.0",
        //Documentation.Category = "Database Functions",
        Documentation.Source = "IR_STRM_TBL",
        Documentation.Description = "Fetches the current 'STRM' value from the database based on specific filters."
    ]
in
    Value.ReplaceType(
    // Replace type of the value
    output,
    // Function caller
    Value.ReplaceMetadata(
        // Replace metadata of the function
        Value.Type(output),
        // Return output type of function
        documentation
        // Documentation assigment
    ))
