let
    Source = SharePoint.Contents(
        "https://laurelridgeedu.sharepoint.com/sites/InstitutionalResearch-group", [ApiVersion = 15]
    ),
    UDTFolder = Source{[Name = "VCCS Data Files"]}[Content]{[Name = "UDT Files"]}[Content],
    GetFileFunc = (fileName as text) as binary =>
        let
            GetCSV = Csv.Document(
                fileName, [Delimiter = ",", Columns = 68, Encoding = 1252, QuoteStyle = QuoteStyle.None]
            ),
            PromoteHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true])
        in
            PromoteHeaders,
    InvokeGetFileFunc = Table.AddColumn(UDTFolder, "Transform File", each GetFileFunc([Content])),
    
    RemoveUnusedCols = Table.SelectColumns(InvokeGetFileFunc, {"Name", "Transform File"}),
    ExpandDataCols = Table.ExpandTableColumn(
        RemoveUnusedCols, "Transform File", Table.ColumnNames(GetFileFunc(UDTFolder{0}[Content]))
    ),
    SetColTypes = Table.TransformColumnTypes(
        ExpandDataCols,
        {
            {"Source.Name", type text},
            {"AY", type text},
            {"MHE", type text},
            {"FHE", type text},
            {"STRM", type text},
            {"SSNO", type text},
            {"VCSIN", type text},
            {"EMPLID", type text},
            {"INSTITUTION", type text},
            {"COLLNUM", type text},
            {"FIRST_NAME", type text},
            {"MIDDLE_NAME", type text},
            {"LAST_NAME", type text},
            {"SEX", type text},
            {"RACE", type any},
            {"NEW_RACE", Int64.Type},
            {"HISP_LATINO", type text},
            {"VX_IR_ETHNIC_1", type text},
            {"VX_IR_ETHNIC_2", type text},
            {"VX_IR_ETHNIC_3", type text},
            {"VX_IR_ETHNIC_4", type text},
            {"VX_IR_ETHNIC_5", type text},
            {"VX_IR_ETHNIC_6", type text},
            {"VX_IR_ETHNIC_7", type text},
            {"PARENT_CAMPUS_A", type text},
            {"CAMPUS", type text},
            {"STATUS", Int64.Type},
            {"JURIS", type text},
            {"PS_JURIS", type text},
            {"POSTAL", type text},
            {"BIRTH_DATE", type date},
            {"AGE", Int64.Type},
            {"MILITARY_STATUS", type text},
            {"VX_IR_CITZEN_CNTRY", type text},
            {"CITIZENSHIP_STATUS", type text},
            {"VISA_PERMIT_TYPE", type text},
            {"VISA_SCHEV", Int64.Type},
            {"RESIDENCY", type text},
            {"VC_JURIS_CODE", Int64.Type},
            {"TUITION_RES", type text},
            {"TUITION_EXCPT", type text},
            {"ATP_CD", Int64.Type},
            {"VX_IR_HS_GRAD_YR", Int64.Type},
            {"EXT_GPA", Int64.Type},
            {"FICE_CD", type text},
            {"VX_IR_PREV_DEGREE", type text},
            {"PROGRAM_LEVEL", Int64.Type},
            {"ACAD_LEVEL_BOT", Int64.Type},
            {"ADMIT_TERM", Int64.Type},
            {"CURR", Int64.Type},
            {"ACAD_PLAN", type text},
            {"CIP", type number},
            {"FP_CODE", type text},
            {"DAYEVE", type text},
            {"QTR_HEAD_CODE", type text},
            {"QUARTER_CODE", type text},
            {"YEAR", Int64.Type},
            {"SKEY", Int64.Type},
            {"EKEY", Int64.Type},
            {"FERPA", type text},
            {"COLLEGE", type text},
            {"FA_ACTIVITY", type text},
            {"VX_XDUL_ATTRIBUTE", type any},
            {"DEFLAG", type any},
            {"CTG", Int64.Type},
            {"VX_IR_GREAT_EXP", type text},
            {"VX_IR_XSSC", type text},
            {"NRA_SCHEV", Int64.Type},
            {"UNT_TAKEN", Int64.Type}
        }
    )
in
    SetColTypes
