---
description: 'Generate a new DAX measure from a business description using organizational standards'
name: 'new-measure'
agent: 'edit'
---

# New DAX Measure Scaffold

Generate one new DAX measure using this input:

- Measure description: ${input:measureDescription}
- Primary table context (optional): ${input:tableName}

Use these standards as the only rule sources:

- .github/instructions/naming.instructions.md
- .github/instructions/dax.instructions.md

Requirements:

- Use a business-friendly measure name in Title Case.
- Follow the standard VAR then RETURN layout.
- Use 4-space indentation.
- Put RETURN on its own line.
- Use unqualified measure references.
- Use fully qualified column references.
- Use DIVIDE() when division is involved.
- Add one comment line above the measure with the provided business description.

Output only the final DAX measure code block.
