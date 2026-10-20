---
name: pq-template-adapter
description: 'Adapt a user-provided Power Query .pq file to this repository FunctionTemplate structure and output a new templated .pq file. Use when the user asks to convert, standardize, refactor, or wrap a Power Query function into the FunctionTemplate pattern in Docs/FunctionTemplate.pq. Triggers: Power Query template, .pq template conversion, FunctionTemplate, templated function metadata, Value.ReplaceType.'
argument-hint: 'Provide source .pq path; optionally provide output path and function name.'
user-invocable: true
---

# Power Query Template Adapter

Convert an attached or referenced Power Query file into a new file that follows this repository template:
[Docs/FunctionTemplate.pq](../../../Docs/FunctionTemplate.pq).

## When to Use This Skill

- User provides a `.pq` file and wants it adapted to the repository function template.
- User wants consistent function metadata and documentation shape for reusable functions.
- User asks to move ad-hoc M logic into a reusable, templated function file.

## Inputs

- Source Power Query file path (required).
- Output file path (optional; default uses source base name with `fn` prefix, such as `TermTable.pq` -> `fnTermTable.pq`).
- Desired function name (optional, but preferred).

## Step-by-Step Workflow

1. Read the source `.pq` file and identify whether it is:
   - A function query (preferred).
   - A non-function query that must be wrapped into a function.
2. Read [Docs/FunctionTemplate.pq](../../../Docs/FunctionTemplate.pq).
3. Build the output function from the template:
   - Keep template structure and metadata pattern.
   - Replace template placeholders with source-specific details.
   - Port core logic from source into the function body.
4. Apply decision logic:
   - If source is already a function: preserve parameters and return shape unless user requests changes.
   - If source is not a function: always wrap into a function, then create parameters only for true external dependencies.
   - Ask whether to keep full template metadata or minimize metadata for the specific output.
   - If source references external queries or `#shared`: prefer explicit parameters over hidden lookups.
   - If source has weak or UI-generated step names: rewrite to simple authored step names.
5. Create a new output `.pq` file. Never overwrite source unless the user explicitly asks.
6. Validate quality checks before finishing.

## Quality Checks

- Output compiles as valid M syntax.
- Output retains the template metadata structure.
- Function name is meaningful and aligned with file name.
- Parameter types and return type are explicit where practical.
- Step names are concise and readable.
- No credentials or environment-specific secrets are hardcoded.

## Gotchas

- **Do not break query dependencies silently.** If the source relies on external queries, convert those dependencies to explicit parameters and call them out.
- **Do not force metadata in scratch scenarios unless asked.** For reusable functions, keep template metadata; for exploratory code, confirm whether full metadata is wanted.
- **Date functions need correct types first.** Convert values to `type date` before calling date functions like `Date.Year`.

## Completion Output

Provide:

- New file path.
- Short summary of what changed.
- Any assumptions made (for parameters, types, or dependency injection).
- Any follow-up recommendations.
