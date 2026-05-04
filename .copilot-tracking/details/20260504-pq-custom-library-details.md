<!-- markdownlint-disable-file -->

# Task Details: PQ Custom Library Build

## Research Reference

**Source Research**: #file:../research/20260504-pq-custom-library-research.md

---

## Phase 1: Directory Structure & Sample Functions

### Task 1.1: Create category subdirectories and sample functions

Create the `PQ Custom Library/Functions/` directory tree with category subfolders representing common function groups. Each folder gets at least one real sample function to validate the load pipeline end-to-end.

**Category folders to create**:
- `PQ Custom Library/Functions/Date/`
- `PQ Custom Library/Functions/Text/`
- `PQ Custom Library/Functions/Table/`
- `PQ Custom Library/Functions/List/`
- `PQ Custom Library/Functions/Number/`

**Sample function to include** — `PQ Custom Library/Functions/Date/QuarterLabel.pq`:

A simple function that returns a text label like `"Q1 FY2026"` for a given date and an optional fiscal year start month.

The function body follows the full documented template format (see Phase 2 for the template). Since this is the very first function, its body also serves to test the end-to-end load.

```powerquery
let
    metaDocumentation = type function (
        dateValue as (type date meta [
            Documentation.FieldCaption = "Date",
            Documentation.FieldDescription = "The date for which to compute the fiscal quarter label.",
            Documentation.SampleValues = {#date(2026, 3, 15)},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional fiscalYearStartMonth as (type nullable number meta [
            Documentation.FieldCaption = "Fiscal Year Start Month",
            Documentation.FieldDescription = "Month number (1–12) where the fiscal year begins. Defaults to 7 (July).",
            Documentation.SampleValues = {7},
            Documentation.AllowedValues = {1,2,3,4,5,6,7,8,9,10,11,12},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as text
    meta [
        Documentation.Name = "Date.QuarterLabel",
        Documentation.Author = "CustomFunctionsLibrary",
        Documentation.LongDescription = "
            <p><b>Date.QuarterLabel</b></p>
            <li>Returns a fiscal quarter label string such as <code>Q1 FY2026</code>.</li>
            <li><b>Parameters:</b></li>
            <ul>
                <li><b>dateValue</b>: The input date.</li>
                <li><b>fiscalYearStartMonth</b> (optional): Month the fiscal year begins (default 7 = July).</li>
            </ul>
            <b>Returns:</b> Text — e.g. <code>Q2 FY2026</code>
        ",
        Documentation.Examples = {
            [
                Description = "Get fiscal quarter label for March 2026 with July fiscal year start.",
                Code = "Date.QuarterLabel(#date(2026, 3, 15), 7)",
                Result = """Q3 FY2026"""
            ]
        }
    ],

    QuarterLabel = (dateValue as date, optional fiscalYearStartMonth as nullable number) =>
        let
            fyStart = fiscalYearStartMonth ?? 7,
            m = Date.Month(dateValue),
            y = Date.Year(dateValue),
            fiscalMonth = Number.Mod(m - fyStart + 12, 12) + 1,
            quarter = Number.IntegerDivide(fiscalMonth - 1, 3) + 1,
            fiscalYear = if m >= fyStart then y + 1 else y,
            label = "Q" & Number.ToText(quarter) & " FY" & Number.ToText(fiscalYear)
        in
            label
in
    Value.ReplaceType(QuarterLabel, metaDocumentation)
```

- **Files**:
  - `PQ Custom Library/Functions/Date/QuarterLabel.pq` — sample documented function
  - `PQ Custom Library/Functions/Text/.gitkeep` — placeholder to track empty folder
  - `PQ Custom Library/Functions/Table/.gitkeep`
  - `PQ Custom Library/Functions/List/.gitkeep`
  - `PQ Custom Library/Functions/Number/.gitkeep`
- **Success**:
  - All five category folders exist in the repo.
  - `QuarterLabel.pq` is valid M code that evaluates without errors.
- **Research References**:
  - #file:../research/20260504-pq-custom-library-research.md (Lines 1–60) — reference project structure and function template analysis
- **Dependencies**:
  - None — this is the first phase.

---

## Phase 2: Function Template

### Task 2.1: Create `PQ Custom Library/FunctionTemplate.pq`

Create an enhanced template that makes it easy to add or remove required and optional parameters. The template uses clearly marked comment blocks to indicate exactly which lines to duplicate or delete for each parameter.

**Design**: 
- The template shows 2 required parameters + 1 optional parameter by default.
- Comment annotations like `// [REQUIRED PARAM — duplicate this block to add more]` and `// [OPTIONAL PARAM — duplicate or remove this block]` guide the user.
- The parameter declaration in `metaDocumentation` and the function signature are both shown with matching comments.
- A header comment block explains the naming convention: file name = function name, folder name = category prefix (so folder `Date`, file `MyFunc.pq` → accessible as `M[Date.MyFunc](args)`).

