// A pattern for constructing a direct file access query in Sharepoint using SharePoint.Contents rather than SharePoint.Files. This pattern is more efficient than SharePoint.Files because it avoids the need to enumerate all files in the site, which can be slow for large sites. Instead, it navigates directly to the desired file by traversing the folder hierarchy.
let
    Source = SharePoint.Contents(
        "https://laurelridgeedu.sharepoint.com/sites/InstitutionalResearch-group", [ApiVersion = 15]
    ),
    Shared_Documents = Source{[Name = "Shared Documents"]}[Content],
    General = Shared_Documents{[Name = "General"]}[Content],
    DE_Snapshots = General{[Name = "DE Snapshots"]}[Content],
    DOE_Fall_Membership = DE_Snapshots{[Name = "DOE Fall Membership"]}[Content],
    RaceStatsFile = DOE_Fall_Membership{[Name = "fall_membership_statistics_race.csv"]}[Content],
    FileContent = Csv.Document(
        RaceStatsFile, [Delimiter = ",", Columns = 59, Encoding = 65001, QuoteStyle = QuoteStyle.None]
    )
in
    FileContent
