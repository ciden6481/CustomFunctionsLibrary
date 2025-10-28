let
    //We start with IR_CLASS_GRADE_ROSTER and isolate student identifying columns
    Source = GradedStudents,
    // Join with IR_STUDENT to get student identifying information and attributes.
    // We do an inner join to eliminate students who are included in the grade table but not the student table.
    // This can happen if they enroll and then drop all classes, they won't be included in IR_STUDENT F2 rows.
    MergeFilteredStudentTable = Table.NestedJoin(
        Source, {"strm-stu key"}, #"IR_STUDENT with vars", {"strm-stu key"}, "IR_STUDENT", JoinKind.Inner
    ),
    #"Expanded IR_STUDENT" = Table.ExpandTableColumn(
        MergeFilteredStudentTable,
        "IR_STUDENT",
        {
            "STRM",
            "EMPLID",
            "ACAD_PLAN",
            "SEX",
            "COUNTY",
            "High School",
            "VX_IR_HS_GRAD_YR",
            "VX_IR_INT_TRANSFER",
            "BIRTHDATE",
            "RESIDENCY",
            "MILITARY_STATUS",
            "UNT_TERM_TOT",
            "Course Load",
            "Student DE",
            "Race",
            "Enrollment Status",
            "Enrollment Status (int xfer only)",
            "NRA",
            "FirstGen",
            "TRANS_JURIS_TBL",
            "TRANS_Mil_Code",
            "PellEligibility"
        },
        {
            "STRM",
            "EMPLID",
            "ACAD_PLAN",
            "SEX",
            "COUNTY",
            "High School",
            "VX_IR_HS_GRAD_YR",
            "VX_IR_INT_TRANSFER",
            "BIRTHDATE",
            "RESIDENCY",
            "MILITARY_STATUS",
            "UNT_TERM_TOT",
            "Course Load",
            "Student DE",
            "Race",
            "Enrollment Status",
            "Enrollment Status (int xfer only)",
            "NRA",
            "FirstGen",
            "TRANS_JURIS_TBL",
            "TRANS_Mil_Code",
            "PellEligibility"
        }
    ),
    ExpandPellEligibilityColumns = Table.ExpandTableColumn(
        #"Expanded IR_STUDENT", "PellEligibility", {"PELL_ELIGIBILITY"}, {"PellElig"}
    ),
    //Replace values so they're usable as categories in PowerBI
    RecodePellEligValues = Table.ReplaceValue(
        ExpandPellEligibilityColumns, "Y", "PellElig", Replacer.ReplaceText, {"PellElig"}
    ),
    //Replace values so they're usable as categories in PowerBI
    RecodePellEligNullValues = Table.ReplaceValue(
        RecodePellEligValues, null, "Not PellELig", Replacer.ReplaceValue, {"PellElig"}
    ),
    //Determine student URP status
    DetermineURP = Table.AddColumn(
        RecodePellEligNullValues,
        "URP",
        each
            if
                (
                    (List.Contains({"Not Specified", "Unknown", "White", null}, [Race]))
                    or (List.Contains({"068", "091"}, [COUNTY]))
                    or [FirstGen] = "FirstGen"
                    or [PellElig] = "PellElig"
                )
                and [NRA] <> "NRA"
            then
                "URP"
            else
                "Not URP"
    ),
    ExpandJurisColumns = Table.ExpandTableColumn(
        DetermineURP, "TRANS_JURIS_TBL", {"name", "svc_area_flag"}, {"Location", "Service Area"}
    ),
    ExpandMilCodeColumns = Table.ExpandTableColumn(
        ExpandJurisColumns, "TRANS_Mil_Code", {"Mil_Name"}, {"Military Status"}
    ),
    RemoveMilCodeColumns = Table.RemoveColumns(ExpandMilCodeColumns, {"MILITARY_STATUS"}),
    RenameMultipleColumns = Table.RenameColumns(
        ExpandMilCodeColumns,
        {
            {"SEX", "Gender"},
            {"ACAD_PLAN", "acadplan"},
            {"COUNTY", "County"},
            {"VX_IR_HS_GRAD_YR", "HS Grad Year"},
            {"RESIDENCY", "Residency"}
        }
    ),
    //This function looks for acadplans that have been changed (plan code) in the plan table and replaces them with the current plan code.
    //This allows "equivalent" plans to be grouped together under the new plan name and degree
    RemapPlans = PlanSwitcheroo(RenameMultipleColumns, "acadplan"),
    #"Merged Queries2" = Table.NestedJoin(
        RemapPlans, {"acadplan"}, IR_ALL_PLANS, {"ACAD_PLAN"}, "IR_ALL_PLANS", JoinKind.LeftOuter
    ),
    ExpandPlanTable = Table.ExpandTableColumn(
        #"Merged Queries2", "IR_ALL_PLANS", {"DESCR", "DEGREE"}, {"Academic Plan", "Degree"}
    ),
    //Replace values so they're usable as categories in PowerBI
    ReplaceNullDegrValue = Table.ReplaceValue(ExpandPlanTable, null, "NonDeg", Replacer.ReplaceValue, {"Degree"}),
    //Replace values so they're usable as categories in PowerBI
    ReplaceNullSvcAreaValue = Table.ReplaceValue(
        ReplaceNullDegrValue, " ", "Not InSvcArea", Replacer.ReplaceValue, {"Service Area"}
    ),
    //Replace values so they're usable as categories in PowerBI
    ReplaceSvcAreaValue = Table.ReplaceValue(
        ReplaceNullSvcAreaValue, "1", "InSvcArea", Replacer.ReplaceText, {"Service Area"}
    ),
    //Replace values so they're usable as categories in PowerBI
    RemoveFinalUnnecessaryColumns = Table.RemoveColumns(
        ReplaceSvcAreaValue, {"MILITARY_STATUS", "VX_IR_INT_TRANSFER", "BIRTHDATE"}
    )
in
    RemoveFinalUnnecessaryColumns
