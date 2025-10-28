//DimStudent contains student data, each row represents one term-student.
let
    //We start with IR_CLASS_GRADE_ROSTER and isolate student identifying columns
    Source = IR_CLASS_GRADE_ROSTER,
    RemoveUnneededColumns = Table.RemoveColumns(
        Source,
        {
            "CRSE_ID",
            "SUBJECT",
            "CATALOG_NBR",
            "CLASS_SECTION",
            "SESSION_CODE",
            "SSR_COMPONENT",
            "INSTRUCTION_MODE",
            "CAMPUS",
            "LOCATION",
            "DESCR",
            "ENRL_TOT",
            "UNITS_MINIMUM",
            "ACAD_ORG",
            "VX_IR_CLS_ATR_XDUL",
            "VX_IR_DAY_EVE_CLS",
            "CLASS_NBR",
            "CRSE_GRADE_INPUT"
        }
    ),
    //Null EMPLIDs can happen due to data entry errors
    RemoveNullEMPLID = Table.SelectRows(RemoveUnneededColumns, each ([STU_EMPLID] <> null)),
    // Unique key for student by term, will serve as primary key
    CreateStrmStuKey = Table.AddColumn(RemoveNullEMPLID, "strm-stu key", each [STRM] & "-" & [STU_EMPLID], type text),
    DeduplicateRows = Table.Distinct(CreateStrmStuKey, {"strm-stu key"}),
    //Join with IR_STUDENT to get student identifying information and attributes.
    //We do an inner join to eliminate students who are included in the grade table but not the student table.
    //This can happen if they enroll and then drop all classes, they won't be included in IR_STUDENT F2 rows.
    MergeFilteredStudentTable = Table.NestedJoin(
        DeduplicateRows, {"strm-stu key"}, IR_STUDENT, {"strm-stu key"}, "IR_STUDENT", JoinKind.Inner
    ),
    ExpandStudentColumns = Table.ExpandTableColumn(
        MergeFilteredStudentTable,
        "IR_STUDENT",
        {
            "ACAD_PLAN",
            "SEX",
            "COUNTY",
            "DESCR",
            "VX_IR_HS_GRAD_YR",
            "ADMIT_TYPE",
            "VX_IR_PRIOR_STDNT",
            "VX_IR_INT_TRANSFER",
            "BIRTHDATE",
            "VISA_PERMIT_TYPE",
            "FICE_CD",
            "VX_IR_PREV_DEGREE",
            "CITIZENSHIP_STATUS",
            "RESIDENCY",
            "VX_IR_ETHNIC_1",
            "VX_IR_ETHNIC_2",
            "VX_IR_ETHNIC_3",
            "VX_IR_ETHNIC_4",
            "VX_IR_ETHNIC_5",
            "VX_IR_ETHNIC_6",
            "VX_IR_ETHNIC_7",
            "MILITARY_STATUS",
            "VX_HIGHEST_EDU",
            "VX_HIGHEST_EDU_1",
            "UNT_TERM_TOT",
            "VX_XDUL_ATTRIBUTE"
        },
        {
            "ACAD_PLAN",
            "SEX",
            "COUNTY",
            "DESCR",
            "VX_IR_HS_GRAD_YR",
            "ADMIT_TYPE",
            "VX_IR_PRIOR_STDNT",
            "VX_IR_INT_TRANSFER",
            "BIRTHDATE",
            "VISA_PERMIT_TYPE",
            "FICE_CD",
            "VX_IR_PREV_DEGREE",
            "CITIZENSHIP_STATUS",
            "RESIDENCY",
            "VX_IR_ETHNIC_1",
            "VX_IR_ETHNIC_2",
            "VX_IR_ETHNIC_3",
            "VX_IR_ETHNIC_4",
            "VX_IR_ETHNIC_5",
            "VX_IR_ETHNIC_6",
            "VX_IR_ETHNIC_7",
            "MILITARY_STATUS",
            "VX_HIGHEST_EDU",
            "VX_HIGHEST_EDU_1",
            "UNT_TERM_TOT",
            "VX_XDUL_ATTRIBUTE"
        }
    ),
    //Calculate course load based on UNT_TERM_TOT
    AddCourseLoadColumn = Table.AddColumn(
        ExpandStudentColumns, "Course Load", each if [UNT_TERM_TOT] >= 12 then "FT" else "PT"
    ),
    //Determine if student is DE in the term
    AddStudentDeColumn = Table.AddColumn(
        AddCourseLoadColumn,
        "Student DE",
        each
            if [ACAD_PLAN] = "041" then
                1
            else if [ACAD_PLAN] = "042" then
                1
            else if [ACAD_PLAN] = "043" then
                1
            else if [VX_XDUL_ATTRIBUTE] = "Y" then
                1
            else
                0
    ),
    RemoveXdulColumn = Table.RemoveColumns(AddStudentDeColumn, {"VX_XDUL_ATTRIBUTE"}),
    //Determine student race based on ethncity columns
    CombineRecodeRaceColumns = Table.AddColumn(
        RemoveXdulColumn,
        "Race",
        each
            if [VX_IR_ETHNIC_3] = "Y" then
                "Hispanic"
            else if
                [VX_IR_ETHNIC_1] = "N"
                and [VX_IR_ETHNIC_2] = "N"
                and [VX_IR_ETHNIC_3] = "N"
                and [VX_IR_ETHNIC_4] = "N"
                and [VX_IR_ETHNIC_5] = "N"
                and [VX_IR_ETHNIC_7] = "N"
            then
                "Unknown"
            else if [VX_IR_ETHNIC_6] = "Y" then
                "Not Specified"
            else if
                ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_4] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_7] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_5] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_7] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_5] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_7] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_7] = "Y" and [VX_IR_ETHNIC_5] = "Y")
                or ([VX_IR_ETHNIC_7] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_5] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_2] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_5] = "Y" and [VX_IR_ETHNIC_6] = "Y")
            then
                "Two or more"
            else if [VX_IR_ETHNIC_1] = "Y" then
                "White"
            else if [VX_IR_ETHNIC_2] = "Y" then
                "Black/African American"
            else if [VX_IR_ETHNIC_4] = "Y" then
                "Asian"
            else if [VX_IR_ETHNIC_5] = "Y" then
                "American Indian/Alaskan Native"
            else if [VX_IR_ETHNIC_7] = "Y" then
                "Native Hawaiian/Pacific Islander"
            else
                "Unknown"
    ),
    RemoveEthnicityColumns = Table.RemoveColumns(
        CombineRecodeRaceColumns,
        {
            "VX_IR_ETHNIC_1",
            "VX_IR_ETHNIC_2",
            "VX_IR_ETHNIC_3",
            "VX_IR_ETHNIC_4",
            "VX_IR_ETHNIC_5",
            "VX_IR_ETHNIC_6",
            "VX_IR_ETHNIC_7"
        }
    ),
    //Determine previously enrolled status, considers VCCS transfers as "Returning"
    DeterminePreviouslyEnrolled = Table.AddColumn(
        RemoveEthnicityColumns,
        "Enrollment Status",
        each
            if
                [VX_IR_PRIOR_STDNT] = "Y"
                or (
                    [VX_IR_PRIOR_STDNT] = "N"
                    and List.Contains(
                        {
                            "008659",
                            "004004",
                            "008660",
                            "004004",
                            "006819",
                            "004988",
                            "003748",
                            "008660",
                            "009629",
                            "005223",
                            "009159",
                            "006871",
                            "003712",
                            "007260",
                            "003760",
                            "003761",
                            "007099",
                            "004996",
                            "003759",
                            "003727",
                            "009928",
                            "009160",
                            "008661"
                        },
                        [FICE_CD]
                    )
                )
            then
                "Returning"
            else if
                [VX_IR_PRIOR_STDNT] = "N"
                and (
                    List.Contains({"TR", "TEF", "TRN", "ITF"}, [ADMIT_TYPE])
                    or [VX_IR_PREV_DEGREE] <> null
                    or [FICE_CD] <> null
                )
            then
                "Transfer"
            else
                "New"
    ),
    //KDetermine previously enrolled status, considers VCCS transfers as "Transfer", only previous LRCC as "Returning"
    DeterminePreviouslyEnrolled2 = Table.AddColumn(
        DeterminePreviouslyEnrolled,
        "Enrollment Status (int xfer only)",
        each
            if [ADMIT_TYPE] = "ITF" or ([FICE_CD] <> "008569" and [FICE_CD] <> null) or [VX_IR_PREV_DEGREE] <> null
            then
                "Transfer"
            else if [VX_IR_PRIOR_STDNT] = "Y" then
                "Returning"
            else
                "New"
    ),
    RemoveMoreUnnecessaryColumns = Table.RemoveColumns(
        DeterminePreviouslyEnrolled2, {"VX_IR_PRIOR_STDNT", "FICE_CD", "VX_IR_PREV_DEGREE", "ADMIT_TYPE"}
    ),
    //Determine if student is a non-resident alien
    DetermineNRA = Table.AddColumn(
        RemoveMoreUnnecessaryColumns,
        "NRA",
        each if [CITIZENSHIP_STATUS] = "4" and [VISA_PERMIT_TYPE] <> "PR" then "NRA" else "Not NRA"
    ),
    RemovedVISAAndCitizenshipColumns = Table.RemoveColumns(DetermineNRA, {"VISA_PERMIT_TYPE", "CITIZENSHIP_STATUS"}),
    //Determine if student is first generation
    DetermineFirstGen = Table.AddColumn(
        RemovedVISAAndCitizenshipColumns,
        "FirstGen",
        each
            if
                ([VX_HIGHEST_EDU_1] = "BLHS" and [VX_HIGHEST_EDU] = "BLHS")
                or ([VX_HIGHEST_EDU_1] = "DGHS" and [VX_HIGHEST_EDU] = "DGHS")
                or ([VX_HIGHEST_EDU_1] = "BLHS" and [VX_HIGHEST_EDU] = "UNKNOWN")
                or ([VX_HIGHEST_EDU_1] = "DGHS" and [VX_HIGHEST_EDU] = "UNKNOWN")
                or ([VX_HIGHEST_EDU] = "BLHS" and [VX_HIGHEST_EDU_1] = "UNKNOWN")
                or ([VX_HIGHEST_EDU] = "DGHS" and [VX_HIGHEST_EDU_1] = "UNKNOWN")
                or ([VX_HIGHEST_EDU_1] = "UNKNOWN" and [VX_HIGHEST_EDU] = "UNKNOWN")
            then
                "FirstGen"
            else
                "Not FirstGen"
    ),
    RemoveParentEdColumns = Table.RemoveColumns(DetermineFirstGen, {"VX_HIGHEST_EDU", "VX_HIGHEST_EDU_1"}),
    //Determine Pell Eligibility
    JoinWithPellEligibility = Table.NestedJoin(
        RemoveParentEdColumns, "strm-stu key", PellEligibility, "strm-stu key", "PellEligibility"
    ),
    ExpandPellEligibilityColumns = Table.ExpandTableColumn(
        JoinWithPellEligibility, "PellEligibility", {"PELL_ELIGIBILITY"}, {"PellElig"}
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
    RenameHSColumn = Table.RenameColumns(DetermineURP, {{"DESCR", "High School"}}),
    //Merge with static juris table
    MergeJurisTable = Table.NestedJoin(
        RenameHSColumn, {"COUNTY"}, TRANS_JURIS_TBL, {"juris"}, "TRANS_JURIS_TBL", JoinKind.LeftOuter
    ),
    //Merge with static Military Status table
    MergeMilStatusTable = Table.NestedJoin(
        MergeJurisTable, {"MILITARY_STATUS"}, TRANS_Mil_Code, {"Mil_Code"}, "TRANS_Mil_Code", JoinKind.LeftOuter
    ),
    ExpandJurisColumns = Table.ExpandTableColumn(
        MergeMilStatusTable, "TRANS_JURIS_TBL", {"name", "svc_area_flag"}, {"Location", "Service Area"}
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
