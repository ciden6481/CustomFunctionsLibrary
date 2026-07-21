let
    Source = IR_CLASS_SE_VW,
    // Filter for valid STRM and F2 rows, remove extract column
    FilterSTRMandF2 = fnFilterValidSTRM(Source),
    #"Filtered Rows1" = Table.SelectRows(FilterSTRMandF2, each [STU_EMPLID] <> null and [STU_EMPLID] <> ""),
    RemoveUnusedCols = Table.RemoveColumns(
        #"Filtered Rows1",
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
    SelectCols = Table.SelectColumns(AddClassKey, {"CLASS_NBR","STRM", "CRSE_GRADE_INPUT", "STU_EMPLID", "class-key"}),
    RenameCols = Table.RenameColumns(SelectCols, {{"CRSE_GRADE_INPUT", "Course Grade"}, {"STU_EMPLID", "EMPLID"}}),
    AddStudentKey = Table.AddColumn(
        RenameCols,
        "strm-stu key",
        each Text.Combine({[STRM], [EMPLID]}, "-")
    ),
    #"Filtered Rows" = Table.SelectRows(AddStudentKey, each ([Course Grade] <> "R" and [Course Grade] <> "WC" and [Course Grade] <> "X")),
    #"Removed Duplicates" = Table.Distinct(#"Filtered Rows")
in
    #"Removed Duplicates"