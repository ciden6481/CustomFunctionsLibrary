#Replace academic plans
Code assumes that [all_plans_by_latest_effdt](all_plans_by_latest_effdt.md) has already been run

```
//Replaces degree for old acadplans
#"Replaced Value" = Table.ReplaceValue(Source,each [DEGREE], each if Text.StartsWith([DESCR],"Liberal Arts") then "AA" else if [DESCR] = "Business Administration" or [DESCR] = "Science: Computer Science" or [DESCR] = "Education" or [DESCR] = "General Studies" or [DESCR] = "Science: Health Professions" or [DESCR] = "Gen Studies: Admin of Justice" then "AS" else [DEGREE],Replacer.ReplaceText,{"DEGREE"}),

//Replaces old acadplans with new names after degree has been fixed
#"Replaced Value1" = Table.ReplaceValue(#"Replaced Value",each [DESCR], each if [DESCR] = "Gen Studies: Admin of Justice" then "Social Sci Criminal Justice" else if [DESCR] = "Science: Health Professions" then "Health Sciences" else if [DESCR] = "Science: Computer Science" then "Computer Science" else [DESCR],Replacer.ReplaceText,{"DESCR"}),

//Fixes null degree values
#"Replaced Value2" = Table.ReplaceValue(#"Replaced Value1",null,"Non-degree",Replacer.ReplaceValue,{"DEGREE"})
```
