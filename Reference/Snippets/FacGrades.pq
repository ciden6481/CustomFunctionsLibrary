//FacGrades contains rows for each term-class-student with foreign keys strm-stu and strm-cls to DimStudent and DimClass respectively.
let
    //Start with IR_CLASS_GRADE_ROSTER table and isolate class and student identifiers and grade column
    Source = IR_CLASS_GRADE_ROSTER,
    RemoveUnnecessaryColumns = Table.RemoveColumns(
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
            "VX_IR_DAY_EVE_CLS"
        }
    ),
    //Null EMPLIDs can happen due to data entry errors
    RemoveNullEMPLID = Table.SelectRows(RemoveUnnecessaryColumns, each ([STU_EMPLID] <> null)),
    // Add unique value for each for term-student, will serve as foreign key to DimStudent
    AddStrmStu = Table.AddColumn(RemoveNullEMPLID, "strm-stu key", each [STRM] & "-" & [STU_EMPLID], type text),
    //CLASS_NBR is imported ast type number, must be converted to concat later
    ChangeClsNbrToText = Table.TransformColumnTypes(AddStrmStu, {{"CLASS_NBR", type text}}),
    // Unique key for class by term, will serve as foreign key to DimClass
    AddStrmCls = Table.AddColumn(ChangeClsNbrToText, "strm-cls key", each [STRM] & "-" & [CLASS_NBR], type text),
    //Filtering incompletes & audits
    FilterGradeColumn = Table.SelectRows(
        AddStrmCls, each ([CRSE_GRADE_INPUT] <> "I" and [CRSE_GRADE_INPUT] <> "R" and [CRSE_GRADE_INPUT] <> "X")
    ),
    RenameColumns = Table.RenameColumns(
        FilterGradeColumn, {{"CRSE_GRADE_INPUT", "Course Grade"}, {"STU_EMPLID", "EMPLID"}}
    ),
    //Primary key, unique value for strm-class-student
    AddStrmStuClsKey = Table.AddColumn(RenameColumns, "strm-cls-stu key", each [#"strm-cls key"] & "-" & [EMPLID])
in
    AddStrmStuClsKey
