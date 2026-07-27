// Reusable Power Query function: RecodeCountyJuris
// Adds a `County` column with human-friendly names based on a county code column.
// Usage examples:
//   RecodeCountyJuris(MyTable)
//   RecodeCountyJuris(MyTable, "CountyCode")

let
    RecodeCountyJuris = (InputTable as table, optional CountyColumnName as nullable text) as table =>
        let
            // default column name when not provided
            ColumnName = if CountyColumnName = null then "COUNTY" else CountyColumnName,

            // safe normalizer: convert value to trimmed text or null
            Normalize = (v as nullable any) as nullable text =>
                if v = null then
                    null
                else
                    Text.Trim(Text.From(v)),

            // map codes to names
            Recode = (code as nullable text) as text =>
                let c = if code = null then null else code
                in
                    if c = "022" then "Clarke"
                    else if c = "030" then "Fauquier"
                    else if c = "034" then "Frederick"
                    else if c = "068" then "Page"
                    else if c = "076" then "Rappahannock"
                    else if c = "083" then "Shenandoah"
                    else if c = "091" then "Warren"
                    else if c = "820" then "Winchester"
                    else "Out of Service Area",

            // add the County column using a safe field lookup
            AddedCounty = Table.AddColumn(
                InputTable,
                "County",
                each Recode(Normalize(try Record.Field(_, ColumnName) otherwise null)),
                type text
            )
        in
            AddedCounty
in
    RecodeCountyJuris
