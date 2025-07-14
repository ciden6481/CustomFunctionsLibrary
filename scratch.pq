let
    Source = IR_STUDENT,
    #"Removed Columns" = Table.RemoveColumns(
        Source,
        {
            "INSTITUTION",
            "ACAD_CAREER",
            "RUNDATE",
            "NATIONAL_ID",
            "DRIVERS_LIC_NBR",
            "VX_IR_DR_LIC_STATE",
            "VX_IR_VA_COLLG_ID",
            "VX_IR_VA_ST_TST_ID",
            "ACAD_PROG",
            "VX_IR_FA_ACAD_PLAN",
            "VX_IR_INIT_PROG",
            "FIRST_NAME",
            "LAST_NAME",
            "MIDDLE_NAME",
            "NAME_SUFFIX",
            "ADDRESS1",
            "ADDRESS2",
            "CITY",
            "STATE",
            "POSTAL",
            "EXT_ORG_ID",
            "STATE2",
            "ATP_CD",
            "EXT_GPA",
            "ACAD_LEVEL_BOT",
            "BIRTHCOUNTRY",
            // "FICE_CD",
            "VX_IR_CITZEN_CNTRY",
            "TUITION_RES",
            "TUITION_EXCPT",
            "ETHNIC_GRP_CD",
            "HISP_LATINO",
            "VX_HIGHEST_EDU",
            "VX_HIGHEST_EDU_1",
            "VC_JURIS_CODE",
            "FERPA",
            "TERM_BEGIN_DT",
            "TERM_END_DT",
            "CENSUS_DT",
            "VX_IR_TKN_GPA_ST",
            "VX_IR_CUM_GPA_ST",
            "VX_IR_CUM_ATMTP_ST",
            "VX_IR_CUM_ERN_ST",
            "FA_LOAD",
            //"FA_STATUS_CODE_14",
            //"VX_FA_ACTIVITY",
            "VX_PROGPLAN_ISSUES",
            "VX_IR_GREAT_EXP",
            "VX_IR_XSSC",
            "ADMIT_TERM",
            "CIP_CODE",
            "STDNT_CAR_NBR"
        }
    ),
    #"Filtered Rows" = Table.SelectRows(#"Removed Columns", each ([VX_IR_EXTRACT_TYPE] = "F2")),
    #"Added Custom" = Table.AddColumn(#"Filtered Rows", "strm-stud key", each [STRM] & "-" & [EMPLID]),
    #"Removed Duplicates" = Table.Distinct(#"Added Custom", {"strm-stud key"}),
    #"Added Conditional Column" = Table.AddColumn(
        #"Removed Duplicates",
        "Term DE",
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
    #"Removed Columns1" = Table.RemoveColumns(#"Added Conditional Column", {"VX_XDUL_ATTRIBUTE"}),
    race_recode = Table.AddColumn(
        #"Removed Columns1",
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
    DeterminePriorStudent = Table.AddColumn(
        race_recode,
        "Prior Student",
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
                2
            else if
                [VX_IR_PRIOR_STDNT] = "N"
                and (
                    List.Contains({"TR", "TEF", "TRN", "ITF"}, [ADMIT_TYPE])
                    or [VX_IR_PREV_DEGREE] <> null
                    or [FICE_CD] <> null
                )
            then
                3
            else
                1
    ),
    DeterminePriorStudent2 = Table.AddColumn(
        DeterminePriorStudent,
        "Prior Student2",
        each
            if [ADMIT_TYPE] = "ITF" or ([FICE_CD] <> "008569" or [FICE_CD] <> null) or [VX_IR_PREV_DEGREE] <> null
            then
                3
            else if [VX_IR_PRIOR_STDNT] = "Y" then
                2
            else
                1
    ),
    DetermineNRA = Table.AddColumn(
        DeterminePriorStudent2, "NRA", each if [CITIZENSHIP_STATUS] = "4" and [VISA_PERMIT_TYPE] <> "PR" then 1 else 0
    ),
    JoinWithPellEligibility = Table.NestedJoin(
        DetermineNRA, "strm-stud key", PellEligibility, "strm-stud key", "PellEligibility"
    )
in
    JoinWithPellEligibility
