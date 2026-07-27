# Copilot instructions for CustomFunctionsLibrary
This repository is a collection of Power Query (M) helpers, DAX snippets, and reusable modules. The goal of these instructions is to help AI coding agents be immediately productive by focusing on project conventions, common workflows, and concrete examples from the codebase.

## Big picture
This repository and the files within serve three main purposes.

### [Reference library](../Reference/)
Reusable Power Query and DAX code, patterns, and modules that can be re-used across projects by adapting them to the specific needs of each query.
    - The files in `DAX/`, `PowerQuery/`, and `Snippets/` represent possible reference files for reusable code, patterns and modules developed over time and are specific to the tables and sources often used in the projects. These may or may not represent the best logic or processes as they are not often updated.
    - The `Other Libraries/` directory contains code copied from other sources that may be useful for reference, but should not be considered authoritative or up-to-date.
### [Ad-hoc Development](../Ad-Hoc Queries/)
A staging and development area for ad-hoc queries that will ultimately be used in external files.
    - The `Ad-Hoc Queries/` directory is the main working area for developing and refining queries that will be copied to external files. These files are expected to change frequently and represent the primary interface for query development.
### [Power Query Custom Function Libarary](../Functions/)
More up-to-date and reusable Power Query M functions and snippets, often developed from ad-hoc queries or the Reference library, that have been refined and optimized for reusability. These should be considered the most authoritative and up-to-date source for reusable Power Query M functions and snippets.

## Project-specific conventions and patterns
- File extension: use `.pq` for M-language files and `.dax` for DAX queries and files.
- Query references: many queries expect external queries or references. When refactoring, inject such dependencies as parameters rather than using `#shared` lookups.
- SQL sources: queries commonly call `Sql.Database("IAAS-INSTANTID\\CARDS", "DATA")`  Treat connection names as environment-specific and avoid hardcoding credentials.

## Concrete examples and quick fixes
- Example bug pattern: calling `Date.Year(...)` before converting columns to `type date`. 

## Useful files to consult
- `Docs` — These files contain documentation and reference materials for Power Query and other relevant topics.
- You have access to current microsoft documentation via `microsoft_docs_search` and `microsoft_docs_fetch` when additional official documentation is needed.
- Sample code can be examined or referenced using `microsoft_code_sample_search`
- A collection of potentially useful Power Query and DAX libraries, code patterns and queries has been compiled and can be used to reference, though the previously mentioned tools and `Docs` will always take precedence:
    - `Other Libraries/` - reusable M modules and DAX snippets copied directly from other sources.
    - `PowerQuery/`, `Snippets/` — working queries and examples used previously that may be useful or similar logic needed.
    - `DAX/` — DAX utilities and generated expressions (e.g. `DAX/TermCalendarTable.dax`).

## Workflow
### Ad-hoc query development and debugging
- Typically, a query will be pasted from an external source in to one of the `Ad-Hoc Queries/` files. The AI agent will then assist in debugging, refining, and optimizing the query.
- Assume that the query will be copied back to the original file and the results, including any relevant error messages or other problems, will be shared with the AI agent for further assistance.
- The AI agent will provide guidance on how to fix issues, optimize performance, and ensure that the query adheres to project conventions and patterns.
- Any improvements to logic, syntax, performance or efficiency that are not specifically asked for should be suggested as part of the assistance.
### Power Query Custom Function Libarary development
- Files developed in the `Functions/` directory are expected to be more stable and reusable across projects, so the AI agent should focus on creating robust, well-documented functions that adhere to project conventions and patterns.
- Files and subdirectories in the directory are structured and any existing queries used in external files will depend on this structure remaining intact, so any refactoring or restructuring should be done with caution and ideally should maintain the overall organization of the directory.


