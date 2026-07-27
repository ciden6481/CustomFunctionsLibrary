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
        param1 as (type text meta [
            Documentation.FieldCaption      = "Parameter 1",
            Documentation.FieldDescription  = "Describe what param1 is used for.",
            Documentation.SampleValues      = {"example value"},
            // Documentation.AllowedValues  = {"Value1", "Value2"},  // uncomment to restrict
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ]),
        // ── [END REQUIRED PARAM] ────────────────────────────────────────────

        // ── [REQUIRED PARAM — copy this block to add more] ─────────────────
        param2 as (type number meta [
            Documentation.FieldCaption      = "Parameter 2",
            Documentation.FieldDescription  = "Describe what param2 is used for.",
            Documentation.SampleValues      = {42},
            // Documentation.AllowedValues  = {1, 2, 3},             // uncomment to restrict
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ]),
        // ── [END REQUIRED PARAM] ────────────────────────────────────────────

        // ── [OPTIONAL PARAM — copy or remove this block] ───────────────────
        // Optional params must come AFTER all required params.
        optional param3 as (type nullable logical meta [
            Documentation.FieldCaption      = "Parameter 3 (optional)",
            Documentation.FieldDescription  = "Describe what param3 controls. Leave blank to use the default.",
            Documentation.SampleValues      = {true, false},
            Documentation.AllowedValues     = {true, false},
            Formatting.IsMultiLine          = false,
            Formatting.IsCode               = false
        ])
        // ── [END OPTIONAL PARAM] ────────────────────────────────────────────

    ) as text   // ← change the return type to match what your function actually returns
                //   common values: text, number, date, list, table, record, any

    // =========================================================================
    // STEP 2 — Function-level documentation
    // =========================================================================
    meta [
        Documentation.Name        = "Category.FunctionName",   // match folder.filename
        Documentation.Author      = "Your Name",
        Documentation.LongDescription =
        "
            <p><b>Category.FunctionName</b></p>
            <li>One-sentence description of what this function does.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>param1</b>: Description. <code>(e.g. ""hello"")</code></li>
                <li><b>param2</b>: Description. <code>(e.g. 42)</code></li>
                <li><b>param3</b> (optional): Description. Defaults to true.</li>
            </ul>
            <b>Returns:</b> Text — describe what the output is.
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
    MyFunction = (param1 as text, param2 as number, optional param3 as nullable logical) =>
        let
            // Supply defaults for optional parameters
            useParam3 = param3 ?? true,

            // ── Your function logic here ──────────────────────────────────
            result    = param1
            // ─────────────────────────────────────────────────────────────
        in
            result

in
    // Bind documentation metadata to the function (required for PQ UI tooltips)
    Value.ReplaceType(MyFunction, metaDocumentation)
