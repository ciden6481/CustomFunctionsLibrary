// sql
let
    Source = Csv.Document(File.Contents("C:\Users\ciden\OneDrive - laurelridge.edu\Institutional Research-group - General\PowerBI Workspaces\Enrollment Dashboard\sql.csv"),[Delimiter=",", Columns=47, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Replaced Value" = Table.ReplaceValue(#"Promoted Headers","","0",Replacer.ReplaceValue,{"PELLELIG"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Replaced Value",{{"ACADLVL", type number}, {"CEEB", type number}, {"EMPLID", type number}, {"HS_GRAD_YEAR", type number}, {"JURIS", type number}, {"LPCC", type number}, {"OFFCNT", type number}, {"ONCNT", type number}, {"PELLELIG", type number}, {"SCH", type number}, {"STRM", type number}, {"TCNT", type number}, {"VHC", type number},  {"X_RUNDATE", type date}, {"RUNDATE", type date}, {"BIRTH_DATE", type date}}),
    #"Trimmed Text" = Table.TransformColumns(Table.TransformColumnTypes(#"Changed Type", {{"ACADLVL", type text}, {"BIRTH_DATE", type text}, {"CEEB", type text}, {"EMPLID", type text}, {"HS_GRAD_YEAR", type text}, {"JURIS", type text}, {"LPCC", type text}, {"OFFCNT", type text}, {"ONCNT", type text}, {"PELLELIG", type text}, {"RUNDATE", type text}, {"SCH", type text}, {"STRM", type text}, {"TCNT", type text}, {"VHC", type text}, {"X_RUNDATE", type text}}, "en-US"),{{"ACAD_CAREER", Text.Trim, type text}, {"ACADLVL", Text.Trim, type text}, {"ACADPLAN", Text.Trim, type text}, {"ADMIT_TYPE", Text.Trim, type text}, {"BIRTH_DATE", Text.Trim, type text}, {"CEEB", Text.Trim, type text}, {"CLSTYP", Text.Trim, type text}, {"DEGREE", Text.Trim, type text}, {"EMPLID", Text.Trim, type text}, {"FHE", Text.Trim, type text}, {"FICE", Text.Trim, type text}, {"FICE_EXTORG_DESC", Text.Trim, type text}, {"FNAME", Text.Trim, type text}, {"GENDER", Text.Trim, type text}, {"HISP_FL", Text.Trim, type text}, {"HOME_CAMPUS", Text.Trim, type text}, {"HS_GRAD_YEAR", Text.Trim, type text}, {"JURIS", Text.Trim, type text}, {"LNAME", Text.Trim, type text}, {"LPCC", Text.Trim, type text}, {"MHE", Text.Trim, type text}, {"MIL_STATUS", Text.Trim, type text}, {"MNAME", Text.Trim, type text}, {"OFFCNT", Text.Trim, type text}, {"ONCNT", Text.Trim, type text}, {"ONOFFCAMP", Text.Trim, type text}, {"PELLELIG", Text.Trim, type text}, {"PREV_DEGREE", Text.Trim, type text}, {"PRVENRL", Text.Trim, type text}, {"R_AMIND_ALSK", Text.Trim, type text}, {"R_ASIAN", Text.Trim, type text}, {"R_BLACK", Text.Trim, type text}, {"R_HAWPAC", Text.Trim, type text}, {"R_HISP", Text.Trim, type text}, {"R_NSPEC", Text.Trim, type text}, {"R_WHITE", Text.Trim, type text}, {"RESIDENCY", Text.Trim, type text}, {"RUNDATE", Text.Trim, type text}, {"SCH", Text.Trim, type text}, {"STRM", Text.Trim, type text}, {"TCNT", Text.Trim, type text}, {"TYPEDL", Text.Trim, type text}, {"VCSIN", Text.Trim, type text}, {"VHC", Text.Trim, type text}, {"X_RUNDATE", Text.Trim, type text}, {"XDUL_ATTRIBUTE", Text.Trim, type text}, {"ZIP", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"ACAD_CAREER", Text.Clean, type text}, {"ACADLVL", Text.Clean, type text}, {"ACADPLAN", Text.Clean, type text}, {"ADMIT_TYPE", Text.Clean, type text}, {"BIRTH_DATE", Text.Clean, type text}, {"CEEB", Text.Clean, type text}, {"CLSTYP", Text.Clean, type text}, {"DEGREE", Text.Clean, type text}, {"EMPLID", Text.Clean, type text}, {"FHE", Text.Clean, type text}, {"FICE", Text.Clean, type text}, {"FICE_EXTORG_DESC", Text.Clean, type text}, {"FNAME", Text.Clean, type text}, {"GENDER", Text.Clean, type text}, {"HISP_FL", Text.Clean, type text}, {"HOME_CAMPUS", Text.Clean, type text}, {"HS_GRAD_YEAR", Text.Clean, type text}, {"JURIS", Text.Clean, type text}, {"LNAME", Text.Clean, type text}, {"LPCC", Text.Clean, type text}, {"MHE", Text.Clean, type text}, {"MIL_STATUS", Text.Clean, type text}, {"MNAME", Text.Clean, type text}, {"OFFCNT", Text.Clean, type text}, {"ONCNT", Text.Clean, type text}, {"ONOFFCAMP", Text.Clean, type text}, {"PELLELIG", Text.Clean, type text}, {"PREV_DEGREE", Text.Clean, type text}, {"PRVENRL", Text.Clean, type text}, {"R_AMIND_ALSK", Text.Clean, type text}, {"R_ASIAN", Text.Clean, type text}, {"R_BLACK", Text.Clean, type text}, {"R_HAWPAC", Text.Clean, type text}, {"R_HISP", Text.Clean, type text}, {"R_NSPEC", Text.Clean, type text}, {"R_WHITE", Text.Clean, type text}, {"RESIDENCY", Text.Clean, type text}, {"RUNDATE", Text.Clean, type text}, {"SCH", Text.Clean, type text}, {"STRM", Text.Clean, type text}, {"TCNT", Text.Clean, type text}, {"TYPEDL", Text.Clean, type text}, {"VCSIN", Text.Clean, type text}, {"VHC", Text.Clean, type text}, {"X_RUNDATE", Text.Clean, type text}, {"XDUL_ATTRIBUTE", Text.Clean, type text}, {"ZIP", Text.Clean, type text}}),
    #"Removed Columns" = Table.RemoveColumns(#"Cleaned Text",{"ACADLVL"})
in
    #"Removed Columns"

// AllMatchTest
let
    // Replace these with your actual query names
    TableA = sql,
    TableB = sas,

    KeyColumn = "EMPLID",

    // Get list of non-key columns
    CompareColumns =
        List.RemoveItems(
            Table.ColumnNames(TableA),
            {KeyColumn}
        ),

    // Join tables on emplid
    Joined =
        Table.NestedJoin(
            TableA,
            {KeyColumn},
            TableB,
            {KeyColumn},
            "B",
            JoinKind.Inner
        ),

    // Convert each row into a comparison record
    Compared =
        Table.AddColumn(
            Joined, 
            "Comparison", 
            each 
                let
                    A = _,
                    Brec = Table.First(A[B]),                    
                    Values =
                        List.Transform(
                            CompareColumns,
                            (c) =>
                                if Record.Field(A, c) = Record.Field(Brec, c)
                                then 0
                                else 1
                        )
                in
                    Record.FromList(Values, CompareColumns),
            type record 
        ),

// ✅ REMOVE original columns first
    RemovedOriginals =
        Table.RemoveColumns(Compared, CompareColumns),

    // ✅ now expand safely
    Expanded =
        Table.ExpandRecordColumn(
            RemovedOriginals,
            "Comparison",
            CompareColumns
        ),

    Result =
        Table.RemoveColumns(Expanded, {"B"}),
    #"Changed Type" = Table.TransformColumnTypes(Result,{{"ACAD_CAREER", Int64.Type}, {"ACADPLAN", Int64.Type}, {"ADMIT_TYPE", Int64.Type}, {"BIRTH_DATE", Int64.Type}, {"CEEB", Int64.Type}, {"CLSTYP", Int64.Type}, {"DEGREE", Int64.Type}, {"FHE", Int64.Type}, {"FICE", Int64.Type}, {"FICE_EXTORG_DESC", Int64.Type}, {"FNAME", Int64.Type}, {"GENDER", Int64.Type}, {"HISP_FL", Int64.Type}, {"HOME_CAMPUS", Int64.Type}, {"HS_GRAD_YEAR", Int64.Type}, {"JURIS", Int64.Type}, {"LNAME", Int64.Type}, {"LPCC", Int64.Type}, {"MHE", Int64.Type}, {"MIL_STATUS", Int64.Type}, {"MNAME", Int64.Type}, {"OFFCNT", Int64.Type}, {"ONCNT", Int64.Type}, {"ONOFFCAMP", Int64.Type}, {"PELLELIG", Int64.Type}, {"PREV_DEGREE", Int64.Type}, {"PRVENRL", Int64.Type}, {"R_AMIND_ALSK", Int64.Type}, {"R_ASIAN", Int64.Type}, {"R_BLACK", Int64.Type}, {"R_HAWPAC", Int64.Type}, {"R_HISP", Int64.Type}, {"R_NSPEC", Int64.Type}, {"R_WHITE", Int64.Type}, {"RESIDENCY", Int64.Type}, {"RUNDATE", Int64.Type}, {"SCH", Int64.Type}, {"STRM", Int64.Type}, {"TCNT", Int64.Type}, {"TYPEDL", Int64.Type}, {"VCSIN", Int64.Type}, {"VHC", Int64.Type}, {"X_RUNDATE", Int64.Type}, {"XDUL_ATTRIBUTE", Int64.Type}, {"ZIP", Int64.Type}})
in
    #"Changed Type"

// sas
let
    Source = Csv.Document(File.Contents("C:\Users\ciden\OneDrive - laurelridge.edu\Institutional Research-group - General\PowerBI Workspaces\Enrollment Dashboard\sas.csv"),[Delimiter=",", Columns=47, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"ACADLVL", type number}, {"CEEB", type number}, {"EMPLID", type number}, {"HS_GRAD_YEAR", type number}, {"JURIS", type number}, {"LPCC", type number}, {"OFFCNT", type number}, {"ONCNT", type number}, {"PELLELIG", type number}, {"SCH", type number}, {"STRM", type number}, {"TCNT", type number}, {"VHC", type number},  {"X_RUNDATE", type date}, {"RUNDATE", type date}, {"BIRTH_DATE", type date}}),
    #"Trimmed Text" = Table.TransformColumns(Table.TransformColumnTypes(#"Changed Type", {{"ACADLVL", type text}, {"BIRTH_DATE", type text}, {"CEEB", type text}, {"EMPLID", type text}, {"HS_GRAD_YEAR", type text}, {"JURIS", type text}, {"LPCC", type text}, {"OFFCNT", type text}, {"ONCNT", type text}, {"PELLELIG", type text}, {"RUNDATE", type text}, {"SCH", type text}, {"STRM", type text}, {"TCNT", type text}, {"VHC", type text}, {"X_RUNDATE", type text}}, "en-US"),{{"ACAD_CAREER", Text.Trim, type text}, {"ACADLVL", Text.Trim, type text}, {"ACADPLAN", Text.Trim, type text}, {"ADMIT_TYPE", Text.Trim, type text}, {"BIRTH_DATE", Text.Trim, type text}, {"CEEB", Text.Trim, type text}, {"CLSTYP", Text.Trim, type text}, {"DEGREE", Text.Trim, type text}, {"EMPLID", Text.Trim, type text}, {"FHE", Text.Trim, type text}, {"FICE", Text.Trim, type text}, {"FICE_EXTORG_DESC", Text.Trim, type text}, {"FNAME", Text.Trim, type text}, {"GENDER", Text.Trim, type text}, {"HISP_FL", Text.Trim, type text}, {"HOME_CAMPUS", Text.Trim, type text}, {"HS_GRAD_YEAR", Text.Trim, type text}, {"JURIS", Text.Trim, type text}, {"LNAME", Text.Trim, type text}, {"LPCC", Text.Trim, type text}, {"MHE", Text.Trim, type text}, {"MIL_STATUS", Text.Trim, type text}, {"MNAME", Text.Trim, type text}, {"OFFCNT", Text.Trim, type text}, {"ONCNT", Text.Trim, type text}, {"ONOFFCAMP", Text.Trim, type text}, {"PELLELIG", Text.Trim, type text}, {"PREV_DEGREE", Text.Trim, type text}, {"PRVENRL", Text.Trim, type text}, {"R_AMIND_ALSK", Text.Trim, type text}, {"R_ASIAN", Text.Trim, type text}, {"R_BLACK", Text.Trim, type text}, {"R_HAWPAC", Text.Trim, type text}, {"R_HISP", Text.Trim, type text}, {"R_NSPEC", Text.Trim, type text}, {"R_WHITE", Text.Trim, type text}, {"RESIDENCY", Text.Trim, type text}, {"RUNDATE", Text.Trim, type text}, {"SCH", Text.Trim, type text}, {"STRM", Text.Trim, type text}, {"TCNT", Text.Trim, type text}, {"TYPEDL", Text.Trim, type text}, {"VCSIN", Text.Trim, type text}, {"VHC", Text.Trim, type text}, {"X_RUNDATE", Text.Trim, type text}, {"XDUL_ATTRIBUTE", Text.Trim, type text}, {"ZIP", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"ACAD_CAREER", Text.Clean, type text}, {"ACADLVL", Text.Clean, type text}, {"ACADPLAN", Text.Clean, type text}, {"ADMIT_TYPE", Text.Clean, type text}, {"BIRTH_DATE", Text.Clean, type text}, {"CEEB", Text.Clean, type text}, {"CLSTYP", Text.Clean, type text}, {"DEGREE", Text.Clean, type text}, {"EMPLID", Text.Clean, type text}, {"FHE", Text.Clean, type text}, {"FICE", Text.Clean, type text}, {"FICE_EXTORG_DESC", Text.Clean, type text}, {"FNAME", Text.Clean, type text}, {"GENDER", Text.Clean, type text}, {"HISP_FL", Text.Clean, type text}, {"HOME_CAMPUS", Text.Clean, type text}, {"HS_GRAD_YEAR", Text.Clean, type text}, {"JURIS", Text.Clean, type text}, {"LNAME", Text.Clean, type text}, {"LPCC", Text.Clean, type text}, {"MHE", Text.Clean, type text}, {"MIL_STATUS", Text.Clean, type text}, {"MNAME", Text.Clean, type text}, {"OFFCNT", Text.Clean, type text}, {"ONCNT", Text.Clean, type text}, {"ONOFFCAMP", Text.Clean, type text}, {"PELLELIG", Text.Clean, type text}, {"PREV_DEGREE", Text.Clean, type text}, {"PRVENRL", Text.Clean, type text}, {"R_AMIND_ALSK", Text.Clean, type text}, {"R_ASIAN", Text.Clean, type text}, {"R_BLACK", Text.Clean, type text}, {"R_HAWPAC", Text.Clean, type text}, {"R_HISP", Text.Clean, type text}, {"R_NSPEC", Text.Clean, type text}, {"R_WHITE", Text.Clean, type text}, {"RESIDENCY", Text.Clean, type text}, {"RUNDATE", Text.Clean, type text}, {"SCH", Text.Clean, type text}, {"STRM", Text.Clean, type text}, {"TCNT", Text.Clean, type text}, {"TYPEDL", Text.Clean, type text}, {"VCSIN", Text.Clean, type text}, {"VHC", Text.Clean, type text}, {"X_RUNDATE", Text.Clean, type text}, {"XDUL_ATTRIBUTE", Text.Clean, type text}, {"ZIP", Text.Clean, type text}}),
    #"Removed Columns" = Table.RemoveColumns(#"Cleaned Text",{"ACADLVL"})
