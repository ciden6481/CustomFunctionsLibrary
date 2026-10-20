// Term
// IR_STRM_TBL
let
    //    Source = IR_STRM_TBL,
    // Use NativeQuery to replace ACAD_YEAR for summer 20 & summer 19 to allow query folding in subsequent steps, rename DESCR to TermYear, and get Semester by itself
    Source = Value.NativeQuery(
        Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
        "SELECT
            subquery.*
        FROM (
            SELECT
            STRM ,
            DESCR AS TermYear,
            DESCRSHORT AS DescriptionShort,
            TERM_BEGIN_DT AS TermBeginDt,
            TERM_END_DT AS TermEndDt,
            SUBSTRING(DESCR, 6, LEN(DESCR) - 5) AS Semester,
                CASE 
                    WHEN STRM = '2203' THEN 2020
                    WHEN STRM = '2193' THEN 2019
                    ELSE CAST(ACAD_YEAR AS INT)
                END AS AcademicYearInt,
                CASE 
                    WHEN STRM = '2203' THEN '2020'
                    WHEN STRM = '2193' THEN '2019'
                    ELSE ACAD_YEAR
                END AS AcademicYear
            FROM dbo.IR_STRM_TBL
            WHERE ACAD_CAREER='CRED'
        ) AS subquery",
        null,
        [
            EnableFolding = true
        ]
    ),
    #"Sorted Rows" = Table.Sort(Source, {{"STRM", Order.Ascending}}),
    #"Changed Type" = Table.TransformColumnTypes(
        #"Sorted Rows", {{"TermEndDt", type date}, {"TermBeginDt", type date}}
    ),
    #"Filtered Rows" = Table.SelectRows(
        #"Changed Type", each ([STRM] <> "2102" and [STRM] <> "2103" and [STRM] <> "2104" and [STRM] <> "2112")
    ),
    #"Added Custom" = Table.AddColumn(
        #"Filtered Rows",
        "VCCS_AcadYr",
        each
            if [Semester] = "Summer" then
                ([AcademicYear] & "-" & Text.From([AcademicYearInt] + 1))
            else
                (Text.From([AcademicYearInt] - 1) & "-" & [AcademicYear])
    )
in
    #"Added Custom"
