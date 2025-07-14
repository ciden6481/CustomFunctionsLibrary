let
    PlanSwitcheroo = (prevStep as table, acadplancol as text) as table =>
        let
            // Establish a connection to the SQL database.
            DatabaseConnection = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
            // Retrieve the table containing academic plan mappings from the database.
            // This table maps old academic plans to their corresponding new plans.
            RetentionPlanMappingTable = DatabaseConnection{
                [Schema = "dbo", Item = "STATIC_IR_PLAN_RETENTION_PLAN_ASSOCIATION"]
            }[Data],
            // Convert the mapping table into a list of records for easier lookup operations.
            MappingRecords = Table.ToRecords(RetentionPlanMappingTable),
            // Transform the specified column in the input table by replacing old academic plans
            // with their corresponding new plans based on the mapping table.
            TransformedTable = Table.TransformColumns(
                prevStep,
                {
                    acadplancol,
                    // The column in the input table to be transformed.
                    each
                        let
                            // Store the current academic plan value from the input table.
                            CurrentPlanValue = _,
                            // Find the record(s) in the mapping table where the old academic plan
                            // matches the current value from the input table.
                            MatchingRecord = List.Select(
                                MappingRecords, (rec) => rec[ACAD_PLAN_OLD] = CurrentPlanValue
                            ),
                            // Determine the new academic plan value:
                            // - If no matching record is found, retain the original value.
                            // - If a match is found, use the new academic plan from the mapping table.
                            NewPlanValue =
                                if List.IsEmpty(MatchingRecord) then
                                    CurrentPlanValue
                                else
                                    MatchingRecord{0}[ACAD_PLAN_NEW]
                        in
                            // Return the new academic plan value or the original value if no match is found.
                            NewPlanValue
                }
            )
        in
            // Return the transformed table with updated academic plan values.
            TransformedTable
in
    PlanSwitcheroo
