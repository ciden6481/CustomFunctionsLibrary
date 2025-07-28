
        let
            Source = SharePoint.Contents(
                "https://laurelridgeedu.sharepoint.com/sites/InstitutionalResearch-group", [ApiVersion = 15]
            ),
            UDTFolder = Source{[Name="VCCS Data Files"]}[Content]{[Name="UDT Files"]}[Content],
            UDTList = UDTFolder[Name],

            let
    Source = (Parameter1) => let
        Source = Csv.Document(Parameter1,[Delimiter=",", Columns=68, Encoding=1252, QuoteStyle=QuoteStyle.None]),
        #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true])
    in
        #"Promoted Headers"
in
    Source

    
            ExtractFiles = (fileName as text) as table =>
                let 
                    FileContents = #"UDT Files"{[Name = "udt_y20242025_anstu.csv"]}[Content],
            #"Imported CSV" = Csv.Document(
                #"udt_y20242025_anstu csv1",
                [
                    Delimiter = ",",
                    Columns = 68,
                    Encoding = 1252,
                    QuoteStyle = QuoteStyle.None
                ]
            ),
            #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
            #"Changed Type" = Table.TransformColumnTypes(
                #"Promoted Headers",
                {
                    {"ay", Int64.Type},
                    {"strm", Int64.Type},
                    {"ssno", Int64.Type},
                    {"vcsin", type text},
                    {"emplid", Int64.Type},
                    {"institution", type text},
                    {"collnum", Int64.Type},
                    {"fname", type text},
                    {"mname", type text},
                    {"lname", type text},
                    {"gender", type text},
                    {"race", type text},
                    {"new_race", Int64.Type},
                    {"hisp_fl", type text},
                    {"r_white", type text},
                    {"r_black", type text},
                    {"r_hisp", type text},
                    {"r_asian", type text},
                    {"r_amind_alsk", type text},
                    {"r_nspec", type text},
                    {"r_hawpac", type text},
                    {"parent_campus_a", type text},
                    {"home_campus", type text},
                    {"status", Int64.Type},
                    {"juris", Int64.Type},
                    {"ps_juris", Int64.Type},
                    {"zip", type text},
                    {"birth_date", type date},
                    {"age", Int64.Type},
                    {"fhe", type text},
                    {"mhe", type text},
                    {"mil_status", type text},
                    {"citiz", type text},
                    {"citz_status", Int64.Type},
                    {"visa", type text},
                    {"visa_schev", Int64.Type},
                    {"residency", type text},
                    {"ovcountry", Int64.Type},
                    {"tuition_residency", type text},
                    {"tuition_exception", type text},
                    {"ceeb", Int64.Type},
                    {"hs_grad_year", Int64.Type},
                    {"hsgpa", Int64.Type},
                    {"college_last_attended", type text},
                    {"prev_degree", type text},
                    {"program_level", Int64.Type},
                    {"ACAD_LEVEL_BOT", Int64.Type},
                    {"admit_term", Int64.Type},
                    {"curr", Int64.Type},
                    {"acadplan", type text},
                    {"cip", type number},
                    {"fp_code", type text},
                    {"dayeve", type text},
                    {"qtr_head_code", type text},
                    {"quarter_code", type text},
                    {"year", Int64.Type},
                    {"skey", Int64.Type},
                    {"ekey", Int64.Type},
                    {"ferpa", type text},
                    {"college", type text},
                    {"fa_activity", type text},
                    {"xdul", type text},
                    {"deflag", type text},
                    {"ctg", Int64.Type},
                    {"great_exp", type text},
                    {"student_success", type text},
                    {"nra_schev", type text},
                    {"annual_student_credits", Int64.Type}
                }
            ),
            #"Appended Query" = Table.Combine({#"Changed Type", #"udt_y20232024_anstu csv"})
        in
            #"Appended Query"

