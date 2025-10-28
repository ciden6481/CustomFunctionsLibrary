let
    MapSchools = (classSection as text) as nullable text =>
        let
            result =
                if classSection = "802A" then
                    "Trades Academy"
                else if classSection = "802B" then
                    "EMS Acadmey"
                else if classSection = "802C" then
                    "Drone Academy"
                else if Text.StartsWith(classSection, "9V") and Text.EndsWith(classSection, "B") then
                    "MVGSF"
                else if Text.StartsWith(classSection, "9V") and Text.EndsWith(classSection, "A") then
                    "MVGSM"
                else if classSection = "9M16" then
                    "MGS"
                else if Text.StartsWith(classSection, "8C") and Text.EndsWith(classSection, "1") then
                    "Clarke County High School"
                else if Text.StartsWith(classSection, "8K") and Text.EndsWith(classSection, "2") then
                    "Kettle Run High School"
                else if Text.StartsWith(classSection, "8L") and Text.EndsWith(classSection, "2") then
                    "Liberty High School"
                else if Text.StartsWith(classSection, "8F") and Text.EndsWith(classSection, "2") then
                    "Fauquier High School"
                else if Text.StartsWith(classSection, "8V") and Text.EndsWith(classSection, "2") then
                    "Fresta Valley Christian School"
                else if Text.StartsWith(classSection, "8J") and Text.EndsWith(classSection, "3") then
                    "James Wood High School"
                else if Text.StartsWith(classSection, "8M") and Text.EndsWith(classSection, "3") then
                    "Millbrook High School"
                else if Text.StartsWith(classSection, "8D") and Text.EndsWith(classSection, "3") then
                    "Dowell J Howard Center"
                else if Text.StartsWith(classSection, "8S") and Text.EndsWith(classSection, "3") then
                    "Sherando High School"
                else if Text.StartsWith(classSection, "8S") and Text.EndsWith(classSection, "3") then
                    "Legacy Christian Academy"
                else if Text.StartsWith(classSection, "8L") and Text.EndsWith(classSection, "4") then
                    "Luray High School"
                else if Text.StartsWith(classSection, "8P") and Text.EndsWith(classSection, "4") then
                    "Page County High School"
                else if Text.StartsWith(classSection, "8T") and Text.EndsWith(classSection, "4") then
                    "Page County Technical Center"
                else if Text.StartsWith(classSection, "8R") and Text.EndsWith(classSection, "5") then
                    "Rappahannock County High School"
                else if Text.StartsWith(classSection, "8W") and Text.EndsWith(classSection, "5") then
                    "Wakefield Country Day School"
                else if Text.StartsWith(classSection, "8C") and Text.EndsWith(classSection, "6") then
                    "Central High School"
                else if Text.StartsWith(classSection, "8J") and Text.EndsWith(classSection, "6") then
                    "Stonewall Jackson High School"
                else if Text.StartsWith(classSection, "8S") and Text.EndsWith(classSection, "6") then
                    "Strasburg High School"
                else if Text.StartsWith(classSection, "8T") and Text.EndsWith(classSection, "6") then
                    "Triplett Tech"
                else if Text.StartsWith(classSection, "8S") and Text.EndsWith(classSection, "7") then
                    "Skyline High School"
                else if Text.StartsWith(classSection, "8W") and Text.EndsWith(classSection, "7") then
                    "Warren County High School"
                else if Text.StartsWith(classSection, "8B") and Text.EndsWith(classSection, "7") then
                    "Blue Ridge Technical Center"
                else if Text.StartsWith(classSection, "8r") and Text.EndsWith(classSection, "7") then
                    "Randolph-Macon Academy"
                else if Text.StartsWith(classSection, "8H") and Text.EndsWith(classSection, "8") then
                    "John Handley High School"
                else
                    null
        in
            result
in
    MapSchools
