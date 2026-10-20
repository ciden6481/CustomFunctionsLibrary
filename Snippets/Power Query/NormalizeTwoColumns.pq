// @snippet.title: NormalizeTwoColumns
// @snippet.description: Snippet for NormalizeTwoColumns.
// @snippet.tags:
//Function creates a mapping table to normalize two columns in two unrelated tables so they match prior to import into Power BI report. In this example, race/ethnicity terms are normalized so the same values are used across tables.
/* Can be implemented as a transform:
Table.TransformColumns(
    Source,
    {
        {"RaceEthnicity", fnNormalizeRace, type text}
    }
)
or as a custom column:
Table.AddColumn(
    Source,
    "Race Standardized",
    each fnNormalizeRace([RaceEthnicity]),
    type text
)
*/
(value as nullable text) as nullable text =>
    let
        RaceMap = [
            #"Black, not of Hispanic origin" = "Black/African American",
            #"Non-Hispanic, two or more races" = "Two or More",
            #"Native Hawaiian  or Pacific Islander" = "Native Hawaiian/Pacific Islander",
            #"White, not of Hispanic origin" = "White",
            #"American Indian or Alaska Native" = "American Indian/Alaska Native",
            #"African American" = "Black/African American",
            #"American Indian /Alaskan" = "American Indian/Alaska Native",
            #"Nat. Hawaiian/Other P.I." = "Native Hawaiian/Pacific Islander",
            #"Two or More Races" = "Two or More",
            #"Unknown race/ethnicity" = "Other/Unknown",
            #"Unknown" = "Other/Unknown"
        ]
    in
        if value = null then
            null
        else
            Record.FieldOrDefault(RaceMap, value, value)
