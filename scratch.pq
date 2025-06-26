let
    // Datamart student table
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    dboIR_STUDENT = Source{[Schema = "dbo", Item = "IR_STUDENT"]}[Data],
    RemoveUnnecessaryCols = Table.RemoveColumns(
        dboIR_STUDENT,
        {
            "INSTITUTION",
            "ACAD_CAREER",
            //"RUNDATE",
            "NATIONAL_ID",
            "DRIVERS_LIC_NBR",
            "VX_IR_DR_LIC_STATE",
            "VX_IR_VA_COLLG_ID",
            "VX_IR_VA_ST_TST_ID",
            "ACAD_PROG",
            "VX_IR_FA_ACAD_PLAN",
            "VX_IR_INIT_PROG",
            "EXT_ORG_ID",
            "STATE2",
            "ATP_CD",
            "EXT_GPA",
            "ACAD_LEVEL_BOT",
            "BIRTHCOUNTRY",
            "VX_IR_LAST_COLLEGE",
            "VX_IR_LAST_COLL_NM",
            "VX_IR_LAST_COLL_ST",
            "VX_IR_CITZEN_CNTRY",
            "TUITION_RES",
            "TUITION_EXCPT",
            "ETHNIC_GRP_CD",
            "VC_JURIS_CODE",
            "FERPA",
            "TERM_END_DT",
            "CENSUS_DT",
            "VX_IR_TKN_GPA_ST",
            "VX_IR_CUM_GPA_ST",
            "VX_IR_CUM_ATMTP_ST",
            "VX_IR_CUM_ERN_ST",
            "UNT_TRNSFR",
            "FA_LOAD",
            "FA_STATUS_CODE_14",
            "VX_FA_ACTIVITY",
            "VX_PROGPLAN_ISSUES",
            "VX_IR_GREAT_EXP",
            "VX_IR_XSSC",
            "CIP_CODE",
            "STDNT_CAR_NBR",
            "ADMIT_TERM"
        }
    ),
    FilterSTRMandF2 = Table.SelectRows(
        RemoveUnnecessaryCols,
        each
            ([VX_IR_EXTRACT_TYPE] = "F2")
            and (
                [STRM] <> "2104"
                and [STRM] <> "2112"
                and [STRM] <> "2113"
                and [STRM] <> "2114"
                and [STRM] <> "2122"
                and [STRM] <> "2123"
                and [STRM] <> "2124"
                and [STRM] <> "2132"
                and [STRM] <> "2133"
                and [STRM] <> "2134"
                and [STRM] <> "2142"
                and [STRM] <> "2143"
            )
    ),
    RemoveExtractCol = Table.RemoveColumns(FilterSTRMandF2, {"VX_IR_EXTRACT_TYPE"}),
    //Combine STRM and EMPLID to create a primary key
    AddPKcol = Table.TransformColumnTypes(
        Table.AddColumn(RemoveExtractCol, "strm-stu key", each [STRM] & "-" & [EMPLID]), {
            {"strm-stu key", type text}
        }
    ),
    RecodeRaceCol = Table.AddColumn(
        AddPKcol,
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
                "Unknown",
        type text
    ),
    RemoveEthnicityCols = Table.RemoveColumns(
        RecodeRaceCol,
        {
            "VX_IR_ETHNIC_7",
            "VX_IR_ETHNIC_6",
            "VX_IR_ETHNIC_5",
            "VX_IR_ETHNIC_4",
            "VX_IR_ETHNIC_3",
            "VX_IR_ETHNIC_2",
            "VX_IR_ETHNIC_1",
            "HISP_LATINO"
        }
    ),
    AddTermDE = Table.AddColumn(
        RemoveEthnicityCols,
        "Term DE",
        each
            if [ACAD_PLAN] = "041" then
                "DE"
            else if [ACAD_PLAN] = "042" then
                "DE"
            else if [ACAD_PLAN] = "043" then
                "DE"
            else if [VX_XDUL_ATTRIBUTE] = "Y" then
                "DE"
            else
                "Not DE",
        type text
    ),
    RemoveXDUL = Table.RemoveColumns(AddTermDE, {"VX_XDUL_ATTRIBUTE"}),
    //Course load based on term credits
    AddCourseLoad = Table.AddColumn(
        RemoveXDUL, "Course Load", each if [UNT_TERM_TOT] >= 12 then "FT" else "PT", type text
    ),
    AddEnrlStatus = Table.AddColumn(
        AddCourseLoad,
        "Enrollment Status",
        each
            if
                [ADMIT_TYPE] = "ITF"
                or ([FICE_CD] <> "008659" and [FICE_CD] <> null and [FICE_CD] <> "")
                or ([VX_IR_PREV_DEGREE] <> null and [VX_IR_PREV_DEGREE] <> "")
            then
                "Transfer"
            else if [VX_IR_PRIOR_STDNT] = "Y" then
                "Returning"
            else
                "New",
        type text
    ),
    RemoveEnrlCols = Table.RemoveColumns(AddEnrlStatus, {"VX_IR_PREV_DEGREE", "FICE_CD"}),
    AddNRA = Table.AddColumn(
        RemoveEnrlCols,
        "NRA",
        each if [CITIZENSHIP_STATUS] = "4" and [VISA_PERMIT_TYPE] <> "PR" then "NRA" else "Not NRA",
        type text
    ),
    RemoveNRAcols = Table.RemoveColumns(
        AddNRA, {"VX_IR_INT_TRANSFER", "VX_IR_PRIOR_STDNT", "VISA_PERMIT_TYPE", "CITIZENSHIP_STATUS"}
    ),
    AddFirstGen = Table.AddColumn(
        RemoveNRAcols,
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
                "Not FirstGen",
        type text
    ),
    //Datamart FA table formatted with pell eligibility info
    JoinPellElig = Table.NestedJoin(
        AddFirstGen, {"strm-stu key"}, PellEligibility_join, {"strm-stu key"}, "PellEligibility", JoinKind.LeftOuter
    ),
    ExpandPellElig = Table.ExpandTableColumn(
        JoinPellElig, "PellEligibility", {"PELL_ELIGIBILITY"}, {"Pell Eligibility"}
    ),
    JoinJuris = Table.NestedJoin(
        ExpandPellElig, {"COUNTY"}, TRANS_JURIS_TBL, {"juris"}, "TRANS_JURIS_TBL", JoinKind.LeftOuter
    ),
    ExpandJuris = Table.ExpandTableColumn(JoinJuris, "TRANS_JURIS_TBL", {"name"}, {"Location"}),
    JoinMilStatus = Table.NestedJoin(
        ExpandJuris, {"MILITARY_STATUS"}, TRANS_Mil_Code, {"Mil_Code"}, "TRANS_Mil_Code", JoinKind.LeftOuter
    ),
    ExpandMilStatus = Table.ExpandTableColumn(JoinMilStatus, "TRANS_Mil_Code", {"Mil_Name"}, {"Military Status"}),
    RenameForReadability = Table.RenameColumns(
        ExpandMilStatus,
        {
            {"CAMPUS", "Campus"},
            {"FIRST_NAME", "First Name"},
            {"LAST_NAME", "Last Name"},
            {"MIDDLE_NAME", "Middle Name"},
            {"NAME_SUFFIX", "Suffix"},
            {"SEX", "Sex"},
            {"ADDRESS1", "Address 1"},
            {"ADDRESS2", "Address 2"},
            {"CITY", "City"},
            {"STATE", "State"},
            {"POSTAL", "Zip"},
            {"DESCR", "High School"},
            {"VX_IR_HS_GRAD_YR", "HS Grad Year"},
            {"BIRTHDATE", "Birthdate"},
            {"RESIDENCY", "Residency"},
            {"DEGREE", "Degree"},
            {"UNT_TERM_TOT", "Term Credits"}
        }
    ),
    ReplacePellVal = Table.ReplaceValue(
        RenameForReadability, "Y", "PellElig", Replacer.ReplaceValue, {"Pell Eligibility"}
    ),
    ReplaceNotPellVal = Table.ReplaceValue(
        ReplacePellVal, null, "Not PellElig", Replacer.ReplaceValue, {"Pell Eligibility"}
    ),
    ReplaceOSval = Table.ReplaceValue(ReplaceNotPellVal, "OS", "Out of state", Replacer.ReplaceValue, {"Residency"}),
    ReplaceISval = Table.ReplaceValue(ReplaceOSval, "IS", "In state", Replacer.ReplaceValue, {"Residency"}),
    ReplaceUval = Table.ReplaceValue(ReplaceISval, "U", "Unknown", Replacer.ReplaceValue, {"Sex"}),
    ReplaceFemVal = Table.ReplaceValue(ReplaceUval, "F", "Female", Replacer.ReplaceValue, {"Sex"}),
    ReplaceMaleVal = Table.ReplaceValue(ReplaceFemVal, "M", "Male", Replacer.ReplaceValue, {"Sex"}),
    RemoveLegacyCols = Table.RemoveColumns(
        ReplaceMaleVal, {"VX_HIGHEST_EDU_1", "VX_HIGHEST_EDU", "MILITARY_STATUS", "ADMIT_TYPE", "COUNTY", "Degree"}
    ),
    // Bring in the mapping table from datamart
    MappingTable = STATIC_IR_PLAN_RETENTION_PLAN_ASSOCIATION_join,
    // Join with mapping table on ACAD_PLAN
    JoinMapTbl = Table.NestedJoin(
        RemoveLegacyCols, {"ACAD_PLAN"}, MappingTable, {"ACAD_PLAN_OLD"}, "JoinTable", JoinKind.LeftOuter
    ),
    ExpandMapJoin = Table.ExpandTableColumn(
        JoinMapTbl, "JoinTable", {"ACAD_PLAN_NEW", "ACAD_PLAN_OLD"}, {"ACAD_PLAN_NEW", "ACAD_PLAN_OLD"}
    ),
    // Replace ACAD_PLAN with ACAD_PLAN_NEW where available, else keep the old value
    PlanSwitcheroo = Table.AddColumn(
        ExpandMapJoin, "ACAD_PLAN_Final", each if [ACAD_PLAN_NEW] = null then [ACAD_PLAN] else [ACAD_PLAN_NEW], type text
    ),
    // Remove intermediate columns and rename if needed
    RemovePlanCols = Table.RemoveColumns(PlanSwitcheroo, {"ACAD_PLAN", "ACAD_PLAN_NEW", "ACAD_PLAN_OLD"}),
    RenamePlanCol = Table.RenameColumns(RemovePlanCols, {{"ACAD_PLAN_Final", "ACAD_PLAN"}}),
    JoinPlanInfo = Table.NestedJoin(
        RenamePlanCol, {"ACAD_PLAN"}, IR_MAX_PLAN_DESCR_join, {"ACAD_PLAN"}, "IR_MAX_PLAN_DESCR_join",
        JoinKind.LeftOuter
    ),
    ExpandPlanInfo = Table.ExpandTableColumn(
        JoinPlanInfo, "IR_MAX_PLAN_DESCR_join", {"DESCR", "DEGREE"}, {"Academic Plan", "Degree"}
    ),
    //Replace Degree null values with "NonDeg"
    ReplaceNonDeg = Table.ReplaceValue(ExpandPlanInfo, null, "NonDeg", Replacer.ReplaceValue, {"Degree"}),
    //Calculate age at term start
    AddTermAge = Table.AddColumn(
        ReplaceNonDeg, "Term Age", each Date.Year([TERM_BEGIN_DT]) - Date.Year([Birthdate]), Int64.Type
    ),
    AcadPlanToText = Table.TransformColumnTypes(AddTermAge, {{"Academic Plan", type text}, {"Degree", type text}})
in
    AcadPlanToText
