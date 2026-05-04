---
agent: agent
description: Evaluate a Power Query file, rename steps for clarity, and add concise step comments.
tools: [execute, read, agent, edit, search, 'microsoftdocs/mcp/*', 'pqlint-mcp/*']
---

# Power Query Step Clarity Pass

Refactor a Power Query M query for readability without changing behavior.

## Inputs
- Target file: ${input:filePath}
- Optional focus: ${input:focus}

If `filePath` is empty, use the currently active `.pq` or `.m` file.
If `focus` is empty, process the full query.

## Tasks
1. Read the target query and identify the full transformation flow.
2. Rename step identifiers to clear, authored names that describe intent.
3. Replace UI-style or unclear names with concise names when safe.
4. Add short comments that explain each step's purpose.
5. Preserve query logic, output schema, and folding-friendly ordering.
6. Keep existing parameter/function signatures unchanged unless explicitly requested.

## Naming Rules
- Prefer names like `FilteredRows`, `SelectedColumns`, `TypedColumns`, `AddedFlags`, `RenamedColumns`, `Result`.
- Use quoted step names only when required by identifier rules.
- Keep names short and consistent.

## Comment Rules
- Add one concise comment per logical step or phase.
- Explain intent, not mechanics.
- Avoid redundant comments.

## Output Format
Return:
1. The updated query.
2. A short change summary of renamed steps.
3. Any warnings if a referenced identifier appears undefined.

## Quality Checks
- Query still has a valid `let ... in ...` structure.
- Final `in` points to the intended final step.
- No accidental logic changes.
- No unnecessary formatting-only edits outside renamed/commented lines.
