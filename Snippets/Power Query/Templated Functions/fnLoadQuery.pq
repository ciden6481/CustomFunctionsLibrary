// @snippet.title: fnLoadQuery
// @snippet.description: Loads and evaluates a .pq or .m query file from a specified folder.
// @snippet.tags: power-query,function,template,expression-evaluate,file-contents
let
    metaDocumentation = type function (
        queryName as (
            type text meta [
                Documentation.FieldCaption = "Query Name",
                Documentation.FieldDescription = "The file name to load, with or without the .pq or .m extension.",
                Documentation.SampleValues = {"stgSTRM", "stgSTRM.pq"},
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        ),
        optional rootPath as (
            type text meta [
                Documentation.FieldCaption = "Root Path",
                Documentation.FieldDescription = "The folder path containing the query files, defaults to C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Coding\CustomFunctionsLibrary\Ad-Hoc Queries\",
                Documentation.SampleValues = {
                    "C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Coding\CustomFunctionsLibrary\Ad-Hoc Queries\"
                },
                Formatting.IsMultiLine = false,
                Formatting.IsCode = false
            ]
        )
    ) as any meta [
        Documentation.Name = "fnLoadQuery",
        Documentation.Author = "Win Iden",
        Documentation.LongDescription = "
            <p><b>fnLoadQuery</b></p>
            <li>Loads a Power Query file from disk and evaluates it as M code.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>queryName</b>: Query file name, with or without extension.</li>
                <li><b>rootPath</b>: Folder where the query file is stored.</li>
                <li><b>sharedEnvironment</b> (optional): Evaluation environment record. Defaults to <code>#shared</code>.</li>
            <b>Returns:</b> The evaluated result from the query file.
        ",
        Documentation.Examples = {
            [
                Description = "Load a query by name without extension.",
                Code = "fnLoadQuery(""stgSTRM"", ""C:\Queries\"", null)",
                Result = "<evaluated result>"
            ],
            [
                Description = "Load a query file by explicit extension.",
                Code = "fnLoadQuery(""stgSTRM.pq"", ""C:\Queries\"", null)",
                Result = "<evaluated result>"
            ]
        }
    ],
    fnLoadQuery = (queryName as text, optional rootPath as text) =>
        let
            RawBasePath =
                if rootPath <> null then
                    rootPath
                else
                    "C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Coding\CustomFunctionsLibrary\Ad-Hoc Queries\",
            BasePath = if Text.EndsWith(RawBasePath, "\") then RawBasePath else RawBasePath & "\",
            HasValidExtension =
                Text.EndsWith(queryName, ".pq", Comparer.OrdinalIgnoreCase)
                or Text.EndsWith(queryName, ".m", Comparer.OrdinalIgnoreCase),
            FileBinary =
                if HasValidExtension then
                    File.Contents(BasePath & queryName)
                else
                    let
                        TryPQ = try File.Contents(BasePath & queryName & ".pq"),
                        Resolved = if TryPQ[HasError] then File.Contents(BasePath & queryName & ".m") else TryPQ[
                            Value
                        ]
                    in
                        Resolved,
            SourceText = Text.FromBinary(Binary.Buffer(FileBinary)),
            Evaluated = Expression.Evaluate(SourceText, #shared)
        in
            Evaluated
in
    Value.ReplaceType(fnLoadQuery, metaDocumentation)