**Key sections**:
1. `metaDocumentation` type function block — lists all params with Documentation metadata.
2. Global `meta [...]` block — Documentation.Name, Author, LongDescription, Examples.
3. `myFunction = (params...) => let ... in result` — the actual implementation.
4. `Value.ReplaceType(myFunction, metaDocumentation)` — binds documentation to function.

- **Files**:
  - `PQ Custom Library/FunctionTemplate.pq`
- **Success**:
  - Template is valid M (pastes into Advanced Editor without parse errors).
  - Comments clearly guide parameter addition/removal.
  - Naming convention note is present.
- **Research References**:
  - #file:../research/20260504-pq-custom-library-research.md (Lines 74–112) — original template analysis and enhanced design notes
- **Dependencies**:
  - Phase 1 completion (establishes directory context)

---

## Phase 3: M_Creator.py (Build Script)

### Task 3.1: Create `PQ Custom Library/M_Creator.py`

Adapt `M_Creator.py` from the reference project with these changes:

1. **Scan directory**: Change from `"Functions"` to `os.path.join(os.path.dirname(__file__), "Functions")` so it works correctly regardless of where the script is run from.
2. **Output path**: Write to `os.path.join(os.path.dirname(__file__), "M.pq")` (sibling of the script).
3. **GitHubUser / GitHubRepo constants**: Set to `"ciden6481"` and `"CustomFunctionsLibrary"`.
4. **M_Code template**: Use the recursive tree approach (see Phase 4 details) instead of the 2-level traversal. The `#TextToReplace` placeholder is still used for the native function list.
5. **Exclusion list**: Keep the same exclusion list from the original — it's a well-maintained list of URLs, PQ built-ins that need no remapping, and library-specific names.
6. **Functions folder prefix in path filter**: The recursive API returns full paths like `PQ Custom Library/Functions/Date/QuarterLabel.pq`. The path filter in M_Code must strip the prefix `"PQ Custom Library/Functions/"`.

**The M_Code template string** embedded in M_Creator.py should exactly match the M.pq content from Phase 4, with `#TextToReplace` as the substitution marker for the native function environment entries.

- **Files**:
  - `PQ Custom Library/M_Creator.py`
- **Success**:
  - Running `python "PQ Custom Library/M_Creator.py"` from the repo root regenerates `PQ Custom Library/M.pq`.
  - The regenerated M.pq is syntactically valid and matches the Phase 4 design.
  - The script exits with code 0 on success.
- **Research References**:
  - #file:../research/20260504-pq-custom-library-research.md (Lines 120–148) — M_Creator.py adaptation analysis
- **Dependencies**:
  - Phase 1 (Functions directory must exist for the scan to find files)
  - Phase 4 design must be finalized first (M_Creator.py embeds the M_Code template)

---

## Phase 4: M.pq (Load Query)

### Task 4.1: Create `PQ Custom Library/M.pq`

**Design**: Use the GitHub Trees API with `?recursive=1` to get all files in the repo in a single call. Filter to only `PQ Custom Library/Functions/**/*.pq` files, then fetch and evaluate each blob.

**Complete M code structure**:

```powerquery
let
    // ─── Configuration ────────────────────────────────────────────────────────
    GitHubUser = "ciden6481",
    GitHubRepo = "CustomFunctionsLibrary",
    FunctionsPrefix = "PQ Custom Library/Functions/",
    BaseURL = "https://api.github.com/repos/",
    PAT = "",  // Set your GitHub PAT here or in a report parameter named PAT
               // Fine-grained token needs: Contents (read-only) on this repo.
               // Docs: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

    // ─── Auth headers ─────────────────────────────────────────────────────────
    QueryHeaders = if PAT <> ""
        then [Authorization = "Bearer " & PAT]
        else [],

    // ─── Get full recursive tree ───────────────────────────────────────────────
    RawTree = Json.Document(
        Web.Contents(
            BaseURL,
            [
                RelativePath = GitHubUser & "/" & GitHubRepo & "/git/trees/main",
                Query = [recursive = "1"],
                Headers = QueryHeaders
            ]
        )
    )[tree],

    // ─── Filter to .pq files under the Functions folder ───────────────────────
    TreeTable = Table.FromList(RawTree, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Expanded = Table.ExpandRecordColumn(TreeTable, "Column1", {"path", "sha", "type"}, {"Path", "Sha", "Type"}),
    FunctionFiles = Table.SelectRows(
        Expanded,
        each [Type] = "blob"
            and Text.StartsWith([Path], FunctionsPrefix)
            and Text.EndsWith([Path], ".pq")
    ),

    // ─── Derive function names from paths ─────────────────────────────────────
    // Path:  "PQ Custom Library/Functions/Date/QuarterLabel.pq"
    // Name:  "Date.QuarterLabel"
    WithRelativePath = Table.AddColumn(
        FunctionFiles,
        "RelPath",
        each Text.Replace(
            Text.Replace([Path], FunctionsPrefix, ""),   // strip prefix
            ".pq", ""                                    // strip extension
        )
    ),
    WithName = Table.AddColumn(
        WithRelativePath,
        "Name",
        each Text.Replace([RelPath], "/", ".", Replacer.ReplaceText)
    ),

    // ─── Fetch and evaluate each function blob ────────────────────────────────
    GetBlob = (sha as text) =>
        Json.Document(
            Web.Contents(
                BaseURL,
                [
                    RelativePath = GitHubUser & "/" & GitHubRepo & "/git/blobs/" & sha,
                    Query = [],
                    Headers = QueryHeaders
                ]
            )
        )[content],

    EvaluateBlob = (sha as text) =>
        let
            raw = GetBlob(sha),
            decoded = Text.FromBinary(Binary.FromText(raw)),
            result = Expression.Evaluate(
                decoded,
                [
                    #TextToReplace
                ]
            )
        in
            result,

    GetRawText = (sha as text) =>
        Text.FromBinary(Binary.FromText(GetBlob(sha))),

    WithValue = Table.AddColumn(
        WithName,
        "Value",
        each try EvaluateBlob([Sha]) otherwise GetRawText([Sha])
    ),

    // ─── Build the output record ───────────────────────────────────────────────
    FinalTable = Table.SelectColumns(WithValue, {"Name", "Value"}),
    OutputRecord = Record.FromTable(FinalTable)
in
    OutputRecord
```

