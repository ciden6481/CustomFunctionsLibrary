let
    #"Renamed Columns1" = Table.RenameColumns(
        #"Added Conditional Column",
        {
            {"VX_IR_ETHNIC_1", "RaceWhite"},
            {"VX_IR_ETHNIC_2", "RaceBlack"},
            {"VX_IR_ETHNIC_3", "RaceHispanic"},
            {"VX_IR_ETHNIC_4", "RaceAsian"},
            {"VX_IR_ETHNIC_5", "RaceAmIndAk"},
            {"VX_IR_ETHNIC_6", "RaceUnsp"},
            {"VX_IR_ETHNIC_7", "RaceHawPAC"}
        }
    ),
    #"Replaced Value" = Table.ReplaceValue(
        #"Renamed Columns",
        "Y",
        "1",
        Replacer.ReplaceText,
        {"RaceWhite", "RaceBlack", "RaceHispanic", "RaceAsian", "RaceAmIndAk", "RaceUnsp", "RaceHawPAC"}
    ),
    #"Replaced Value1" = Table.ReplaceValue(
        #"Replaced Value",
        "N",
        "",
        Replacer.ReplaceText,
        {"RaceWhite", "RaceBlack", "RaceHispanic", "RaceAsian", "RaceAmIndAk", "RaceUnsp", "RaceHawPAC"}
    ),
    #"Changed Type" = Table.TransformColumnTypes(
        #"Replaced Value1",
        {
            {"RaceWhite", type number},
            {"RaceBlack", type number},
            {"RaceHispanic", type number},
            {"RaceAsian", type number},
            {"RaceAmIndAk", type number},
            {"RaceUnsp", type number},
            {"RaceHawPAC", type number}
        }
    ),
    #"Added Custom2" = Table.AddColumn(
        #"Changed Type",
        "Race",
        each
            if [RaceHispanic] = 1 then
                "Hispanic"
            else if List.Sum({[RaceWhite], [RaceBlack], [RaceAsian], [RaceAmIndAk], [RaceHawPAC]}) > 1 then
                "Two or More Races"
            else if List.Sum({[RaceWhite], [RaceBlack], [RaceAsian], [RaceAmIndAk], [RaceHawPAC], [RaceUnsp]}) < 1 then
                "Unknown"
            else if [RaceWhite] = 1 then
                "White"
            else if [RaceBlack] = 1 then
                "African American"
            else if [RaceAsian] = 1 then
                "Asian"
            else if [RaceHawPAC] = 1 then
                "Hawaiian/Pacific Islander"
            else if [RaceAmIndAk] = 1 then
                "American Indian/Alaskan"
            else if [RaceUnsp] = 1 then
                "Not Specified"
            else
                "ERROR"
    )
in
    #"Added Custom2"
