---
description: 'Scaffold layered Power Query queries for a new entity using organizational standards'
name: 'new-pq-query'
agent: 'edit'
---

# New Power Query Layered Scaffold

Generate layered queries using this input:

- Entity name: ${input:entityName}
- Layer type: ${input:layerType}

If layer type is missing or unclear, ask whether the final query should be Dim or Fact before generating output.

Use these standards as the only rule sources:

- .github/instructions/power-query.instructions.md
- .github/instructions/naming.instructions.md

Generate these three queries:

1. Src{EntityName}
2. Stg{EntityName}
3. {Dim|Fact}{EntityName}

Use a standard let/in structure with named steps such as Source, KeepNeededColumns, FilterActiveRows, RenameColumns, and ChangeTypes.

Use PascalCase action-oriented step names.

Include brief placeholder comments where the developer should customize business-specific logic.

Output only the generated M code for all three queries.
