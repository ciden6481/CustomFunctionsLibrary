let
    Source = Table.Combine(
        {udt_y20202021_anstu, udt_y20242025_anstu, udt_y20232024_anstu, udt_y20222023_anstu, udt_y20212022_anstu}
    ),
    FilterForDE = Table.SelectRows(Source, each ([DEFLAG] = "1")),
    JoinJURIS = Table.NestedJoin(
        FilterForDE, {"JURIS"}, TRANS_JURIS_TBL, {"juris"}, "TRANS_JURIS_TBL", JoinKind.LeftOuter
    ),
    JoinCEEB = Table.NestedJoin(JoinJURIS, {"ATP_CD"}, CEEB, {"CEEB"}, "CEEB (Sheet1)", JoinKind.LeftOuter),
    ExpandCEEB = Table.ExpandTableColumn(
        JoinCEEB,
        "CEEB (Sheet1)",
        {"CEEB", "School", "School District", "LR_Division"},
        {"CEEB", "School", "School District", "LR_Division"}
    ),
    ExpandJURIS = Table.ExpandTableColumn(ExpandCEEB, "TRANS_JURIS_TBL", {"name"}, {"Location"}),
    RecodeRace = Table.AddColumn(
        ExpandJURIS,
        "Race",
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
                "Unknown",
        type text
    )
in
    RecodeRace
