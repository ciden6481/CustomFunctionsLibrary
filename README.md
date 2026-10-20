# CustomFunctionsLibrary

Power Query (M) helpers, DAX snippets, and reusable modules for rapid authoring and reuse in Power BI and data workflows.

## Project Name and Description

- **Name:** CustomFunctionsLibrary
- **Purpose:** A curated collection of Power Query M (.pq/.m) helpers, DAX snippets, and templated functions designed to speed up authoring, encourage consistent patterns, and provide reusable building blocks for ad-hoc queries and productionized library code.

## Technology Stack

- Power Query M (`.pq`, `.m`) — primary authoring language for functions and snippets.
- DAX (`.dax`) — example measures and generator helpers.
- PowerShell (`.ps1`) — automation scripts for generating indexes and validating metadata.
- Git / GitHub — source control and collaboration.
- Optional tooling: Power Query SDK / MakePQX (for connector/packaging workflows).

## Project Architecture

This repository is organized as a focused content library rather than a monolithic application. Key elements:

- `Docs/` — templates, coding guidance, and the canonical `FunctionTemplate.pq` used when converting ad-hoc logic into reusable functions.
- `Snippets/` — small, focused `.pq` snippets and templated functions (the working library).
- `Reference/` — example libraries, external snippets, and DAX helpers.
- `PowerQuery/` — in-progress or working queries.
- `scripts/` — automation for documentation and metadata maintenance.

Diagram (logical):

Power Query authors → create/edit snippets → `Snippets/` → metadata scripts → `Snippets/README.md`

## Getting Started

Prerequisites:

- Windows or environment able to run PowerShell scripts.
- Power BI Desktop or the Power Query SDK to test M code interactively.

Clone and prepare:

```powershell
git clone https://github.com/<your-org>/CustomFunctionsLibrary.git
cd CustomFunctionsLibrary

# Regenerate the snippets index (auto-updates Snippets/README.md)
./scripts/update-snippets-readme.ps1

# Validate snippet metadata headers
./scripts/validate-snippet-metadata.ps1
```

Authoring tips:

- Start with `Docs/FunctionTemplate.pq` when you convert ad-hoc logic into a reusable function.
- Keep environment-specific values out of repository code — use parameters.

## Project Structure

- `Docs/` — documentation, templates, and guidance.
- `Snippets/` — Power Query snippets and templated functions (index at `Snippets/README.md`).
- `PowerQuery/` — work-in-progress queries.
- `Reference/` — prior libraries, examples, DAX snippets.
- `scripts/` — `update-snippets-readme.ps1`, `validate-snippet-metadata.ps1`.

## Key Features

- Canonical function template (`Docs/FunctionTemplate.pq`) to standardize metadata and UI tooltips.
- Automated snippets index generation and metadata validation via PowerShell scripts.
- Collections of small, composable Power Query snippets for common ETL patterns.

## Development Workflow

1. Iterate in `Ad-Hoc Queries/` or `PowerQuery/` while you prototype.
2. When a snippet is stable, add it to `Snippets/` and include header metadata comments (`// @snippet.title`, `// @snippet.description`, `// @snippet.tags`).
3. Run `./scripts/update-snippets-readme.ps1` to refresh the index and `./scripts/validate-snippet-metadata.ps1` before opening a PR.

## Coding Standards

- Use `PascalCase` for file names, function names, and step names.
- Include `Value.ReplaceType` metadata for reusable functions so the Power Query UI shows helpful documentation.
- Define parameter metadata blocks exactly as shown in `Docs/FunctionTemplate.pq`.
- Convert columns to correct types before calling type-specific functions (e.g., `Date.Year`).

## Testing

- This repository does not include automated unit tests for M or DAX. Validation focuses on metadata and documentation quality.
- Use these scripts to check repository hygiene:

```powershell
./scripts/update-snippets-readme.ps1
./scripts/validate-snippet-metadata.ps1
```

If you have a Power Query SDK / MakePQX workflow, run its compile step separately (not included here).

## Contributing

- Add new snippets in `Snippets/Power Query/` or `Snippets/Power Query/Templated Functions/`.
- Add or update header metadata comments at the top of `.pq` files:

```m
// @snippet.title: MySnippetName
// @snippet.description: One-line description of the snippet's purpose.
// @snippet.tags: power-query,snippet
```

- Run the index and validation scripts, then open a PR with your changes.

## License

No license file is included in this repository. Add a `LICENSE` file if you want to grant explicit reuse rights.

---

See also: [Docs/FunctionTemplate.pq](Docs/FunctionTemplate.pq) and [Snippets/README.md](Snippets/README.md)

If you want, I can expand this into a longer blueprint README with examples and rendered diagrams.