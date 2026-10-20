// @snippet.title: DEfacilities
// @snippet.description: Snippet for DEfacilities.
// @snippet.tags: auto-generated
//Query fetches class locations from datamart and filters for Governor's School and DE  High School locations. It also adds a column for the school name and county based on the class location and section.
let
    Source = @Source,
   
    AddSchoolCol = Table.AddColumn(
        Source,
 "High School",
        each
            if [ACAD_ORG] = "ICDUAL" then
                if Text.EndsWith([CLASS_LOCATION], "MGS") or [CLASS_LOCATION] = "SC_MGS" then
                    "Masanutten Regional Governors School"
                else if [CLASS_LOCATION] = "MVGSF" then
                    "Mountain Vista Governors School Fauquier"
                else if [CLASS_LOCATION] = "MVGSM" then
                    "Mountain Vista Governors School Middletown"
                else if [CLASS_SECTION] = "802A" or [CLASS_LOCATION] = "MID_TRADES" then
                    "High School Trades Academy"
                else if [CLASS_SECTION] = "802B" then
                    "EMS Academy"
                else if [CLASS_SECTION] = "802C" then
                    "Drone Academy"
                else if [CLASS_SECTION] = "802D" or [CLASS_SECTION] = "812D" or [CLASS_LOCATION] = "MID_FEA" then
                    "Future Educators Academy"
                else if Text.EndsWith([SPACE_DESC], "High School") then
                    if [SPACE_DESC] = "Mountain View High School" then
                        "Stonewall Jackson High School"
                    else
                        [SPACE_DESC]
                else if Text.EndsWith([SPACE_DESC], "Hs") then
                    Text.Replace([SPACE_DESC], "Hs", "High School")
                else
                    null
            else
                null,
        type text
    ),
    AddCountyCol = Table.AddColumn(
        AddSchoolCol,
        "School District",
        each
            if List.Contains(
                {
                    "High SchoolTrades Academy",
                    "EMS Academy",
                    "Drone Academy",
                    "Future Educators Academy",
                    "Dowell J Howard Center",
                    "Blue Ridge Technical Center",
                    "Triplett Tech Institute"
                },
                [High School]
            ) then
                "Academies"
            else if List.Contains(
                {
                    "Masanutten Regional Governors School",
                    "Mountain Vista Governors School Fauquier",
                    "Mountain Vista Governors School Middletown"
                },
                [High School]
            ) then
                "Governors School"
            else if [High School] = "Clarke County High School" then
                "Clarke County"
            else if List.Contains({"Fauquier County High School", "Kettle Run High School", "liberty High School"}, [High School]) then
                "Fauquier County"
            else if List.Contains({"James Wood High School", "Sherando High School", "Millbrook High School"}, [High School]) then
                "Frederick County"
            else if [High School] = "John Handley High School" then
                "Winchester City"
            else if List.Contains({"Luray High School", "Page County High School"}, [High School]) then
                "Page County"
            else if [High School] = "Rappahannock County High School" then
                "Rappahannock County"
            else if List.Contains(
                {
                    "Strasburg High School",
                    "Stonewall Jackson High School",
                    "Mountain View High School",
                    "Central High School"
                },
                [High School]
            ) then
                "Shenandoah County"
            else if List.Contains({"Warren County High School", "Skyline High School"}, [High School]) then
                "Warren County"
            else
                null,
        type text
    )
in
    AddCountyCol
