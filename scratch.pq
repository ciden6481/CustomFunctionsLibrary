let
    // ▓▓▓ Parameters ▓▓▓
    // Filter value for VX_IR_EXTRACT_TYPE
    ExtractTypeFilter = "F2",
    // ▓▓▓ Native SQL Source with Race Classification (Staging Layer) ▓▓▓
    SqlConnection = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    StudentSource = Value.NativeQuery(
        SqlConnection,
        "
        SELECT 
            STRM,
            EMPLID,
            FIRST_NAME,
            LAST_NAME,
            MIDDLE_NAME,
            NAME_SUFFIX,
            SEX,
            COUNTY,
            ADDRESS1,
            ADDRESS2,
            CITY,
            STATE,
            POSTAL,
            VX_IR_HS_GRAD_YR,
            BIRTHDATE,
            ACAD_PLAN,
            VX_IR_ETHNIC_1,
            VX_IR_ETHNIC_2,
            VX_IR_ETHNIC_3,
            VX_IR_ETHNIC_4,
            VX_IR_ETHNIC_5,
            VX_IR_ETHNIC_6,
            VX_IR_ETHNIC_7,
            VX_XDUL_ATTRIBUTE,
            RUNDATE,
            ATP_CD,
            CASE
                WHEN VX_IR_ETHNIC_3 = 'Y' THEN 'Hispanic'
                WHEN 
                    (CASE WHEN VX_IR_ETHNIC_1 = 'Y' THEN 1 ELSE 0 END +
                     CASE WHEN VX_IR_ETHNIC_2 = 'Y' THEN 1 ELSE 0 END +
                     CASE WHEN VX_IR_ETHNIC_4 = 'Y' THEN 1 ELSE 0 END +
                     CASE WHEN VX_IR_ETHNIC_5 = 'Y' THEN 1 ELSE 0 END +
                     CASE WHEN VX_IR_ETHNIC_6 = 'Y' THEN 1 ELSE 0 END +
                     CASE WHEN VX_IR_ETHNIC_7 = 'Y' THEN 1 ELSE 0 END) > 1
                THEN 'Two or more'
                WHEN VX_IR_ETHNIC_1 = 'Y' THEN 'White'
                WHEN VX_IR_ETHNIC_2 = 'Y' THEN 'Black/African American'
                WHEN VX_IR_ETHNIC_4 = 'Y' THEN 'Asian'
                WHEN VX_IR_ETHNIC_5 = 'Y' THEN 'American Indian/Alaskan Native'
                WHEN VX_IR_ETHNIC_7 = 'Y' THEN 'Native Hawaiian/Pacific Islander'
                WHEN VX_IR_ETHNIC_6 = 'Y' THEN 'Not Specified'
                ELSE 'Unknown'
            END AS Race
        FROM dbo.IR_STUDENT
        WHERE VX_IR_EXTRACT_TYPE = '"
            & ExtractTypeFilter
            & "'
        ",
        null,
        [
            EnableFolding = true
        ]
    ),
    // Column Cleanup and Derived Flags
    RenamedColumns = Table.RenameColumns(
        StudentSource,
        {
            {"FIRST_NAME", "First Name"},
            {"LAST_NAME", "Last Name"},
            {"MIDDLE_NAME", "Middle Name"},
            {"NAME_SUFFIX", "Name Suffix"},
            {"SEX", "Sex"},
            {"COUNTY", "County"},
            {"ADDRESS1", "Address 1"},
            {"ADDRESS2", "Address 2"},
            {"CITY", "City"},
            {"STATE", "State"},
            {"POSTAL", "Postal"},
            {"VX_IR_HS_GRAD_YR", "HS Grad Year"},
            {"BIRTHDATE", "Birthdate"}
        }
    ),
    AddDualEnrollmentFlag = Table.AddColumn(
        RenamedColumns,
        "TermDE",
        each if List.Contains({"041", "042", "043"}, [ACAD_PLAN]) or [VX_XDUL_ATTRIBUTE] = "Y" then 1 else 0,
        Int64.Type
    ),
    RemoveUnusedColumns = Table.RemoveColumns(
        AddDualEnrollmentFlag,
        {
            "ACAD_PLAN",
            "VX_XDUL_ATTRIBUTE",
            "VX_IR_ETHNIC_1",
            "VX_IR_ETHNIC_2",
            "VX_IR_ETHNIC_3",
            "VX_IR_ETHNIC_4",
            "VX_IR_ETHNIC_5",
            "VX_IR_ETHNIC_6",
            "VX_IR_ETHNIC_7"
        }
    ),
    // ▓▓▓ Student-Level Term Summary
    BaseTable = RemoveUnusedColumns
in
    BaseTable
