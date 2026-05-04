/* --------------------------- Function Template ------------------------------

How to use this template

1. Edit only sections marked USER EDIT START / USER EDIT END.
2. Update the output function signature to match your parameters.
3. Put your real function logic in the FUNCTION BODY section.
4. Update parameterTypes so it matches the same parameters and order.
5. Set requiredParameterCount to the number of leading required parameters.
6. Set returnType to the actual output type of the function.
7. Add or remove parameter metadata records as needed:
   - Documentation.FieldCaption
   - Documentation.FieldDescription
   - Documentation.SampleValues
   - Documentation.AllowedValues
   - DefaultValue
8. Keep optional parameters after required parameters.

Important notes

- The output function signature and parameterTypes must match.
- Parameter metadata is applied through functionType, not directly on the implementation.
- This template is flexible for authoring different functions, but one final function
  still has a fixed parameter list.

Example sync pattern

output =
    (requiredParam as any, optional optionalParam as nullable any) as any => ...

parameterTypes = [
    requiredParam = type any meta [...],
    optionalParam = type nullable any meta [...]
]

requiredParameterCount = 1

-------------------------------------------------------------------------- */
let
    /* --------------------------- Function segment --------------------------- */
    // USER EDIT START: FUNCTION SIGNATURE
    output =
        (
            requiredParam as any,
            optional optionalParam as nullable any
        )
    // USER EDIT END: FUNCTION SIGNATURE
        as any =>
            // USER EDIT START: FUNCTION BODY
            // Put your actual transformation logic here.
            // The value returned by this inner "in" is the function output.
            let
                initStep = requiredParam,
                result = initStep
            in
                result,
            // USER EDIT END: FUNCTION BODY

    /* --------------------------- Parameter type segment --------------------- */
    // USER EDIT START: PARAMETER METADATA (must match signature names/order)
    parameterTypes = [
        requiredParam = type any meta [
            Documentation.FieldCaption = "Required Parameter",
            Documentation.FieldDescription = "Describe what this required parameter is used for.",
            Documentation.SampleValues = {"sample"}
        ],
        optionalParam = type nullable any meta [
            Documentation.FieldCaption = "Optional Parameter",
            Documentation.FieldDescription = "Describe what this optional parameter controls.",
            DefaultValue = null,
            Documentation.SampleValues = {null, "sample"}
        ]
    ],
    // USER EDIT END: PARAMETER METADATA

    // USER EDIT START: TYPE SETTINGS
    requiredParameterCount = 1,
    returnType = type any,
    // USER EDIT END: TYPE SETTINGS

    functionType =
        Type.ForFunction(
            [
                ReturnType = returnType,
                Parameters = parameterTypes
            ],
            requiredParameterCount
        ),

    /* --------------------------- Documentation segment ---------------------- */
    // USER EDIT START: FUNCTION DOCUMENTATION
    documentation = [
        Documentation.Name = "FUNCTION.NAME",
        Documentation.Description = "Short description of what the function returns.",
        Documentation.LongDescription = "Longer description of behavior, assumptions, and edge-case handling.",
        Documentation.Source = "SOURCE OR URL",
        Documentation.Version = "1.0.0",
        Documentation.Author = "AUTHOR NAME",
        Documentation.Examples = {
            [
                Description = "Describe an example invocation.",
                Code = "FUNCTION.NAME(requiredParamValue, optionalParamValue)",
                Result = "Expected result"
            ]
        }
    ]
    // USER EDIT END: FUNCTION DOCUMENTATION

/* --------------------------- Output ---------------------------------------- */
in
    Value.ReplaceType(
        output,
        Value.ReplaceMetadata(
            functionType,
            documentation
        )
    )