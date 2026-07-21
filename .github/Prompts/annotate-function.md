---
description: Add a header doc block and inline comments to a Power Query .pq function file; treat filename as function name and format according to Power Query M conventions
arguments:
  filePath: Optional path to the .pq file inside a gist (e.g. Functions/MyFunction.pq)
  functionName: Function name (filename without .pq). The agent will search for file named <functionName>.pq if filePath not provided.
---

You are asked to edit a Power Query M (.pq) file that implements a single top-level function. Important: in this repository each `.pq` file contains one function and the function name equals the filename (without the `.pq` extension). When the user requests `Annotate function {{functionName}}`, the agent should look for a file named `{{functionName}}.pq`.

Inputs (placeholders):
- {{filePath}} — Optional. Exact path to the target .pq file within a gist (for example: Functions/MyFunction.pq). If provided, use this file directly and do not perform filename-based search.
- {{functionName}} — The function name / filename (without the `.pq` extension) to annotate. If provided and `{{filePath}}` is not given, search for a file named `{{functionName}}.pq` first in the "Power Query Functions" gist, then across other gists if not found there.

Search rules:
- If `{{filePath}}` is supplied, open that file and annotate it.
- Else if `{{functionName}}` is supplied, look for `{{functionName}}.pq` in this order:
  1) The "Power Query Functions" gist (preferred)
  2) Other gists in the account/workspace
- If multiple files with the same name are found, prefer the match in "Power Query Functions". If still ambiguous, choose the first match found.
- If neither `{{filePath}}` nor `{{functionName}}` is supplied, annotate the first `.pq` file and its first top-level function found in the "Power Query Functions" gist.

Task:
1) Locate the target `.pq` file using the rules above.

2) Add a top-of-file documentation block using M block-comment syntax (`/* ... */`) placed at the very top of the file (before any code). The block must include these sections:
   - Function: the function name (use the filename if available)
   - Purpose: a one-sentence summary of what the function does
   - Parameters: list each parameter with name, expected type (use explicit type if present; otherwise mark as "inferred"), and a short description
   - Returns: description of the return value and its type
   - Example: a minimal usage example (optional)

   Use this template for the block:
   /*
   Function: <FunctionName>
   Purpose: <one-line summary>
   Parameters:
    - param1 (type) — description
    - param2 (type) — description
   Returns:
    - description (type)
   Example:
    - <FunctionName>(...)
   */

3) Inside the function body, add concise single-line comments using `//` to explain the logic and control flow at key steps (transformations, conditional branches, loops, grouping/aggregation, error handling, returns). Prefer comments on their own lines above the code block or statement rather than inline at the end of lines. Keep each comment short (1–2 sentences) and focused on intent and why the step exists.

4) Preserve the original code behavior, variable names, and formatting as much as possible. Do not refactor or change logic — only add documentation/comments.

5) If the file contains multiple functions, only annotate the top-level function whose name matches `{{functionName}}`. If `{{functionName}}` is empty but `{{filePath}}` points to a file with multiple top-level functions, annotate the first top-level function in that file.

6) If parameter types are not explicit, infer reasonable types (e.g., Text, Number, Date, Table, List, Record) and mark them as "inferred" in the Parameters section.

7) Output requirement: Return the full updated file contents only (the .pq file text), including the new top-of-file comment block and inline comments. Do not add any explanatory text outside the file contents.

   - If the specified file `{{functionName}}.pq` is not found in any gist, return a single-line file containing exactly:
     // No file named {{functionName}}.pq found in any gist; no changes made.

   - If the file was found but the named top-level function is not present in that file, return the original file unchanged but add a single-line top comment reading:
     // No top-level function named {{functionName}} found; file unchanged.

8) Formatting requirement: After inserting the documentation block and inline comments, reformat the file to follow common Power Query M formatting conventions while preserving code tokens and logic. Formatting rules to apply:
   - Place the header block (`/* ... */`) at the very top, followed by a single blank line.
   - Format `let` / `in` blocks with `let` and `in` on their own lines.
   - Place each step assignment inside `let` on its own line and separate steps with commas where required by M syntax.
   - Use 4-space indentation for nested expressions and for step definitions inside `let`.
   - Align comment lines above the statements they describe and indent them to the same level as the following statement.
   - Remove trailing whitespace and ensure the file ends with a single newline.
   - Do not rename variables, change function or step names, or alter expressions beyond whitespace and line-breaking necessary for readability.
   - Avoid introducing line breaks inside string literals or breaking tokens in a way that changes semantics.

Notes/examples for comment style:
- // Convert column X to date type for accurate comparisons
- // Group rows by CustomerID and compute total sales

Be careful not to break code syntax when inserting comments or reformatting. Use M comment syntax (`/* ... */` for the header block and `//` for single-line comments).