// --------------------------- Function ------------------------------
let
    // --------------------------- Fucntion segment -----------------------------------
    output =
        (sometext as text/* parameter as text, optional opt_parameter as text */) as number/* as text */ =>      // Input definition + Function output type definition
            let                                                                         // Inner function steps declaration
                initStep = Text.Length(sometext),
                lastStep = initStep * 2
            in
                lastStep,                                                               // Output from inner steps     
    // --------------------------- Documentation segment ------------------------------
    documentation = [
        Documentation.Name = " Double String Count ",                                      // Name of the function
        Documentation.Description = " This function doubles the number of characters in the string ",                                    // Decription of the function
        Documentation.LongDescription = "A longer description of the function",                // Long description of the function
        Documentation.Source = " Source URL ",                            // Source of the function
        Documentation.Version = " ver ",                                            // Version of the function
        Documentation.Author = " who, me? ",                                              // Author of the function
        Documentation.Examples =                                                        // Examples of the functions
        {
            [
                Description = " EXAMPLE DESCRIPTION ",                                  // Description of the example
                Code = " 'fn(sometext)' ",                                                // Code of the example
                Result = " 8 "                                             // Result of the example
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






