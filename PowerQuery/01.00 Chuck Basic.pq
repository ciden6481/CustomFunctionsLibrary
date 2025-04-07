let
    Source = Json.Document(
        Web.Contents(
            "https://api.chucknorris.io/jokes/random"
        )
    )
in
    Source