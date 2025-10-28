let
    Source = fnAlphaSortCols(#"Staged_StudentTables"),
    RemovedCols = Table.RemoveColumns(
        Source,
        {
            "year",
            "File Name",
            "college",
            "collnum",
            "ctg",
            "dayeve",
            "ekey",
            "hsgpa",
            "nra_schev",
            "ovcountry",
            "prev_degree",
            "program_level",
            "institution",
            "ps_juris",
            "qtr_head_code",
            "quarter_code",
            "race",
            "skey",
            "ssno",
            "tuition_exception",
            "tuition_residency",
            "vcsin",
            "visa_schev",
            "acad_level_bot",
            "admit_term",
            "strm"
        }
    ),
    BlankToNull = Table.ReplaceValue(RemovedCols, "", null, Replacer.ReplaceValue, Table.ColumnNames(RemovedCols)),
    TypedColumns = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"zip", type text},
            {"visa", type text},
            {"r_white", type text},
            {"r_nspec", type text},
            {"r_hisp", type text},
            {"r_hawpac", type text},
            {"r_black", type text},
            {"r_asian", type text},
            {"r_amind_alsk", type text},
            {"residency", type text},
            {"parent_campus_a", type text},
            {"mname", type text},
            {"mhe", type text},
            {"lname", type text},
            {"juris", type text},
            {"home_campus", type text},
            {"hisp_fl", type text},
            {"gender", type text},
            {"fp_code", type text},
            {"fname", type text},
            {"fhe", type text},
            {"ferpa", type text},
            {"fa_activity", type text},
            {"emplid", type text},
            {"curr", type text},
            {"college_last_attended", type text},
            {"citiz", type text},
            {"cip", type text},
            {"ceeb", type text},
            {"ay", type text},
            {"acadplan", type text},
            {"birth_date", type date},
            {"age", type number},
            {"annual_student_credits", type number},
            {"great_exp", type text},
            {"hs_grad_year", type number},
            {"citz_status", type text},
            {"deflag", type number},
            {"mil_status", type text},
            {"new_race", type number},
            {"status", type number},
            {"xdul", type text},
            {"student_success", type text}
        }
    ),
    // Create two academic plan columns, the updated one translates programs that have been converted or changed to reflect the new plan code
    AddUpdatedAcadPlan = fnAddUpdatedPlanCol(TypedColumns, "acadplan"),
    AddKeyCol = Table.AddColumn(AddUpdatedAcadPlan, "StudentYear", each [emplid] & "-" & [ay], type text),
    AddHyphen = Table.TransformColumns(AddKeyCol, {{"ay", each Text.Insert(_, 4, "-"), type text}}),
    RenamedColumns = Table.RenameColumns(
        AddHyphen,
        {
            {"ay", "AcademicYear"},
            {"age", "Age"},
            {"annual_student_credits", "Student Credits"},
            {"birth_date", "Birth Date"},
            {"ceeb", "CEEBCode"},
            {"cip", "CIPCode"},
            {"citiz", "Citizenship"},
            {"citz_status", "CitizStatusCode"},
            {"college_last_attended", "CollgLastAttCode"},
            {"curr", "CurrCode"},
            {"deflag", "DEFlag"},
            {"emplid", "EMPLID"},
            {"fa_activity", "FAActivityFlag"},
            {"ferpa", "FERPACode"},
            {"fhe", "FHECode"},
            {"fname", "FirstName"},
            {"fp_code", "FPCode"},
            {"gender", "Gender"},
            {"great_exp", "GreatExpFlag"},
            {"hisp_fl", "HispFlag"},
            {"home_campus", "Home Campus"},
            {"hs_grad_year", "HS Graduation Year"},
            {"juris", "JurisCode"},
            {"lname", "LastName"},
            {"mhe", "MHECode"},
            {"mil_status", "MilStatusCode"},
            {"mname", "MiddleName"},
            {"new_race", "NewRaceCode"},
            {"parent_campus_a", "Parent Campus"},
            {"residency", "Residency"},
            {"status", "StatusCode"},
            {"student_success", "StudSuccessFlag"},
            {"visa", "VisaCode"},
            {"xdul", "XDULFlag"},
            {"zip", "Zip"}
        }
    ),
    Custom1 = Table.AddColumn(
        RenamedColumns,
        "First Gen",
        each
            if ([MHECode] = "BLHS" or [MHECode] = "DGHS") and ([FHECode] = "BLHS" or [FHECode] = "DGHS") then
                1
            else if ([MHECode] = "BLHS" or [MHECode] = "DGHS") and ([FHECode] = "UNKNOWN" or [FHECode] = "ADNK") then
                1
            else if ([FHECode] = "BLHS" or [FHECode] = "DGHS") and ([MHECode] = "UNKNOWN" or [MHECode] = "ADNK") then
                1
            else if [MHECode] = "UNKNOWN" and [FHECode] = "UNKNOWN" then
                1
            else
                0,
        type number
    )
in
    Custom1
