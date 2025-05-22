let
    // Source data from IR_CLASS_GRADE_ROSTER
    Source = IR_CLASS_GRADE_ROSTER,
    // Remove unnecessary columns from the source table
    #"Removed Class Roster Columns" = Table.RemoveColumns(
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
    // Filter out rows where the student ID is null
    FilterOutNullStudentIDs = Table.SelectRows(#"Removed Class Roster Columns", each ([STU_EMPLID] <> null)),
    // Unique key for student by term
    // Add a column for a unique key combining term and student ID
    AddStrmStuKey = Table.AddColumn(
        FilterOutNullStudentIDs, "strm-stu key", each [STRM] & "-" & [STU_EMPLID], type text
    ),
    // Remove duplicate rows based on the unique term-student key
    RemoveDuplicateStrmStuKeys = Table.Distinct(AddStrmStuKey, {"strm-stu key"}),
    #"Merged Queries" = Table.NestedJoin(
        RemoveDuplicateStrmStuKeys, {"strm-stu key"}, IR_STUDENT, {"strm-stu key"}, "IR_STUDENT", JoinKind.Inner
    ),
    #"Expanded IR_STUDENT" = Table.ExpandTableColumn(
        #"Merged Queries",
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
    // Add a column to determine if the student is full-time (FT) or part-time (PT) based on total term units
    AddCourseLoad = Table.AddColumn(
        #"Expanded IR_STUDENT", "Course Load", each if [UNT_TERM_TOT] >= 12 then "FT" else "PT"
    ),
    AddStudentDEFlag = Table.AddColumn(
        AddCourseLoad,
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
    // Recode ethnic flags into a single 'Race' column based on specific logic
    RecodeRace = Table.AddColumn(
        AddStudentDEFlag,
        //Replace with name of previous step
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
    // Remove the individual ethnic flag columns
    RemoveEthnicityFlags = Table.RemoveColumns(
        RecodeRace,
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
    DetermineEnrollmentStatus = Table.AddColumn(
        RemoveEthnicityFlags,
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
    // Determine enrollment status considering only internal transfers
    DetermineEnrollmentStatusIntXferOnly = Table.AddColumn(
        DetermineEnrollmentStatus,
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
    // Remove columns used for determining enrollment status
    RemoveEnrollmentStatusColumns = Table.RemoveColumns(
        DetermineEnrollmentStatusIntXferOnly, {"VX_IR_PRIOR_STDNT", "FICE_CD", "VX_IR_PREV_DEGREE", "ADMIT_TYPE"}
    ),
    // Add a flag for Non-Resident Alien (NRA) status
    AddNRAFlag = Table.AddColumn(
        RemoveEnrollmentStatusColumns,
    DetermineNRA = Table.AddColumn(
        "NRA",
        each if [CITIZENSHIP_STATUS] = "4" and [VISA_PERMIT_TYPE] <> "PR" then "NRA" else "Not NRA"
    ),
    RemovedVISAAndCitizenshipColumns = Table.RemoveColumns(DetermineNRA, {"VISA_PERMIT_TYPE", "CITIZENSHIP_STATUS"}),
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
    // Remove the highest education columns
    RemoveHighestEduColumns = Table.RemoveColumns(DetermineFirstGen, {"VX_HIGHEST_EDU", "VX_HIGHEST_EDU_1"}),
    MergeWithPellEligibility = Table.NestedJoin(
        #"Removed Columns8", "strm-stu key", PellEligibility, "strm-stu key", "PellEligibility"
    ),
    #"Expanded PellEligibility" = Table.ExpandTableColumn(
        JoinWithPellEligibility, "PellEligibility", {"PELL_ELIGIBILITY"}, {"PellElig"}
    ),
    // Replace 'Y' in PellElig with 'PellElig'
    #"Replaced Value3" = Table.ReplaceValue(
        #"Expanded PellEligibility", "Y", "PellElig", Replacer.ReplaceText, {"PellElig"}
    ),
    // Renamed from #"Replaced Value4"
    // Replace null values in PellElig with 'Not PellELig'
    ReplaceNullPellElig = Table.ReplaceValue(
        #"Replaced Value3", null, "Not PellELig", Replacer.ReplaceValue, {"PellElig"}
    ),
    // Determine if the student is Underrepresented Population (URP) based on race, county, first-gen status, and pell eligibility
    DetermineURP = Table.AddColumn(
        ReplaceNullPellElig,
    DetermineURP = Table.AddColumn(ReplaceNullPellElig,
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
    // Rename the 'DESCR' column to 'High School'
    RenameDescriptionToHighSchool = Table.RenameColumns(DetermineURP, {{"DESCR", "High School"}}),
    MergeWithJurisdictionTable = Table.NestedJoin(
        RenameDescriptionToHighSchool, {"COUNTY"}, TRANS_JURIS_TBL, {"juris"}, "TRANS_JURIS_TBL", JoinKind.LeftOuter
    ),
    MergeWithMilitaryCodeTable = Table.NestedJoin(
        MergeWithJurisdictionTable,
        {"MILITARY_STATUS"},
        TRANS_Mil_Code,
        {"Mil_Code"},
        "TRANS_Mil_Code",
        JoinKind.LeftOuter
    ),
    // Expand the merged TRANS_JURIS_TBL table
    #"Expanded TRANS_JURIS_TBL1" = Table.ExpandTableColumn(
        #"Merged Queries1", "TRANS_JURIS_TBL", {"name", "svc_area_flag"}, {"Location", "Service Area"}
    ),
    // Expand the merged TRANS_Mil_Code table
    #"Expanded TRANS_Mil_Code" = Table.ExpandTableColumn(
        #"Expanded TRANS_JURIS_TBL1", "TRANS_Mil_Code", {"Mil_Name"}, {"Military Status"}
    ),
    // Remove the original military status code column
    RemoveMilitaryStatusCode = Table.RemoveColumns(#"Expanded TRANS_Mil_Code", {"MILITARY_STATUS"}),
    RenameKeyColumns = Table.RenameColumns(
        #"Expanded TRANS_Mil_Code",
        {
            {"SEX", "Gender"},
            {"ACAD_PLAN", "acadplan"},
            {"COUNTY", "County"},
            {"VX_IR_HS_GRAD_YR", "HS Grad Year"},
            {"RESIDENCY", "Residency"}
        }
    ),
    // Apply a custom function 'PlanSwitcheroo' to the 'acadplan' column
    RemapPlans = PlanSwitcheroo(RenameKeyColumns, "acadplan"),
    // Merge with the IR_ALL_PLANS table based on academic plan
    MergeWithAllPlans = Table.NestedJoin(
        RemapPlans, {"acadplan"}, IR_ALL_PLANS, {"ACAD_PLAN"}, "IR_ALL_PLANS", JoinKind.LeftOuter
    ),
    // Expand the merged IR_ALL_PLANS table
    #"Expanded IR_ALL_PLANS" = Table.ExpandTableColumn(
        MergeWithAllPlans, "IR_ALL_PLANS", {"DESCR", "DEGREE"}, {"Academic Plan", "Degree"}
    ),
    // Replace null values in the 'Degree' column with 'NonDeg'
    ReplaceNullDegreeWithNonDeg = Table.ReplaceValue(
        #"Expanded IR_ALL_PLANS", null, "NonDeg", Replacer.ReplaceValue, {"Degree"}
    ),
    // Replace space values in 'Service Area' with 'Not InSvcArea'
    ReplaceSpaceServiceAreaWithNotInSvcArea = Table.ReplaceValue(
        ReplaceNullDegreeWithNonDeg, " ", "Not InSvcArea", Replacer.ReplaceText, {"Service Area"}
    ),
    ReplaceOneServiceAreaWithInSvcArea = Table.ReplaceValue(
        ReplaceSpaceServiceAreaWithNotInSvcArea, "1", "InSvcArea", Replacer.ReplaceText, {"Service Area"}
    ),
    RemoveFinalUnusedColumns = Table.RemoveColumns(
        ReplaceOneServiceAreaWithInSvcArea, {"MILITARY_STATUS", "VX_IR_INT_TRANSFER", "BIRTHDATE"}
    )
    // Final output table
in
    RemoveFinalUnusedColumns
