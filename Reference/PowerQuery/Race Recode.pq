//InputTable is name of previous step, ColumnName is name of column to be created
let
    RecodeRace = (InputTable as table, ColumnName as text) as table =>
    Let
    Recode = Table.AddColumn(
        InputTable,
        
        ColumnName,
        each
            if [VX_IR_ETHNIC_3] = "Y" then
                "Hispanic"
            else if
                [VX_IR_ETHNIC_1] = "N"
                and [VX_IR_ETHNIC_2] = "N"
                and [VX_IR_ETHNIC_3] = "N"
                and [VX_IR_ETHNIC_4] = "N"
                and [VX_IR_ETHNIC_5] = "N"
                and [VX_IR_ETHNIC_7] = "N"
            then
                "Unknown"
            else if [VX_IR_ETHNIC_6] = "Y" then
                "Not Specified"
            else if
                ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_4] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_7] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_5] = "Y")
                or ([VX_IR_ETHNIC_1] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_7] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_5] = "Y")
                or ([VX_IR_ETHNIC_4] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_7] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_7] = "Y" and [VX_IR_ETHNIC_5] = "Y")
                or ([VX_IR_ETHNIC_7] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_5] = "Y" and [VX_IR_ETHNIC_2] = "Y")
                or ([VX_IR_ETHNIC_2] = "Y" and [VX_IR_ETHNIC_6] = "Y")
                or ([VX_IR_ETHNIC_5] = "Y" and [VX_IR_ETHNIC_6] = "Y")
            then
                "Two or more"
            else if [VX_IR_ETHNIC_1] = "Y" then
                "White"
            else if [VX_IR_ETHNIC_2] = "Y" then
                "Black/African American"
            else if [VX_IR_ETHNIC_4] = "Y" then
                "Asian"
            else if [VX_IR_ETHNIC_5] = "Y" then
                "American Indian/Alaskan Native"
            else if [VX_IR_ETHNIC_7] = "Y" then
                "Native Hawaiian/Pacific Islander"
            else
                "Unknown"
    )
in
    Recode
    in
    RecodeRace
