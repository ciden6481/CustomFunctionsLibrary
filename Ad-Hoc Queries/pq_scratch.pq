let
    Source = IR_CLASS_MTG_DETAIL_VW,
    FilterSTRMandF2 = fnFilterValidSTRM(Source),
    RemoveUnusedCols = Table.SelectColumns(
        FilterSTRMandF2,
        {
            "ACAD_ORG",
            "CAMPUS",
            "CATALOG_NBR",
            "CLASS_NBR",
            "CLASS_SECTION",
            "CRSE_ID",
            "DESCR",
            "EMPLID",
            "ENRL_TOT",
            //"FACILITY_TYPE",
            "FIRST",
            "INSTRUCTION_MODE",
            "LAST",
            "LOCATION",
            "SSR_COMPONENT",
            "STRM",
            "INSTR_ROLE",
            "SUBJECT",
            "UNITS_MINIMUM",
            "VCCS_EMAIL",
            "VX_IR_CLS_ATR_XDUL",
            "VX_IR_CLS_VAL_DED",
            "VX_IR_CLS_VAL_DLM"
        }
    ),
    //Deduplicate table, but only after removing unused columns to avoid missing duplicates that only differ by the removed columns
    Deduplicate = Table.Distinct(RemoveUnusedCols),
    AddClassKey = Table.AddColumn(
        Deduplicate,
        "class-key",
        each Text.Combine({[STRM], Text.From([CLASS_NBR]), [CLASS_SECTION], [SSR_COMPONENT]}, "-"),
        type text
    ),
    RenameCols = Table.RenameColumns(
        AddClassKey,
        {
            {"DESCR", "Class Description"},
            {"LOCATION", "Class Location"},
            {"CAMPUS", "Class Campus"},
            {"INSTRUCTION_MODE", "Class Instruction Mode"},
            {"SSR_COMPONENT", "Class Component Type"},
            {"CRSE_ID", "Course ID"},
            {"SUBJECT", "Subject"},
            {"CLASS_NBR", "Class Number"},
            {"CATALOG_NBR", "Catalog Number"},
            {"CLASS_SECTION", "Class Section"},
            {"ENRL_TOT", "Enrl Total"},
            {"UNITS_MINIMUM", "Class Credits"},
            {"ACAD_ORG", "AcadOrg"},
            {"FIRST", "Instructor First Name"},
            {"LAST", "Instructor Last Name"},
            {"VCCS_EMAIL", "Instructor Email"},
            {"VX_IR_CLS_VAL_DLM", "Class Delivery Mode"}
        }
    ),
    // Group by class-key, and then filter to PI or, if no PI, keep all. This prevents missing classe info in the fact table.
    GroupByClass = Table.Group(
        RenameCols,
        {"class-key"},
        {
            {
                "All",
                each _,
                type table [
                    AcadOrg = nullable text,
                    Class Campus = nullable text,
                    Catalog Number = text,
                    Class Number = number,
                    Class Section = text,
                    Course ID = nullable text,
                    Class Description = nullable text,
                    EMPLID = nullable text,
                    Enrl Total = nullable number,
                    Instructor First Name = nullable text,
                    Class Instruction Mode = nullable text,
                    Instructor Last Name = nullable text,
                    Class Location = nullable text,
                    Class Component Type = nullable text,
                    STRM = text,
                    INSTR_ROLE = nullable text,
                    Subject = text,
                    Class Credits = nullable number,
                    Instructor Email = nullable text,
                    VX_IR_CLS_ATR_XDUL = nullable text,
                    VX_IR_CLS_VAL_DED = nullable text,
                    Class Delivery Mode = nullable text,
                    #"class-key" = text
                ]
            }
        }
    ),
    FilterPIorAll = (tbl as table) as table =>
        let
            piRows = Table.SelectRows(tbl, each [INSTR_ROLE] = "PI"),
            result = if Table.RowCount(piRows) > 0 then piRows else tbl
        in
            result,
    ApplyFilter = Table.TransformColumns(GroupByClass, {{"All", each FilterPIorAll(_), type table}}),
    ExpandRows = Table.ExpandTableColumn(
        ApplyFilter,
        "All",
        {
            "AcadOrg",
            "Class Campus",
            "Catalog Number",
            "Class Number",
            "Class Section",
            "Course ID",
            "Class Description",
            "EMPLID",
            "Enrl Total",
            "Instructor First Name",
            "Class Instruction Mode",
            "Instructor Last Name",
            "Class Location",
            "Class Component Type",
            "STRM",
            "INSTR_ROLE",
            "Subject",
            "Class Credits",
            "Instructor Email",
            "VX_IR_CLS_ATR_XDUL",
            "VX_IR_CLS_VAL_DED",
            "Class Delivery Mode"
        },
        {
            "AcadOrg",
            "Class Campus",
            "Catalog Number",
            "Class Number",
            "Class Section",
            "Course ID",
            "Class Description",
            "EMPLID",
            "Enrl Total",
            "Instructor First Name",
            "Class Instruction Mode",
            "Instructor Last Name",
            "Class Location",
            "Class Component Type",
            "STRM",
            "INSTR_ROLE",
            "Subject",
            "Class Credits",
            "Instructor Email",
            "VX_IR_CLS_ATR_XDUL",
            "VX_IR_CLS_VAL_DED",
            "Class Delivery Mode"
        }
    )
in
    ExpandRows
