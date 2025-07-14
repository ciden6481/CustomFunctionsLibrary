//DimClass contains one row per term-class with details about each class
let
    //Start with IR_CLASS_GRADE_ROSTER table and isolate class information columns.
    //Includes strm-stu key which will be foreign key to DimStudent table
    Source = IR_CLASS_GRADE_ROSTER,
    RemoveUnnecessaryColumns = Table.RemoveColumns(Source, {"STU_EMPLID", "CRSE_GRADE_INPUT"}),
    //CLASS_NBR is imported ast type number, must be converted to concat later
    ChangeClsNbrToText = Table.TransformColumnTypes(RemoveUnnecessaryColumns, {{"CLASS_NBR", type text}}),
    // Primary key for class by term, necessary because class numbers are not unique and are recycled between terms.
    AddStrmClsKey = Table.AddColumn(ChangeClsNbrToText, "strm-cls key", each [STRM] & "-" & [CLASS_NBR], type text),
    DuduplicateStrmCls = Table.Distinct(AddStrmClsKey, {"strm-cls key"}),
    RenameColumns = Table.RenameColumns(
        DuduplicateStrmCls,
        {
            {"DESCR", "Course Descr"},
            {"LOCATION", "Class Location"},
            {"CAMPUS", "Class Campus"},
            {"INSTRUCTION_MODE", "Class Instruction Mode"},
            {"SSR_COMPONENT", "Class Component Type"},
            {"CRSE_ID", "Course ID"},
            {"SUBJECT", "Subject"},
            {"CLASS_NBR", "Class Number"},
            {"CATALOG_NBR", "Catalog Number"},
            {"CLASS_SECTION", "Class Section"},
            {"SESSION_CODE", "Session Code"},
            {"ENRL_TOT", "Enrl Total"},
            {"UNITS_MINIMUM", "Credits"},
            {"ACAD_ORG", "AcadOrg"},
            {"VX_IR_DAY_EVE_CLS", "Day/Evening Class"}
        }
    ),
    AddClassDeColumn = Table.AddColumn(
        RenameColumns,
        "Class DE",
        each if [AcadOrg] = "ICDUAL" then "DE" else if [VX_IR_CLS_ATR_XDUL] = "XDUL" then "DE" else "NonDE",
        type text
    ),
    //Concat text for easy identifier in PowerBI
    AddClassLabel = Table.AddColumn(
        AddClassDeColumn,
        "Class Label",
        each [Subject] & " " & [Catalog Number] & ": " & [Course Descr] & " (" & [Class Component Type] & ")",
        type text
    ),
    RemoveMoreUnnecessaryColumns = Table.RemoveColumns(AddClassLabel, {"VX_IR_CLS_ATR_XDUL"}),
    ReplaceDayValue = Table.ReplaceValue(
        RemoveMoreUnnecessaryColumns, "D", "Day", Replacer.ReplaceText, {"Day/Evening Class"}
    ),
    ReplaceEveningValue = Table.ReplaceValue(
        ReplaceDayValue, "E", "Evening", Replacer.ReplaceText, {"Day/Evening Class"}
    )
in
    ReplaceEveningValue
