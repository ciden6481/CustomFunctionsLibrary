let
    Source = IR_CLASS_GRADE_ROSTER,
    // Filter for valid STRM and F2 rows, remove extract column
    FilterSTRMandF2 = fnFilterValidSTRM(Source),
    RemoveUnusedCols = Table.RemoveColumns(
        FilterSTRMandF2,
        {
            "INSTITUTION",
            "ACAD_CAREER",
            "GRADE_ROSTER_STAT",
            "GRADING_SCHEME",
            "GRADING_BASIS_ENRL",
            "LAST_DATE_ATTENDED",
            "VX_IR_CLS_ATR_XOER"
        }
    ),
    AddClassKey = Table.AddColumn(
        RemoveUnusedCols,
        "class-key",
        each Text.Combine({[STRM], Text.From([CLASS_NBR]), [CLASS_SECTION], [SSR_COMPONENT]}, "-")
    ),
    SelectCols = Table.SelectColumns(AddClassKey, {"STRM", "CRSE_GRADE_INPUT", "STU_EMPLID", "class-key"}),
    RenameCols = Table.RenameColumns(SelectCols, {{"CRSE_GRADE_INPUT", "Course Grade"}, {"STU_EMPLID", "EMPLID"}}),
    AddStudentKey = Table.AddColumn(
        RenameCols,
        "strm-stu key",
        each Text.Combine({[STRM], [EMPLID]}, "-")
    )
in
    AddStudentKey
