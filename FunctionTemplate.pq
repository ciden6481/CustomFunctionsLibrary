/* --------------------------- Function ------------------------------ */
let
    /* --------------------------- Fucntion segment ----------------------------------- */
    output =
        (param as text ) as text  =>    // Input definition + Function output type definition: (parameter as {type of parameter})  as {type of output}            
            
            let                         // Inner function steps declaration                                                                         
                initStep = "",
                lastStep = ""
            in                          // Output from inner steps
                lastStep,                                                                    
    /* --------------------------- Documentation segment ------------------------------ */
    documentation = [
        Documentation.Name = " NAME OF FUNCTION ",              // Name of the function
        Documentation.Description = " DESCRIPTION ",            // Decription of the function
        Documentation.Source = " URL / SOURCE DESCRIPTION ",    // Source of the function
        Documentation.Version = " VERSION ",                    // Version of the function
        Documentation.Author = " AUTHOR ",                      // Author of the function
        Documentation.Examples =                                // Examples of the functions
        {
            [
                Description = " EXAMPLE DESCRIPTION ",                                  // Description of the example
                Code = " EXAMPLE CODE ",                                                // Code of the example
                Result = " EXAMPLE RESULT "                                             // Result of the example
            ]
        }
    ]
    // --------------------------- Output --------------------------------------------
in
    Value.ReplaceType(                                                                  // Replace type of the value           
        output,                                                                         // Function caller
        Value.ReplaceMetadata(                                                          // Replace metadata of the function
            Value.Type(output),                                                         // Return output type of function               
            documentation                                                               // Documentation assigment
        )
    )
// ------------------------------------------------------------------------------------






