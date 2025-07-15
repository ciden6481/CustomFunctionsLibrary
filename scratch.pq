let
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    IR_STUDENT = Source{[Schema = "dbo", Item = "IR_STUDENT"]}[Data],
    InitialColumns = Table.SelectColumns(
        IR_STUDENT,
        {
            "STRM",
            "EMPLID",
            "FIRST_NAME",
            "LAST_NAME",
            "MIDDLE_NAME",
            "NAME_SUFFIX",
            "SEX",
            "COUNTY",
            "ADDRESS1",
            "ADDRESS2",
            "CITY",
            "STATE",
            "POSTAL",
            "VX_IR_HS_GRAD_YR",
            "BIRTHDATE",
            "ACAD_PLAN",
            "VX_IR_ETHNIC_1",
            "VX_IR_ETHNIC_2",
            "VX_IR_ETHNIC_3",
            "VX_IR_ETHNIC_4",
            "VX_IR_ETHNIC_5",
            "VX_IR_ETHNIC_6",
            "VX_IR_ETHNIC_7",
            "VX_XDUL_ATTRIBUTE",
            "VX_IR_EXTRACT_TYPE",
            "RUNDATE"
        }
    ),
    FilterF2Rows = Table.SelectRows(InitialColumns, each [VX_IR_EXTRACT_TYPE] = "F2"),
    RemoveExtractType = Table.RemoveColumns(FilterF2Rows, {"VX_IR_EXTRACT_TYPE"}),
AddRaceColumn = Table.AddColumn(
    RemoveExtractType,
    "Race",
    each
        if [VX_IR_ETHNIC_1] = "1" then "American Indian or Alaska Native"
        else if [VX_IR_ETHNIC_2] = "1" then "Asian"
        else if [VX_IR_ETHNIC_3] = "1" then "Black or African American"
        else if [VX_IR_ETHNIC_4] = "1" then "Hispanic or Latino"
        else if [VX_IR_ETHNIC_5] = "1" then "Native Hawaiian or Other Pacific Islander"
        else if [VX_IR_ETHNIC_6] = "1" then "White"
        else if [VX_IR_ETHNIC_7] = "1" then "Two or More Races"
        else "Unknown"
),
RemoveVX_IR_ETHNICcolumns = Table.RemoveColumns(
    AddRaceColumn,
    {
        "VX_IR_ETHNIC_1",
        "VX_IR_ETHNIC_2",
        "VX_IR_ETHNIC_3",
        "VX_IR_ETHNIC_4",
        "VX_IR_ETHNIC_5",
        "VX_IR_ETHNIC_6",
        "VX_IR_ETHNIC_7"
    }
)
in
    RemoveVX_IR_ETHNICcolumns
