---
description: 'Adapt a referenced or attached Power Query .pq file into the repository FunctionTemplate and write the new function file to Functions/Templated.'
name: 'Adapt PQ to Function Template'
argument-hint: 'Provide source .pq path; optional function name and metadata preference.'
agent: 'agent'
---

# Adapt PQ to Function Template

## Mission

Use the `pq-template-adapter` skill to convert a source `.pq` file into a new templated function file.

## Scope and Preconditions

- Source file is a Power Query `.pq` file provided by path or attachment.
- Output destination policy is strict: write output to `Functions/Templated/`.
- Do not overwrite existing source file unless the user explicitly asks.

## Inputs

- Source path: ${input:sourcePath:Path to source .pq file}
- Function name (optional): ${input:functionName:Optional function name without fn prefix}
- Metadata preference: ${input:metadataMode:full|minimal|ask}

If `sourcePath` is missing, stop and ask for it.

## Workflow

1. Load and follow the `pq-template-adapter` skill.
2. Read `Docs/FunctionTemplate.pq` and the source `.pq` file.
3. Determine target function filename:
- If `functionName` is provided, use `fn${input:functionName}.pq`.
- If `functionName` is not provided, prepend `fn` to source base name.
4. Set output path to `Functions/Templated/<target-file-name>.pq`.
5. Adapt source logic into template structure.
6. If source is not a function, wrap it into a function and parameterize true external dependencies.
7. Apply metadata behavior:
- `full`: keep full template metadata.
- `minimal`: reduce metadata while keeping a valid typed function shape.
- `ask`: ask the user before finalizing.
8. Keep step names simple and authored (avoid verbose UI-generated names).
9. Preserve source behavior unless a change is needed for templating, typing, or dependency injection.

## Output Expectations

- Exactly one new output file in `Functions/Templated/`.
- Brief summary of:
- output file path
- assumptions made
- dependency/parameter changes
- metadata mode used

## Quality Assurance

Before final response, confirm all checks:

- Output file path is under `Functions/Templated/`.
- Filename starts with `fn` and ends with `.pq`.
- Result follows `Docs/FunctionTemplate.pq` structure.
- Function is typed and valid Power Query M syntax.
- External dependencies are explicit parameters when practical.
- No credentials or environment-specific secrets are hardcoded.
