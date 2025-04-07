// --------------------------- Function ------------------------------
let
    // --------------------------- Fucntion segment -----------------------------------
    output =
    // Input definition + Function output type definition
    (
        /*parameter as text, optional opt_parameter as text*/
    )/*as text*/ =>
        // Inner function steps declaration
        let
            initStep = "", lastStep = ""
        in
            // Output from inner steps
            lastStep,
    // --------------------------- Documentation segment ------------------------------
    documentation = [
        // Name of the function
        Documentation.Name = " NAME OF FUNCTION ",
        // Decription of the function
        Documentation.Description = " DESCRIPTION ",
        // Source of the function
        Documentation.Source = " URL / SOURCE DESCRIPTION ",
        // Version of the function
        Documentation.Version = " VERSION ",
        // Author of the function
        Documentation.Author = " AUTHOR ",
        // Examples of the functions
        Documentation.Examples = {
            [
                // Description of the example
                Description = " EXAMPLE DESCRIPTION ",
                // Code of the example
                Code = " EXAMPLE CODE ",
                // Result of the example
                Result = " EXAMPLE RESULT "
            ]
        }
    ]
    // --------------------------- Output --------------------------------------------
in
    // Replace type of the value
    Value.ReplaceType(
    // Function caller
    output,
    // Replace metadata of the function
    Value.ReplaceMetadata(
    // Return output type of function
    Value.Type(output),
    // Documentation assigment
    documentation))
// ------------------------------------------------------------------------------------
