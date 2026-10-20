// @snippet.title: AddCountyFilterColumn
// @snippet.description: Snippet for AddCountyFilterColumn.
// @snippet.tags: auto-generated

Table.AddColumn(
    PrevStep, 
    "Location", 
    each if [COUNTY] = null then "Outside Service Area"
    else if [COUNTY] = "022" then "Clarke" 
    else if [COUNTY] = "030" then "Fauquier" 
    else if [COUNTY] = "034" then "Frederick" 
    else if [COUNTY] = "068" then "Page" 
    else if [COUNTY] = "076" then "Rapphannock" 
    else if [COUNTY] = "083" then "Shenandoah" 
    else if [COUNTY] = "091" then "Warren" 
    else if [COUNTY] = "820" then "Winchester" 
    else "Outside Service Area", 
    type text 
  )