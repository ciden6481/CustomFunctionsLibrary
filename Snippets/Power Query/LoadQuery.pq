// @snippet.title: LoadQuery
// @snippet.description: Loads and evaluates a .pq or .m query file from a root path.
// @snippet.tags: power-query,snippet,expression-evaluate,file-contents

(queryName as text, optional rootPath as text) =>
    let
        // Ensure BasePath always ends with a backslash
        RawBasePath = if rootPath <> null then rootPath else "C:\Users\ciden\OneDrive - laurelridge.edu\Documents\Coding\CustomFunctionsLibrary\Ad-Hoc Queries\",
        BasePath = if Text.EndsWith(RawBasePath, "\") then RawBasePath else RawBasePath & "\",
        // Check if queryName already has .pq or .m extension
        HasValidExtension =
            Text.EndsWith(queryName, ".pq", Comparer.OrdinalIgnoreCase)
            or Text.EndsWith(queryName, ".m", Comparer.OrdinalIgnoreCase),
        // Resolve file content
        FileBinary =
            if HasValidExtension then
                File.Contents(BasePath & queryName)
            else
                // If no extension is specified, look for .pq first, then .m
                let
                    TryPQ = try File.Contents(BasePath & queryName & ".pq"),
                    Resolved = if TryPQ[HasError] then File.Contents(BasePath & queryName & ".m") else TryPQ[Value]
                in
                    Resolved,
        SourceText = Text.FromBinary(Binary.Buffer(FileBinary)),
        Evaluated = Expression.Evaluate(SourceText, #shared)
    in
        Evaluated
