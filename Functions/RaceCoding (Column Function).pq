// Recode VX_IR_ETHNIC_* flags into a single `Race` value for use with Add Column -> Invoke Custom Function.
// Usage: Add Column -> Invoke Custom Function, map each parameter to its VX_IR_ETHNIC_* column.
let
    RecodeRace = (
        RaceCol1 as any,
        RaceCol2 as any,
        RaceCol3 as any,
        RaceCol4 as any,
        RaceCol5 as any,
        RaceCol6 as any,
        RaceCol7 as any
    ) as text =>
        let
            // normalize various "yes" values to 1, else 0
            IsYes = (v) =>
                let
                    s = if v = null then "" else Text.Upper(Text.Trim(Text.From(v)))
                in
                    if List.Contains({"Y", "1", "TRUE", "YES", "T"}, s) then 1 else 0,

            // evaluate flags for this row
            _f1 = IsYes(RaceCol1),
            _f2 = IsYes(RaceCol2),
            _f3 = IsYes(RaceCol3),
            _f4 = IsYes(RaceCol4),
            _f5 = IsYes(RaceCol5),
            _f6 = IsYes(RaceCol6),
            _f7 = IsYes(RaceCol7),

            // multi-race count: per spec, count only 1,2,4,5,7 (exclude 3 and 6)
            _sumMulti = _f1 + _f2 + _f4 + _f5 + _f7,
            // any presence among 1,2,4,5,6,7 (used to detect no Y)
            _any = _f1 + _f2 + _f4 + _f5 + _f6 + _f7,

            // final Race logic (same priorities as the table function)
            result =
                if _f3 = 1 then
                    "Hispanic"
                else if _sumMulti > 1 then
                    "Two or More Races"
                else if _any < 1 then
                    "Unknown race/ethnicity"
                else if _f1 = 1 then
                    "White"
                else if _f2 = 1 then
                    "African American"
                else if _f4 = 1 then
                    "Asian"
                else if _f5 = 1 then
                    "American Indian /Alaskan"
                else if _f6 = 1 then
                    "Not Specified"
                else if _f7 = 1 then
                    "Hawaiian / Pacific Islander"
                else
                    "Unknown race/ethnicity"
        in
            result
in
    RecodeRace
