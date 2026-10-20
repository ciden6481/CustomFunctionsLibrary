// @snippet.title: fnJurisToCounty
// @snippet.description: Snippet for fnJurisToCounty.
// @snippet.tags: auto-generated

//invoke via add column
let
    Source = (County as nullable text) as text =>
        if County = "022" then
            "Clarke"
        else if County = "030" then
            "Fauquier"
        else if County = "034" then
            "Frederick"
        else if County = "068" then
            "Page"
        else if County = "076" then
            "Rapphannock"
        else if County = "083" then
            "Shenandoah"
        else if County = "091" then
            "Warren"
        else if County = "820" then
            "Winchester"
        else
            "Outside Service Area"
in
    Source
