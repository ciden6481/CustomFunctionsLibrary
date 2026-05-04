---
description: "Create a new PQ Custom Library function file from a source .pq query using FunctionTemplate, with required clarification on parameters and metadata"
name: "Create PQ Library Function"
argument-hint: "Source .pq path + target Category.FunctionName (example: PowerQuery/MapSchools.pq -> Date.SchoolYearLabel)"
agent: "agent"
tools: [vscode, execute, read, agent, edit, 'microsoftdocs/mcp/*']
---
Create a new function in this repository's PQ Custom Library from the user-provided arguments.

Primary goal:
- Create one new file under `PQ Custom Library/Functions/<Category>/<FunctionName>.pq`.
- Use `PQ Custom Library/FunctionTemplate.pq` as the structural base.
- Insert/adapt logic from the specified source `.pq` file into the template's implementation section.
- Ensure output is a reusable function with clear parameter and metadata documentation.

Before editing files, ask clarifying questions when needed. At minimum, confirm any missing items below:
1. Source query file path.
2. Target function name as `Category.FunctionName`.
3. Required parameters (names, types, and meaning).
4. Optional parameters (names, types, defaults).
5. Function description and at least one example input/output.

If the source query is not already function-shaped:
- Refactor it into a function with explicit parameters.
- Keep step names simple and readable.
- Remove hard-coded external dependencies where possible by parameterizing them.

Implementation rules:
- Follow the structure and metadata pattern from `PQ Custom Library/FunctionTemplate.pq`.
- Set `Documentation.Name` to the exact `Category.FunctionName`.
- Keep metadata beginner-friendly and specific.
- Preserve query folding friendliness where applicable.
- Return the typed function with `Value.ReplaceType(...)`.

After creating or updating the function file:
1. Run `python "PQ Custom Library/M_Creator.py"` to regenerate `PQ Custom Library/M.pq`.
2. Run a mandatory self-review before finalizing output.
3. Report exactly what was created/changed.
4. Provide a short usage example in this form: `M[Category.FunctionName](...)`.
5. If anything is ambiguous, stop and ask targeted follow-up questions instead of guessing.

Mandatory self-review checklist (always run in the same prompt execution):
1. File path and naming:
- Confirm file is in `PQ Custom Library/Functions/<Category>/<FunctionName>.pq`.
- Confirm `Documentation.Name` exactly matches `<Category>.<FunctionName>`.
2. Template conformance:
- Confirm metadata section, function-level documentation section, and implementation section are all present.
- Confirm output uses `Value.ReplaceType(<function>, metaDocumentation)`.
3. Parameter quality:
- Confirm required and optional parameters are documented with clear beginner-friendly descriptions.
- Confirm optional parameters have explicit default behavior in implementation.
4. Example quality:
- Confirm at least one realistic example exists and matches expected parameter types.
5. Reusability and safety:
- Flag hard-coded external dependencies that should be parameterized.
- Flag obvious folding-hostile operations when avoidable.
6. Loader compatibility:
- Confirm `python "PQ Custom Library/M_Creator.py"` completed and `PQ Custom Library/M.pq` was regenerated.

Required review output section:
- Add a section titled `Review Results` with:
	- `Status: PASS` or `Status: FAIL`
	- Bullet list of findings (or `No issues found`)
	- If FAIL, include exact fixes made or still required

Output style:
- Explain changes in beginner-friendly terms.
- Keep response concise but concrete.
- Include file links for every changed file.
