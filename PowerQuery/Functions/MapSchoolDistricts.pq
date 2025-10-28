let
    MapSchoolDistricts = (classSection as text) as nullable text =>
        let
            result =
                if
                    (Text.StartsWith(classSection, "9V") and Text.EndsWith(classSection, "B"))
                    or (Text.StartsWith(classSection, "9V") and Text.EndsWith(classSection, "A"))
                    or (classSection = "9M16")
                    or List.Contains({"802A", "802B", "802C"}, classSection)
                then
                    "Governor's School"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "1") then
                    "Clarke County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "2") then
                    "Fauquier County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "3") then
                    "Frederick County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "4") then
                    "Page County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "5") then
                    "Rappahannock County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "6") then
                    "Shenandoah County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "7") then
                    "Warren County"
                else if Text.Middle(classSection, 0, 1) = "8" and Text.EndsWith(classSection, "8") then
                    "Winchester City"
                else
                    null
        in
            result
in
    MapSchoolDistricts
