//InputTable is name of previous step, ColumnName is name of column to be created
let
    RecodeRace = (InputTable as table, ColumnName as text) as table =>
    Table.AddColumn(
        InputTable,
        
        ColumnName,
        each
        if [VX_IR_ETHNIC_3] = "Y" then
            "Hispanic"
        else if 
            List.Count(
                List.Select(
                    {
                        [VX_IR_ETHNIC_1], [VX_IR_ETHNIC_2], [VX_IR_ETHNIC_4],
                        [VX_IR_ETHNIC_5], [VX_IR_ETHNIC_6], [VX_IR_ETHNIC_7]
                    }, each _ = "Y"
                )
            ) > 1 then
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
        else if [VX_IR_ETHNIC_6] = "Y" then
            "Not Specified"
        else
            "Unknown",
    type text
)
in
 
    RecodeRace
