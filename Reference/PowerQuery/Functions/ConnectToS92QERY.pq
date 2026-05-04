let

  GetFilteredOracleViewImpl = 
    (
      ViewName as text,
      optional CustomFilter1Column as nullable text,
      optional CustomFilter1Value as any,
      optional InstitutionValue as any,
      optional CustomFilter2Column as nullable text,
      optional CustomFilter2Value as any,
      optional StrmValues as nullable text
    ) 
    as table =>
    let
      // Defaults
      _Server = "s92qery",
      _Schema = "SYSADM",
      _InstitutionValue = if (InstitutionValue <> null) then InstitutionValue else "LF298",

      // Connect to Oracle
      Source = Oracle.Database(_Server, [CreateNavigationProperties = false]),

      // Pull the target view/table
      TableData = Source{[Schema = _Schema, Item = ViewName]}[Data],

      // Custom Filter 1 (apply only if both column and value provided)
      _ParseTokens = (value as any) as list =>
        let
          _Raw = if value = null then null else Text.Trim(Text.From(value)),
          _Tokens =
            if _Raw = null or _Raw = "" then
              {}
            else
              List.Distinct(
                List.Select(
                  List.Transform(Text.Split(_Raw, ","), each Text.Trim(_)),
                  each _ <> ""
                )
              )
        in
          _Tokens,
      _TableColumns = Table.ColumnNames(TableData),
      StepMainFiltered = 
        if (CustomFilter1Column <> null and CustomFilter1Value <> null) then
          let
            _EnsureMainColumn = 
              if List.Contains(_TableColumns, CustomFilter1Column) 
              then TableData 
              else 
                error Text.Format(
                  "Column '#{col}' was not found in view '#{view}'. Available columns: #{cols}",
                  [col = CustomFilter1Column, view = ViewName, cols = Text.Combine(_TableColumns, ", ")]
                ),
            _Tokens = _ParseTokens(CustomFilter1Value),
            _HasTokens = List.Count(_Tokens) > 0,
            _Filtered =
              if _HasTokens then
                Table.SelectRows(
                  _EnsureMainColumn,
                  each
                    let v = try Text.Trim(Text.From(Record.Field(_, CustomFilter1Column))) otherwise null
                    in v <> null and List.Contains(_Tokens, v)
                )
              else
                _EnsureMainColumn
          in
            _Filtered
        else
          TableData,

      // Optional INSTITUTION filter (skip if no value or column missing)
      _InstitutionRaw = if _InstitutionValue = null then null else Text.Trim(Text.From(_InstitutionValue)),
      _StepMainColumns = Table.ColumnNames(StepMainFiltered),
      StepMaybeInstitutionFiltered =
        if (_InstitutionRaw = null or _InstitutionRaw = "") then
          StepMainFiltered
        else
          let
            HasInstitution = List.Contains(_StepMainColumns, "INSTITUTION")
          in
            if not HasInstitution then
              StepMainFiltered
            else
              Table.SelectRows(
                StepMainFiltered,
                each Record.Field(_, "INSTITUTION") = _InstitutionRaw
              ),

      // Custom Filter 2 (apply only if both column and value provided; skip if column missing)
      StepMaybeThirdFiltered =
        if (CustomFilter2Column <> null and CustomFilter2Value <> null) then
          let
            CurrentCols = Table.ColumnNames(StepMaybeInstitutionFiltered)
          in
            if List.Contains(CurrentCols, CustomFilter2Column) then
              let
                _Tokens = _ParseTokens(CustomFilter2Value),
                _HasTokens = List.Count(_Tokens) > 0
              in
                if _HasTokens then
                  Table.SelectRows(
                    StepMaybeInstitutionFiltered,
                    each
                      let v = try Text.Trim(Text.From(Record.Field(_, CustomFilter2Column))) otherwise null
                      in v <> null and List.Contains(_Tokens, v)
                  )
                else
                  StepMaybeInstitutionFiltered
            else
              StepMaybeInstitutionFiltered
        else
          StepMaybeInstitutionFiltered,

      // STRM filter: optional, accepts single or comma-separated list; skip if empty or column missing
      _StrmRaw = if StrmValues = null then null else Text.Trim(StrmValues),
      StepMaybeStrmFiltered =
        if (_StrmRaw = null or _StrmRaw = "") then
          StepMaybeThirdFiltered
        else
          let
            HasStrm = List.Contains(Table.ColumnNames(StepMaybeThirdFiltered), "STRM")
          in
            if not HasStrm then
              StepMaybeThirdFiltered
            else
              let
                _Tokens =
                  List.Distinct(
                    List.Select(
                      List.Transform(Text.Split(_StrmRaw, ","), each Text.Trim(_)),
                      each _ <> ""
                    )
                  ),
                _HasTokens = List.Count(_Tokens) > 0,
                _Filtered =
                  if _HasTokens then
                    Table.SelectRows(
                      StepMaybeThirdFiltered,
                      each
                        let v = try Text.Trim(Text.From(Record.Field(_, "STRM"))) otherwise null
                        in v <> null and List.Contains(_Tokens, v)
                    )
                  else
                    StepMaybeThirdFiltered
              in
                _Filtered
    in
      StepMaybeStrmFiltered,

  // === Type + Metadata that drives the UI ===
  GetFilteredOracleViewType =
    type function (
      // Required parameters
      ViewName as (type text meta [
        Documentation.FieldCaption = "View Name",
        Documentation.FieldDescription = "Oracle view name (schema item) to read from.",
        Documentation.SampleValues = { "PS_EMAIL_FERPA_VW", "PS_VX_IR_STUDENT" }
      ]),

      // Optional parameters
      optional InstitutionValue as (type any meta [
        Documentation.FieldCaption = "Institution Value: Leave blank for default LF298",
        Documentation.FieldDescription = "Value used to filter INSTITUTION. Defaults to LF298 if null, ignored if blank, and skipped if the column doesn't exist.",
        DefaultValue = "LF298",
        Documentation.SampleValues = { "LF298" }
      ]),

      optional StrmValues as (type nullable text meta [
        Documentation.FieldCaption = "STRM Value(s): Single or comma-separated list",
        Documentation.FieldDescription = "Single term (e.g., 2241) or comma-separated list (e.g., 2241,2244,2247). Ignored if STRM column not present.",
        Documentation.SampleValues = { "2241", "2241,2244,2247" }
      ]),

      optional CustomFilter1Column as (type nullable text meta [
        Documentation.FieldCaption = "Custom Filter 1: Column",
        Documentation.FieldDescription = "Column to filter on. Only applied if both column and value are provided.",
        Documentation.SampleValues = { "NAME_TYPE" }
      ]),

      optional CustomFilter1Value as (type any meta [
        Documentation.FieldCaption = "Custom Filter 1: Value",
        Documentation.FieldDescription = "Single value or comma-separated list for custom filter 1. Only applied if both column and value are provided.",
        Documentation.SampleValues = { "PRI" }
      ]),

      optional CustomFilter2Column as (type nullable text meta [
        Documentation.FieldCaption = "Custom Filter 2: Column",
        Documentation.FieldDescription = "An additional column to filter by (only applied if both column and value are provided).",
        Documentation.SampleValues = { "EMAIL_PREFERRED", "CAMPUS" }
      ]),

      optional CustomFilter2Value as (type any meta [
        Documentation.FieldCaption = "Custom Filter 2: Value",
        Documentation.FieldDescription = "Single value or comma-separated list for custom filter 2.",
        Documentation.SampleValues = { "Y", "EA" }
      ])
    ) as table meta [
      Documentation.Name = "GetFilteredOracleView",
      Documentation.LongDescription = "Queries a table from s92qery applies up to four optional filters: INSTITUTION; STRM list; and Custom Filter 1/2 column filters."

    ],

  // Attach the type/metadata to the implementation
  GetFilteredOracleView = Value.ReplaceType(GetFilteredOracleViewImpl, GetFilteredOracleViewType)
in
  GetFilteredOracleView