// Import IR_STUDENT table and perform transformations. Will be used to create DimStudent table.
let
    // Step 1: Get source table (foldable)
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    dbo_IR_STUDENT = Source{[Schema = "dbo", Item = "IR_STUDENT"]}[Data],
    // Step 2: Get buffered list of valid STRM values
    ValidSTRM = fx_GetValidSTRMList(),
    // Step 3: Apply STRM + ExtractType filter inline (preserves folding)
    FilteredTable = Table.SelectRows(
        dbo_IR_STUDENT, each [STRM] <> null and List.Contains(ValidSTRM, [STRM]) and [VX_IR_EXTRACT_TYPE] = "F2"
    ),
    // Step 4: Remove unnecessary columns
    RemoveUnnecessaryColumns = Table.RemoveColumns(
        FilteredTable,
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
            "DEGREE",
            "VX_IR_CITZEN_CNTRY",
            "TUITION_RES",
            "TUITION_EXCPT",
            "ETHNIC_GRP_CD",
            "HISP_LATINO",
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
            "VX_PROGPLAN_ISSUES",
            "VX_IR_GREAT_EXP",
            "VX_IR_XSSC",
            "ADMIT_TERM",
            "CIP_CODE",
            "STDNT_CAR_NBR",
            "VX_IR_LAST_COLLEGE",
            "VX_IR_LAST_COLL_NM",
            "VX_IR_LAST_COLL_ST",
            "UNT_TRNSFR",
            "FA_STATUS_CODE_14",
            "VX_FA_ACTIVITY",
            "CAMPUS"
        }
    ),
    // Step 5: Add surrogate key
    AddStrmStuKey = Table.AddColumn(RemoveUnnecessaryColumns, "strm-stu key", each [STRM] & "-" & [EMPLID], type text)
in
    AddStrmStuKey
