// IR_STRM_TBL
let
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    dbo_IR_STRM_TBL = Source{[Schema = "dbo", Item = "IR_STRM_TBL"]}[Data],
    // Use NativeQuery to replace ACAD_YEAR for summer 20 & summer 19 to allow query folding in subsequent steps
    NativeQuery = Value.NativeQuery(
        Source,
        "SELECT
            subquery.*
        FROM (
            SELECT
            STRM,
            DESCR,
                CASE 
                    WHEN STRM = '2203' THEN '2020'
                    WHEN STRM = '2193' THEN '2019'
                    ELSE ACAD_YEAR
                END AS ACAD_YEAR
            FROM dbo.IR_STRM_TBL
            WHERE ACAD_CAREER='CRED'
        ) AS subquery",
        null,
        [
            EnableFolding = true
        ]
    ),
    #"Sorted Rows" = Table.Sort(NativeQuery, {{"STRM", Order.Ascending}}),
    #"Renamed Columns" = Table.RenameColumns(#"Sorted Rows", {{"DESCR", "TermYear"}})
in
    #"Renamed Columns"