in
    #"Removed Columns"

// NonMatchingRows
let
    Source = AllMatchTest,
    //Source = Table.Buffer(AllMatchTest),
    NonEMPLIDCols = List.Buffer(List.RemoveItems(Table.ColumnNames(Source), {"EMPLID"})),
        /*NonMatchCols = List.Select(
        NonEMPLIDCols,
        each List.Sum(Table.Column(Source, _) ) > 0
    ),*/
    NonMatchCols = List.Buffer(List.Select(
        NonEMPLIDCols,
        (col) => List.AnyTrue(List.Transform(Table.Column(Source, col), each _ <> null and _ > 0))
    )),
    NonMatchTable = Table.SelectColumns(Source, {"EMPLID"} & NonMatchCols),
    /*#"Added Custom" = Table.AddColumn(
    NonMatchTable,
    "Total",
    each
        List.Sum(
            List.Transform(
                NonMatchCols,
                (c) => Record.Field(_, c)
            )
        ),
    type number
),*/
#"Added Custom" = Table.AddColumn(
        NonMatchTable,
        "Total",
        each if List.IsEmpty(NonMatchCols) then 0 else List.Sum(List.RemoveNulls(Record.ToList(Record.SelectFields(_, NonMatchCols)))),
        type number
    ),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom", each [Total] > 0),
    #"Merged Queries" = Table.NestedJoin(#"Filtered Rows", {"EMPLID"}, sas, {"EMPLID"}, "sas", JoinKind.LeftOuter),
    #"Merged Queries1" = Table.NestedJoin(#"Merged Queries", {"EMPLID"}, sql, {"EMPLID"}, "sql", JoinKind.LeftOuter),
    Expandsql = Table.ExpandTableColumn(#"Merged Queries1", "sql", NonMatchCols, List.Transform(NonMatchCols, each Text.Insert(_,0,"sql."))),
    #"Expanded sas" = Table.ExpandTableColumn(Expandsql, "sas", NonMatchCols, List.Transform(NonMatchCols, each Text.Insert(_,0,"sas."))),
    #"Reordered Columns" = Table.ReorderColumns(#"Expanded sas",
        {
            "EMPLID", 
            "ACADPLAN", 
            "sas.ACADPLAN", 
            "sql.ACADPLAN", 
            "FICE",
            "sas.FICE", 
            "sql.FICE",  
            "FICE_EXTORG_DESC",
            "sas.FICE_EXTORG_DESC",
            "sql.FICE_EXTORG_DESC", 
            "FNAME",
            "sas.FNAME",
            "sql.FNAME", 
            "LNAME",
            "sas.LNAME",
            "sql.LNAME", 
            "LPCC",
            "sas.LPCC",
            "sql.LPCC", 
            "MNAME",
            "sas.MNAME",
            "sql.MNAME", 
            "PELLELIG",
            "sas.PELLELIG",
            "sql.PELLELIG", 
            "Total" 

})
in
    #"Reordered Columns"