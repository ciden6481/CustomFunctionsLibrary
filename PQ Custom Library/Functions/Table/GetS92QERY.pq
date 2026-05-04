// =============================================================================
// NAMING CONVENTION
// =============================================================================
// The function's callable name in the library is derived from its location:
//   - Folder name  → category prefix
//   - File name    → function name  (without .pq)
//
// Example:
//   File:  Functions/Date/MyFunc.pq
//   Usage: M[Date.MyFunc](args)
//
// Keep file and folder names PascalCase, no spaces.
// =============================================================================

let
    // =========================================================================
    // STEP 1 — Parameter documentation metadata
    //
    // Each parameter needs one block below. The type function signature here
    // must EXACTLY match the actual function signature in Step 3.
    //
    // To add a required parameter:   copy one [REQUIRED PARAM] block
    // To add an optional parameter:  copy one [OPTIONAL PARAM] block
    // To remove a parameter:         delete the entire block including its comma
    // =========================================================================
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
        // Optional params must come AFTER all required params.
        optional institution as (type nullable text meta [
            Documentation.FieldCaption      = "Institution filter",
            Documentation.FieldDescription  = "Instititution value to filter by (optional).",
            Documentation.SampleValues      = {"LF298"},
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ]),
        // ── [END OPTIONAL PARAM] ────────────────────────────────────────────

                // Optional params must come AFTER all required params.
        optional extractType as (type nullable text meta [
            Documentation.FieldCaption      = "Extract Type filter",
            Documentation.FieldDescription  = "Extract type value to filter by (optional).",
            Documentation.SampleValues      = {"F2"},
            Documentation.AllowedValues     = {"F2", "D"},
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ])
        // ── [END OPTIONAL PARAM] ────────────────────────────────────────────

    ) as table   // ← change the return type to match what your function actually returns
                //   common values: text, number, date, list, table, record, any

    // =========================================================================
    // STEP 2 — Function-level documentation
    // =========================================================================
    meta [
        Documentation.Name        = "Table.GetS92QERY",   // match folder.filename
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
                Description = "Describe this example.",
                Code        = "Category.FunctionName(""hello"", 42, true)",
                Result      = """expected output"""
            ]
            // Add more examples:
            // ,[
            //     Description = "Second example description.",
            //     Code        = "Category.FunctionName(""world"", 10)",
            //     Result      = """other output"""
            // ]
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
            // ── Your function logic here ──────────────────────────────────
            Source = Oracle.Database("s92qery"),
            tableFetch = Source{[Schema = "SYSADM", Item = tableName]}[Data],
            FilteredByInstitution = if HasInstitutionFilter then Table.SelectRows(tableFetch, each [INSTITUTION] = institution) else tableFetch,
            FilteredByExtractType = if HasExtractTypeFilter then Table.SelectRows(FilteredByInstitution, each [VX_IR_EXTRACT_TYPE] = extractType) else FilteredByInstitution,
            result    = FilteredByExtractType
            // ─────────────────────────────────────────────────────────────
        in
            result

in
    // Bind documentation metadata to the function (required for PQ UI tooltips)
    Value.ReplaceType(GetS92QERY, metaDocumentation)
