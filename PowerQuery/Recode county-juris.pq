let
    //Recode county for actual county names
    #"Added County" = Table.AddColumn(
        #"Added TermDE",
        "County",
        each
            if [COUNTY] = "022" then
                "Clarke"
            else if [COUNTY] = "030" then
                "Fauquier"
            else if [COUNTY] = "034" then
                "Frederick"
            else if [COUNTY] = "068" then
                "Page"
            else if [COUNTY] = "076" then
                "Rappahannock"
            else if [COUNTY] = "083" then
                "Shenandoah"
            else if [COUNTY] = "091" then
                "Warren"
            else if [COUNTY] = "820" then
                "Winchester"
            else
                "Out of Service Area"
    )
in
    #"Added County"