**Note**: `#TextToReplace` is the placeholder that `M_Creator.py` replaces with the native function environment mapping (e.g., `Date.Year = Date.Year, Text.From = Text.From, ...`).

**Usage in Power Query**:
```
// After adding M query to Power Query:
M[Date.QuarterLabel](#date(2026, 3, 15), 7)
```

- **Files**:
  - `PQ Custom Library/M.pq` — the generated load query (also committed to source control so it works immediately without running M_Creator.py)
- **Success**:
  - Pasting M.pq into Power Query Advanced Editor, naming it `M`, and invoking `M[Date.QuarterLabel](#date(2026, 3, 15))` returns `"Q3 FY2026"`.
  - Works in both Power BI Desktop and Power BI Service (after setting PAT parameter).
- **Research References**:
  - #file:../research/20260504-pq-custom-library-research.md (Lines 60–100) — M.pq design, recursive tree approach, path derivation
- **Dependencies**:
  - Phase 1 (at least one function file must exist)

---

## Phase 5: GitHub Actions Workflow

### Task 5.1: Create `.github/workflows/generate-mpq.yml`

**Trigger**: Push to `main` branch, paths filter on `PQ Custom Library/Functions/**`.

**Workflow steps**:
1. `actions/checkout@v4` with `fetch-depth: 0` and `persist-credentials: true`.
2. `actions/setup-python@v5` with Python 3.12.
3. Run `python "PQ Custom Library/M_Creator.py"`.
4. Detect if `PQ Custom Library/M.pq` changed using `git diff --quiet`.
5. If changed: configure git user as `github-actions[bot]`, then commit and push with message `"chore: regenerate M.pq [skip ci]"`.
   - `[skip ci]` prevents the workflow from re-triggering itself.

**Permissions required**: `contents: write` at the job level.

**Full YAML**:

```yaml
name: Regenerate M.pq

on:
  push:
    branches: [main]
    paths:
      - "PQ Custom Library/Functions/**"

permissions:
  contents: write

jobs:
  regenerate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          persist-credentials: true

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Run M_Creator
        run: python "PQ Custom Library/M_Creator.py"

      - name: Commit updated M.pq if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git diff --quiet "PQ Custom Library/M.pq" || (
            git add "PQ Custom Library/M.pq" &&
            git commit -m "chore: regenerate M.pq [skip ci]" &&
            git push
          )
```

- **Files**:
  - `.github/workflows/generate-mpq.yml`
- **Success**:
  - Pushing a new `.pq` file under `PQ Custom Library/Functions/` triggers the workflow.
  - Workflow passes, and a commit updating `M.pq` appears in the repo history.
  - Pushes that don't touch function files do NOT trigger the workflow.
- **Research References**:
  - #file:../research/20260504-pq-custom-library-research.md (Lines 150–170) — GitHub Actions design
- **Dependencies**:
  - Phase 3 (M_Creator.py must exist)
  - Repo must have Actions enabled (default for public repos)

---

## Dependencies

- Python 3.x (for M_Creator.py and CI)
- GitHub repo: `ciden6481/CustomFunctionsLibrary`
- GitHub PAT with read-only Contents scope (user configures in Power BI parameter)

## Success Criteria

- All five files/directories created and committed.
- `M.pq` loads successfully in Power Query with at least one function callable.
- GitHub Actions workflow auto-updates `M.pq` on function changes.
- `FunctionTemplate.pq` is self-explanatory for adding parameters.
