(SharePointUrl as text, optional ApiVersion as nullable number) as binary =>
let
    // Default to SharePoint API version 15.
    APIVersion =
        if ApiVersion = null
        then 15
        else ApiVersion,

    // Parse the URL. Uri.Parts separates the query string automatically.
    UrlParts = Uri.Parts(SharePointUrl),

    HostRoot =
        UrlParts[Scheme] & "://" & UrlParts[Host],

    EncodedPathSegments =
        List.Select(
            Text.Split(
                Text.Trim(UrlParts[Path], "/"),
                "/"
            ),
            each _ <> ""
        ),

    // Sharing links begin with segments such as:
    // :x: / r / sites / SiteName / ...
    //
    // Remove the sharing-link prefix when present.
    NormalizedEncodedSegments =
        if
            List.Count(EncodedPathSegments) >= 2
            and Text.StartsWith(EncodedPathSegments{0}, ":")
            and EncodedPathSegments{1} = "r"
        then
            List.Skip(EncodedPathSegments, 2)
        else
            EncodedPathSegments,

    // M has no built-in percent-decoder, so decode %XX (and +) manually via raw UTF-8 bytes.
    UriUnescapeDataString =
        (EncodedText as text) as text =>
            let
                TextToBytes = (SegmentText as text) as list => Binary.ToList(Text.ToBinary(SegmentText, TextEncoding.Utf8)),
                HexDigits = "0123456789ABCDEF",
                HexByteToNumber =
                    (HexPair as text) as number =>
                        let
                            UpperHexPair = Text.Upper(HexPair),
                            HighDigit = Text.PositionOf(HexDigits, Text.Start(UpperHexPair, 1)),
                            LowDigit = Text.PositionOf(HexDigits, Text.End(UpperHexPair, 1))
                        in
                            if
                                Text.Length(HexPair) <> 2
                                or HighDigit < 0
                                or LowDigit < 0
                            then
                                error Error.Record(
                                    "Invalid percent-encoding",
                                    "A percent-encoded path segment contains an invalid hexadecimal byte.",
                                    [EncodedByte = HexPair]
                                )
                            else
                                HighDigit * 16 + LowDigit,
                NormalizedText = Text.Replace(EncodedText, "+", " "),
                Segments = Text.Split(NormalizedText, "%"),
                FirstSegmentBytes = TextToBytes(Segments{0}),
                RemainingSegmentBytes =
                    List.Transform(
                        List.Skip(Segments, 1),
                        each {HexByteToNumber(Text.Start(_, 2))} & TextToBytes(Text.Range(_, 2))
                    ),
                AllBytes = List.Combine({FirstSegmentBytes} & RemainingSegmentBytes)
            in
                Text.FromBinary(Binary.FromList(AllBytes), TextEncoding.Utf8),

    // Decode %20 and other URL-encoded characters separately.
    PathSegments =
        List.Transform(
            NormalizedEncodedSegments,
            each UriUnescapeDataString(_)
        ),

    // Locate either:
    // sites / SiteName
    // teams / TeamName
    SiteMarkerPosition =
        List.PositionOfAny(
            PathSegments,
            {"sites", "teams"}
        ),

    ValidateSite =
        if
            SiteMarkerPosition < 0
            or List.Count(PathSegments) < SiteMarkerPosition + 3
        then
            error Error.Record(
                "Invalid SharePoint URL",
                "The URL does not contain a recognizable SharePoint site and file path.",
                [
                    URL = SharePointUrl,
                    ExpectedPath = "/sites/SiteName/Library/.../File"
                ]
            )
        else
            null,

    SiteUrl =
        HostRoot
            & "/"
            & Text.Combine(
                List.Range(
                    PathSegments,
                    SiteMarkerPosition,
                    2
                ),
                "/"
            ),

    // Library, folders, and filename after the site root.
    RelativePath =
        List.Skip(
            PathSegments,
            SiteMarkerPosition + 2
        ),

    ValidateFilePath =
        if List.IsEmpty(RelativePath) then
            error Error.Record(
                "Missing file path",
                "The URL identifies a SharePoint site but not a file.",
                [URL = SharePointUrl]
            )
        else
            null,

    Source =
        SharePoint.Contents(
            SiteUrl,
            [ApiVersion = APIVersion]
        ),

    // Walk through:
    // Library -> folder -> subfolder -> file.
    Result =
        List.Accumulate(
            RelativePath,
            Source,
            (CurrentContent as any, CurrentName as text) as any =>
                if not Value.Is(CurrentContent, type table) then
                    error Error.Record(
                        "Unexpected navigation result",
                        "A binary value was reached before the complete path was processed.",
                        [PathSegment = CurrentName]
                    )
                else
                    let
                        MatchingRows =
                            Table.SelectRows(
                                CurrentContent,
                                each [Name] = CurrentName
                            ),

                        NextContent =
                            if Table.IsEmpty(MatchingRows) then
                                error Error.Record(
                                    "SharePoint path not found",
                                    "The specified library, folder, or file was not found.",
                                    [
                                        PathSegment = CurrentName,
                                        Site = SiteUrl
                                    ]
                                )
                            else
                                MatchingRows{0}[Content]
                    in
                        NextContent
        ),

    ValidateBinary =
        if not Value.Is(Result, type binary) then
            error Error.Record(
                "File binary not returned",
                "The URL appears to identify a folder rather than a file.",
                [URL = SharePointUrl]
            )
        else
            Result
in
    ValidateBinary
