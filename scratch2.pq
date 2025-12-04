let
    Source = fnAlphaSortCols(Staged_StudentEnrollmentTables),
    //Replace all blank values with nulls for easier handling
    BlankToNull = Table.ReplaceValue(Source, "", null, Replacer.ReplaceValue, Table.ColumnNames(Source)),
    TypedColumns = Table.TransformColumnTypes(
        BlankToNull,
        {
            {"zip", type text},
            {"visa", type text},
            {"residency", type text},
            {"parent_campus_a", type text},
            {"mhe", type text},
            {"juris", type text},
            {"gender", type text},
            {"fp_code", type text},
            {"fhe", type text},
            {"fa_activity", type text},
            {"emplid", type text},
            {"college_last_attended", type text},
            {"cip", type text},
            {"ceeb", type text},
            {"ay", type text},
            {"acadplan", type text},
            {"birth_date", type date},
            {"age", Int32.Type},
            {"annual_student_credits", Int32.Type},
            {"hs_grad_year", Int32.Type},
            {"citz_status", type text},
            {"new_race", Int32.Type},
            {"status", Int32.Type},
            {"student_success", type text},
            {"mil_status", type text},
            {"prev_degree", type text}
        }
    ),
    // Hidden columns are CamelCase and visible columns are Sentence Case;
    // Boolean columns prefixed with "Is", "In", etc.;
    // Dimension code lookup columns have suffix "Code"
    RenamedColumns = Table.RenameColumns(
        TypedColumns,
        {
            {"ay", "Academic-Year"},
            {"age", "Student Age"},
            {"annual_student_credits", "Student Credits"},
            {"birth_date", "Student Birthdate"},
            {"ceeb", "HSCEEBCode"},
            {"cip", "CIPCode"},
            {"citz_status", "CitizenshipStatusCode"},
            {"college_last_attended", "PreviousCollegeFICECode"},
            {"deflag", "IsDE"},
            {"emplid", "Student EMPLID"},
            {"fa_activity", "IsFAActivity"},
            {"fhe", "FHECode"},
            {"fp_code", "FPCode"},
            {"gender", "Student Gender"},
            {"great_exp", "IsGreatExp"},
            {"hs_grad_year", "Student HS Graduation Year"},
            {"juris", "JURISCode"},
            {"mhe", "MHECode"},
            {"mil_status", "MilStatusCode"},
            {"new_race", "RaceCode"},
            {"parent_campus_a", "ParentCampusCode"},
            {"residency", "ResidenceCode"},
            {"status", "FTICCode"},
            {"student_success", "IsStudentSuccess"},
            {"visa", "VisaCode"},
            {"xdul", "IsXDUL"},
            {"zip", "Zip"},
            {"r_amind_alsk", "RaceIsAmIndAlsk"},
            {"r_asian", "RaceIsAsian"},
            {"r_black", "RaceIsBlack"},
            {"r_hawpac", "RaceIsHawPac"},
            {"r_hisp", "RaceIsHisp"},
            {"r_nspec", "RaceIsNspec"},
            {"r_white", "RaceIsWhite"},
            {"prev_degree", "PreviousDegreeTypeCode"}
        }
    ),
    // Create two academic plan columns, the updated one translates programs that have been converted or changed to reflect the new plan code
    AddUpdatedAcadPlan = fnAddUpdatedPlanCol(RenamedColumns, "acadplan"),
    //Uniquer per row, created to enable merge with Grads table
    AddStudYrID = Table.AddColumn(
        AddUpdatedAcadPlan, "StudentYearID", each [Student EMPLID] & "-" & [#"Academic-Year"], type text
    ),
    AddHyphen = Table.TransformColumns(AddStudYrID, {{"Academic-Year", each Text.Insert(_, 4, "-"), type text}}),
    //Change race values from Y/N to 1/0 and type integer for improved model efficiency
    YColsToLogical = Table.TransformColumns(
        AddHyphen,
        List.Transform(
            {
                "RaceIsAmIndAlsk",
                "RaceIsAsian",
                "RaceIsBlack",
                "RaceIsHawPac",
                "RaceIsHisp",
                "RaceIsNspec",
                "RaceIsWhite",
                "IsGreatExp",
                "IsFAActivity",
                "IsStudentSuccess",
                "IsDE",
                "IsXDUL"
            },
            each {_, each if (_ = "Y") or (_ = "1") then 1 else 2, type number}
        )
    ),
    //based on VCCS definition, different from federal
    Add1stGen = Table.AddColumn(
        YColsToLogical,
        "Is1stGen",
        each
            if
                ([MHECode] = "BLHS" or [MHECode] = "DGHS" or [MHECode] = "CAHS" or [MHECode] = "UNKN")
                and ([FHECode] = "BLHS" or [FHECode] = "DGHS" or [FHECode] = "CAHS" or [FHECode] = "UNKN")
            then
                true
            else
                false,
        type logical
    ),
    //Maps to DimParentCampus
    ReplaceParentCampusVals = Table.TransformColumns(
        Add1stGen, {{"ParentCampusCode", each if _ = "A" then 1 else if _ = "B" then 2 else if _ = "Z" then 3 else 0,
        Int32.Type}}
    ),
    //Maps to DimResidence
    ReplaceResidenceVals = Table.TransformColumns(
        ReplaceParentCampusVals, {{"ResidenceCode", each if _ = "IS" then 1 else if _ = "OS" then 2 else 0,
        Int32.Type}}
    ),
    //Maps to DimGender
    ReplaceGenderVals = Table.TransformColumns(
        ReplaceResidenceVals, {{"Student Gender", each if _ = "F" then 1 else if _ = "M" then 2 else 0, Int32.Type}}
    ),
    ReplaceNullMilStatus = Table.ReplaceValue(ReplaceGenderVals, null, "1", Replacer.ReplaceValue, {"MilStatusCode"})
in
    ReplaceNullMilStatus
