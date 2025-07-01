let
    Source = Oracle.Database("s92qery"),
    tableFetch = Source{[Schema = "SYSADM", Item = "PS_CLASS_TBL_SE_VW"]}[Data],
    FilterLF298 = Table.SelectRows(tableFetch, each [INSTITUTION] = "LF298"),
    RemoveUnusedCols = Table.SelectColumns(
        FilterLF298,
        {
            "EMPLID",
            "STRM",
            "CLASS_NBR",
            "GRADING_BASIS_ENRL",
            "STDNT_ENRL_STATUS",
            "CRSE_ID",
            "ENRL_STATUS_REASON",
            "CRSE_GRADE_INPUT",
            "CRSE_GRADE_OFF",
            "EARN_CREDIT",
            "INCLUDE_IN_GPA"
        }
    ),
    // Get buffered list of valid STRM values
    ValidSTRM = fx_GetValidSTRMList(),
    // Apply STRM + ExtractType filter inline (preserves folding)
    FilteredTable = Table.SelectRows(RemoveUnusedCols, each [STRM] <> null and List.Contains(ValidSTRM, [STRM])),
    //FIlter out non-enrolled students, non-graded courses, and incomplete/audit/withdraw grades
    FilterGrades = Table.SelectRows(
        FilteredTable,
        each
            ([GRADING_BASIS_ENRL] <> "NON")
            and ([STDNT_ENRL_STATUS] = "E")
            and ([CRSE_GRADE_INPUT] <> "R" and [CRSE_GRADE_INPUT] <> "X" and [CRSE_GRADE_INPUT] <> "I")
    ),
    // Unique key for class by term, will serve as foreign key to DimClass
    AddStrmCls = Table.AddColumn(FilterGrades, "strm-cls key", each [STRM] & "-" & Text.From([CLASS_NBR]), type text),
    // Add unique value for each for term-student, will serve as foreign key to DimStudent
    AddStrmStu = Table.AddColumn(AddStrmCls, "strm-stu key", each [STRM] & "-" & [EMPLID], type text)
in
    AddStrmStu
