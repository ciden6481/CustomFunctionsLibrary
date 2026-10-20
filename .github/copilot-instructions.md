# Copilot instructions for CustomFunctionsLibrary
This repository contains Power Query (M) helpers, DAX snippets, and reusable modules.
Follow these instructions to choose the right source files and apply consistent query-development behavior.

## Big picture
Use folders by intent.

### [Docs](../Docs/)
Primary internal documentation for Power Query concepts, patterns, and guidance.
- Consult this folder first.
- Prefer these patterns over external examples.

### [Reference](../Reference/)
A catch-all reference area containing prior work, external libraries, and collected examples.
- Reuse ideas from here, but verify before applying.
- Treat this folder as non-authoritative by default.
- `Other Libraries/` is for inspiration and comparison, not source of truth.

### [Ad-Hoc Queries](../Ad-Hoc Queries/)
Scratch workspace for developing and formatting queries that are pasted into Power Query.
- Expect frequent edits and experimentation.
- Optimize for fast iteration and clear debugging.

### [Snippets](../Snippets/)
Reusable snippets created specifically for this user's work.
- Prefer this folder for reusable building blocks.
- Adapt snippets from here before using broader reference sources.
- When creating or editing snippet `.pq` files, include or update header metadata comments:
	- `// @snippet.title: ...`
	- `// @snippet.description: ...`
	- `// @snippet.tags: ...` (optional)

## Project-specific conventions and patterns
- Use `.pq` for M files and `.dax` for DAX files.
- Replace hidden external dependencies with explicit function parameters where practical.
- Avoid `#shared` lookups in reusable query logic.
- Treat connection names as environment-specific and never hardcode credentials.

## Concrete examples and quick fixes
- Convert columns to `type date` before calling date functions such as `Date.Year(...)`.

## Useful files to consult
- Start with `Docs/`.
- Use `microsoft_docs_search` and `microsoft_docs_fetch` for current Microsoft documentation when needed.
- Use `microsoft_code_sample_search` for sample code.
- Use `Reference/` for additional patterns, then validate.
- Use `Snippets/` for work-specific reusable logic.

## Workflow
### Ad-hoc query development and debugging
- Assume external queries are pasted into `Ad-Hoc Queries/` for iteration.
- Focus on debugging, refactoring, and formatting for paste-back into Power Query.
- Explain fixes clearly and include likely root causes.
- Proactively suggest practical improvements to logic, syntax, and performance.

### Snippet reuse and refinement
- Store reusable, work-specific patterns in `Snippets/`.
- When ad-hoc logic becomes reusable, suggest promoting it to `Snippets/`.
- Prefer small, composable snippets with simple step names.
- After snippet changes, refresh `Snippets/README.md` via `scripts/update-snippets-readme.ps1`.


