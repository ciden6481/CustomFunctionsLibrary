let
    metaDocumentation = type function (

        // ── [REQUIRED PARAM — copy this block to add more] ─────────────────
        tableName as (type text meta [
            Documentation.FieldCaption      = "Table Name",
            Documentation.FieldDescription  = "Name of the table to retrieve.",
            Documentation.SampleValues      = {"PS_VX_IR_STUDENT"},
            // Documentation.AllowedValues  = {"Value1", "Value2"},  // uncomment to restrict
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ]),
        // ── [END REQUIRED PARAM] ────────────────────────────────────────────

        // ── [OPTIONAL PARAM — copy or remove this block] ───────────────────
        optional institution as (type nullable text meta [
            Documentation.FieldCaption      = "Institution filter",
            Documentation.FieldDescription  = "Instititution value to filter by (optional).",
            Documentation.SampleValues      = {"LF298"},
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ]),
        optional extractType as (type nullable text meta [
            Documentation.FieldCaption      = "Extract Type filter",
            Documentation.FieldDescription  = "Extract type value to filter by (optional).",
            Documentation.SampleValues      = {"F2"},
            Documentation.AllowedValues     = {"F2", "D"},
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ])
        // ── [END OPTIONAL PARAM] ────────────────────────────────────────────

    ) as table   

    // =========================================================================
    // STEP 2 — Function-level documentation
    // =========================================================================
    meta [
        Documentation.Name        = "Table.GetS92QERY",   
        Documentation.Author      = "Win Iden",
        Documentation.LongDescription =
        "
            <p><b>Table.GetS92QERY</b></p>
            <li>Queries S92QERY for the specified table.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>tableName</b>: Table name. <code>(e.g. ""PS_VX_IR_STUDENT"")</code></li>
                <li><b>institution</b> (optional): Filter by institution. Defaults to no filter.</li>
                <li><b>extract_type</b> (optional): Filter by extract type. Defaults to no filter.</li>
            </ul>
            <b>Returns:</b> Requested table from S92QERY.
        ",
        Documentation.Examples = {
            [
                Description = "Import PS_VX_IR_STUDENT table filtered by LF298 institution and F2 extract type.",
                Code        = "Table.GetS92QERY(""PS_VX_IR_STUDENT"", ""LF298"", ""F2"")",
                Result      = """Filtered student table"""
            ]
                    }
    ],

    // =========================================================================
    // STEP 3 — Function implementation
    //
    // The parameter names and types here must EXACTLY match Step 1.
    //   - Required params:  (param1 as type, param2 as type)
    //   - Optional params:  (optional param3 as nullable type)
    //
    // Use ?? to supply defaults for optional parameters:
    //   myDefault = param3 ?? true
    // =========================================================================
    GetS92QERY = (tableName as text, optional institution as nullable text, optional extractType as nullable text) =>
        let
            HasInstitutionFilter = institution <> null and Text.Trim(institution) <> "",
            HasExtractTypeFilter = extractType <> null and Text.Trim(extractType) <> "",
            Source = Oracle.Database("s92qery"),
            tableFetch = Source{[Schema = "SYSADM", Item = tableName]}[Data],
            FilteredByInstitution = if HasInstitutionFilter then Table.SelectRows(tableFetch, each [INSTITUTION] = institution) else tableFetch,
            FilteredByExtractType = if HasExtractTypeFilter then Table.SelectRows(FilteredByInstitution, each [VX_IR_EXTRACT_TYPE] = extractType) else FilteredByInstitution,
            result = FilteredByExtractType
        in
            result

in
    // Bind documentation metadata to the function (required for PQ UI tooltips)
    Value.ReplaceType(GetS92QERY, metaDocumentation)
