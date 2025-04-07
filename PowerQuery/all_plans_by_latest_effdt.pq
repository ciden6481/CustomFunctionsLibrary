# Replace academic plans

Code assumes that [all_plans_by_latest_effdt] has already been run


```
let
    Source = Sql.Database("IAAS-INSTANTID\CARDS", "DATA"),
    dbo_IR_ALL_PLANS = Source{[Schema="dbo",Item="IR_ALL_PLANS"]}[Data],
    #"Grouped Rows" = Table.Group(dbo_IR_ALL_PLANS, {"ACAD_PLAN"}, {{"latest", each List.Max([EFFDT]), type datetime}, {"all_rows", each _, type table [INSTITUTION=text, ACAD_PLAN=text, EFFDT=datetime, EFF_STATUS=text, DESCR=nullable text, DESCRSHORT=nullable text, ACAD_PLAN_TYPE=nullable text, ACAD_PROG=nullable text, DEGREE=nullable text, DIPLOMA_DESCR=nullable text, DIPLOMA_PRINT_FL=nullable text, TRNSCR_DESCR=nullable text, TRNSCR_PRINT_FL=nullable text, FIRST_TERM_VALID=nullable text, CIP_CODE=nullable text, STUDY_FIELD=nullable text, SSR_LAST_ADM_TERM=nullable text, SSR_NSC_CRD_LVL=nullable text, SSR_PROG_LENGTH=nullable number, SSR_PROG_LEN_TYPE=nullable text]}}),
    #"Expanded all_rows" = Table.ExpandTableColumn(#"Grouped Rows", "all_rows", {"EFFDT", "EFF_STATUS", "DESCR", "DEGREE"}, {"EFFDT", "EFF_STATUS", "DESCR", "DEGREE"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded all_rows", each [EFFDT] = [latest])
in
    #"Filtered Rows"
```