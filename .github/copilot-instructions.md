# Copilot instructions for CustomFunctionsLibrary
This repository is a collection of Power Query (M) helpers, DAX snippets, and reusable modules. The goal of these instructions is to help AI coding agents be immediately productive by focusing on project conventions, common workflows, and concrete examples from the codebase.

## Big picture
- Purpose: to develop, debug and refine queries used in external files. In almost all cases, work in this director will consist of pasting a query into one of the `ScratchFiles/` files and asking for assistance. 

 - `ScratchFiles/` - scratch files for staging and developing DAX and M queries to be used in external files. These files will change often and represent the major working files to be edited.

  
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
    - `Other Libraries/` - reusable M modules and DAX snippets.
   - `Other Libraries/pquery` and `Other Libraries/LibPQ` — canonical reusable M modules and helper libraries (use `LibPQ` loader).
   - `PowerQuery/`, `Snippets/` — working queries and examples used previously that may be useful or similar logic needed.
   - `DAX/` — DAX utilities and generated expressions (e.g. `DAX/TermCalendarTable.dax`).

## Workflow
- Typically, a query will be pasted from an external source in to one of the `ScratchFiles/` files. The AI agent will then assist in debugging, refining, and optimizing the query.
- Assume that the query will be copied back to the original file and the results, including any relevant error messages or other problems, will be shared with the AI agent for further assistance.
- The AI agent will provide guidance on how to fix issues, optimize performance, and ensure that the query adheres to project conventions and patterns.
- Any improvements to logic, syntax, performance or efficiency that are not specifically asked for should be suggested as part of the assistance.



