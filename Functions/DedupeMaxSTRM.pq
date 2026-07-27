// Not a reusable function, this snippet needs to be edited and pasted into the main query to work.  It is a helper to dedupe the data by EMPLID and STRM, keeping only the most recent STRM for each EMPLID.
// Replace "EMPLID" & "STRM" if necessary

let
    PrevStep = <YourPreviousStepNameHere>,
    GroupByMaxSTRM =
        Table.Group(
            PrevStep,
            {"EMPLID"},
            {{"STRM", each List.Max([STRM]), type text}}
        ),

    JoinToMaxSTRM =
        TableJoin(
            PrevStep,
            {"EMPLID", "STRM"},
            GroupByMaxSTRM,
            {"EMPLID", "STRM"},
            
            JoinKind.Inner
        )
in
    JoinToMaxSTRM
