let
    Source = fnAlphaSortCols(#"Staged_WDSEnrollmentTables"),
    RemovedColumns = Table.RemoveColumns(Source, {"File Name", "institution", "acad_career", "ssno"}),
    EmptyToNull = Table.ReplaceValue(
        RemovedColumns, "", null, Replacer.ReplaceValue, Table.ColumnNames(RemovedColumns)
    ),
    FormatBirthdates = Table.TransformColumns(
        EmptyToNull,
        {
            {
                "birthdate",
                each
                    try
                        if _ = null then
                            null
                        else if Text.Contains(_, "/") then
                            Date.From(_)
                        else
                            Date.From(Text.Insert(Text.Insert(_, 2, "/"), 5, "/"))
                        otherwise null,
                type date
            }
        }
    ),
    TypeColumns = Table.TransformColumnTypes(
        FormatBirthdates,
        {
            {"end_dt", type date},
            {"start_dt", type date},
            {"count", type number},
            {"complete_cnt", type number},
            {"contact_hours", type number},
            {"min_hrs", type number},
            {"ff", type number},
            {"wcg", type number},
            {"urp_race", type number},
            {"urp_loc", type number},
            {"urp", type number},
            {"limited", type number}
        }
    ),
    FilterFF = Table.SelectRows(TypeColumns, each ([wcg] = 1) or ([ff] = 1)),
    RenamedColumns = Table.RenameColumns(
        FilterFF,
        {
            {"address1", "Address"},
            {"birthdate", "Birthdate"},
            {"catalog_nbr", "Catalog Number"},
            {"city", "City"},
            {"class_nbr", "Class Number"},
            {"class_section", "Class Section"},
            {"complete_cnt", "Complete Count"},
            {"contact_hours", "Contact Hours"},
            {"count", "County"},
            {"crse_attr", "Course Attr"},
            {"crse_attr_value", "Course Attr Value"},
            {"crse_id", "Course ID"},
            {"descr", "Class Description"},
            {"end_dt", "Class End Date"},
            {"ff", "FF"},
            {"first name", "First Name"},
            {"grade", "Grade"},
            {"instruct_mode", "Instruction Mode"},
            {"last_name", "Last Name"},
            {"limited", "Limited"},
            {"location", "Location"},
            {"middle_name", "Middle Name"},
            {"min_hrs", "Min Hours"},
            {"race", "Race"},
            {"sex", "Sex"},
            {"start_dt", "Class Start Date"},
            {"state", "State"},
            {"subject", "Class Subject"},
            {"urp", "URP Flag"},
            {"urp_loc", "URP Location Flag"},
            {"urp_race", "URP Race Flag"},
            {"wcg", "WCG"},
            {"zip", "ZIP"},
            {"juris", "Juris Code"},
            {"emplid", "EMPLID"}
        }
    )
in
    RenamedColumns
