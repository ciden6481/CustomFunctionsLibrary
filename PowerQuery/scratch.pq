let
  Source = Table.Combine({#"2022 Data", #"2024 Data"}), 
  #"Merged Queries" = Table.NestedJoin(
    Source, 
    {"QuestionNumber"}, 
    QuestionMapping, 
    {"QuestionNumber"}, 
    "QuestionMapping", 
    JoinKind.LeftOuter
  ), 
  #"Expanded QuestionMapping" = Table.ExpandTableColumn(
    #"Merged Queries", 
    "QuestionMapping", 
    {"NewQuestionHeading", "NewQuestionSubheading", "DataType"}, 
    {"NewQuestionHeading", "NewQuestionSubheading", "DataType"}
  ), 
  #"Filtered Rows" = Table.SelectRows(#"Expanded QuestionMapping", each ([DataType] <> "Other")), 
  #"Grouped Rows" = Table.Group(
    #"Filtered Rows", 
    {"QuestionAnswer"}, 
    {
      {
        "AllRows", 
        each _, 
        type table [
          Respondent = text, 
          SurveyYear = text, 
          QuestionNumber2022 = nullable number, 
          QuestionAnswer = text, 
          QuestionNumber = nullable number
        ]
      }
    }
  ), 
  #"Sorted Rows1" = Table.Sort(#"Grouped Rows", {{"QuestionAnswer", Order.Ascending}}), 
  #"Added Answer Category Column" = Table.AddColumn(
    #"Sorted Rows1", 
    "Answer Category", 
    each 
      if List.Contains(
        {
          "Strongly Agree", 
          "Agree", 
          "Very Satisfied", 
          "Satisfied", 
          "Safe", 
          "Very Safe", 
          "Very Well", 
          "Well"
        }, 
        [QuestionAnswer]
      )
      then
        "Positive"
      else if List.Contains(
        {
          "Strongly Disagree", 
          "Disagree", 
          "Very Dissatisfied", 
          "Dissatisfied", 
          "Not At All", 
          "Not At All Safe", 
          "Not Well", 
          "Somewhat Safe"
        }, 
        [QuestionAnswer]
      )
      then
        "Negative"
      else
        null
  ), 
  #"Sorted Rows" = Table.Sort(
    #"Added Answer Category Column", 
    {{"Answer Category", Order.Descending}}
  ), 
  #"Added AllPositiveCount Column" = Table.AddColumn(
    #"Sorted Rows", 
    "AllPositiveCount", 
    each 
      if List.Contains(
        {
          "Strongly Agree", 
          "Agree", 
          "Very Satisfied", 
          "Satisfied", 
          "Safe", 
          "Very Safe", 
          "Very Well", 
          "Well", 
          "Yes"
        }, 
        [QuestionAnswer]
      )
      then
        1
      else
        null, 
    type number
  ), 
  #"Added AllNegativeCount Column" = Table.AddColumn(
    #"Added AllPositiveCount Column", 
    "AllNegativeCount", 
    each 
      if List.Contains(
        {
          "Strongly Disagree", 
          "Disagree", 
          "Very Dissatisfied", 
          "Dissatisfied", 
          "Not At All", 
          "Not At All Safe", 
          "Not Well", 
          "Somewhat Safe", 
          "No"
        }, 
        [QuestionAnswer]
      )
      then
        1
      else
        null, 
    type number
  ), 
  #"Added SomewhatPositive Column" = Table.AddColumn(
    #"Added AllNegativeCount Column", 
    "SomewhatPositive", 
    each if List.Contains({"Agree", "Satisfied", "Safe", "Well"}, [QuestionAnswer]) then 1 else null, 
    type number
  ), 
  #"Added SomewhatNegative Column" = Table.AddColumn(
    #"Added SomewhatPositive Column", 
    "SomewhatNegative", 
    each 
      if List.Contains({"Disagree", "Dissatisfied", "Not Well", "Somewhat Safe"}, [QuestionAnswer]) then
        1
      else
        null, 
    type number
  ), 
  #"Added VeryPositive Column" = Table.AddColumn(
    #"Added SomewhatNegative Column", 
    "VeryPositive", 
    each 
      if List.Contains(
        {"Strongly Agree", "Very Satisfied", "Very Safe", "Very Well"}, 
        [QuestionAnswer]
      )
      then
        1
      else
        null, 
    type number
  ), 
  #"Added VeryNegative Column" = Table.AddColumn(
    #"Added VeryPositive Column", 
    "VeryNegative", 
    each 
      if List.Contains(
        {"Strongly Disagree", "Very Dissatisfied", "Not At All", "Not At All Safe"}, 
        [QuestionAnswer]
      )
      then
        1
      else
        null, 
    type number
  ), 
  #"Expanded AllRows" = Table.ExpandTableColumn(
    #"Added VeryNegative Column", 
    "AllRows", 
    {"Respondent", "SurveyYear", "QuestionNumber2022", "QuestionNumber"}, 
    {"Respondent", "SurveyYear", "QuestionNumber2022", "QuestionNumber"}
  )
in
  #"Expanded AllRows"