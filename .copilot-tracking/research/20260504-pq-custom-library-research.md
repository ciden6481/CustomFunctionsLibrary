<!-- markdownlint-disable-file -->

# Research: PQ Custom Library Build

**Date**: 2026-05-04  
**Source Repo**: https://github.com/OscarValerock/PowerQueryFunctions  
**Target Repo**: https://github.com/ciden6481/CustomFunctionsLibrary  

---

## 1. Reference Project Analysis

### 1.1 Directory Structure (OscarValerock/PowerQueryFunctions)

```
/
├── Functions/
│   ├── Category1/
│   │   └── FunctionName.pq
│   └── Category2/
│       └── FunctionName.pq
├── M.pq                  ← generated load query
├── M_Creator.py          ← Python script that regenerates M.pq
├── M_FxDocTemplate.pq    ← template for new functions
└── README.md
```

### 1.2 How M_Creator.py Works (Lines 1–~100 of M_Creator.py)

- Scans all `.pq` files under the `Functions/` directory with `os.walk`.
- Uses regex `\b\w+\.\w+\b` to extract all `Namespace.Function` references used in function bodies.
- Filters out a manually maintained exclusion list (URLs, library-specific names, etc.) and a manual additions list.
- Builds a deduplicated, sorted list of native M functions used.
- Substitutes `#TextToReplace` in a hardcoded `M_Code` string template with those function = function mappings.
- Writes the result to `M.pq`.

**Key insight**: `Expression.Evaluate` requires an explicit environment record listing every native PQ function the evaluated code might call. M_Creator.py automates building this list.

### 1.3 How M.pq Works

The generated M.pq:
1. Sets `GitHubUser`, `GitHubRepo`, `BaseURL`, and `PAT` variables.
2. Builds `QueryHeaders` — adds `Authorization: Bearer <PAT>` only if PAT is non-empty.
3. Calls GitHub Trees API: `GET /repos/{user}/{repo}/git/trees/main` to get root tree.
4. Finds the SHA for the `"Functions"` entry in the root tree.
5. Gets that tree (category folders + any root-level .pq files).
6. For each category entry, gets its tree to find individual `.pq` files.
7. For each `.pq` blob SHA, calls `/git/blobs/{sha}` — returns base64 content.
8. Decodes + calls `Expression.Evaluate(content, [nativeFn = nativeFn, ...])` to hydrate each function.
9. Falls back to returning raw text if evaluation fails.
10. Builds a `Record` where each key is `"Category.FunctionName"` (folder + filename without .pq).
11. Returns this record as the query result — so `M[Category.FunctionName](args)` invokes the function.

### 1.4 Power BI Service Compatibility

**Confirmed compatible** — the README states "A Power BI Service compatible M Power Query custom functions library."

Why it works in PBI Service:
- `Web.Contents` with a static `BaseURL` + dynamic `RelativePath` query option avoids the "dynamic data source" error that would occur with a fully dynamic URL string.
- PAT is stored as a query parameter, not hardcoded, keeping credentials out of source.
- No local file system access; everything is fetched over HTTPS from GitHub API.

**The M_Creator.py script is a build tool only** — it runs locally/in CI to regenerate M.pq. The generated M.pq is what gets committed and used by Power BI.

**On-premises gateway**: Since `Web.Contents` hits a public HTTPS endpoint (GitHub API), the gateway just proxies the HTTPS call. No local files need to be on the gateway. This is compatible as long as the gateway allows outbound HTTPS to `api.github.com`.

### 1.5 Template Structure (M_FxDocTemplate.pq)

```powerquery
let
    metaDocumentation = type function (
        parameter1 as (type text meta [ ... ]),
        parameter2 as (type number meta [ ... ]),
        optional parameter3 as (type nullable logical meta [ ... ])
    ) as list
    meta [
        Documentation.Name = "...",
        Documentation.Author = "...",
        Documentation.LongDescription = "...",
        Documentation.Examples = { [...] }
    ],

    myFunction = (parameter1 as text, parameter2 as number, optional parameter3 as nullable logical) =>
        let
            // function body
        in
            result
in
    Value.ReplaceType(myFunction, metaDocumentation)
```

**Key design**: `Value.ReplaceType(myFunction, metaDocumentation)` attaches the documentation metadata to the function so Power Query shows rich documentation in the UI.

---

## 2. Target Repo Structure Plan

### 2.1 Proposed Directory Layout

```
PQ Custom Library/
├── Functions/
│   ├── Date/
│   │   └── (example function).pq
│   ├── Text/
│   │   └── (example function).pq
│   └── Table/
│       └── (example function).pq
├── M.pq              ← generated, committed, used by Power BI
├── M_Creator.py      ← adapted build script
└── FunctionTemplate.pq  ← enhanced template
```

### 2.2 GitHub API Navigation for Nested Path

The `PQ Custom Library/Functions/` path is 2 levels deep from the repo root. Two options:

**Option A – Recursive tree** (chosen for simplicity):
- Call `GET /repos/{user}/{repo}/git/trees/main?recursive=1`
- Returns all files in the repo flattened.
- Filter by `path` starting with `"PQ Custom Library/Functions/"` and ending with `".pq"`.
- Avoids multi-step tree traversal.
- Trade-off: larger API response, but manageable for this size library.

**Option B – Multi-step traversal** (more efficient but more complex M code):
- Navigate root → "PQ Custom Library" → "Functions" → categories → files.
- Requires 3+ API calls per load.

**Decision**: Use Option A (recursive tree). Simpler M code, repo will be small enough that response size won't be an issue.

### 2.3 Path-to-Name Derivation

With recursive tree, each function file has a path like:
`PQ Custom Library/Functions/Date/AddBusinessDays.pq`

To derive the record key `Date.AddBusinessDays`:
1. Strip prefix `"PQ Custom Library/Functions/"`.
2. Replace `"/"` with `"."`.
3. Strip trailing `".pq"`.

### 2.4 PAT Token Handling

- PAT stored in an M parameter named `PAT` (empty string by default).
- In Power BI Desktop: set the PAT in the query parameter before publishing, or use a named parameter that can be set at publish time.
- In Power BI Service: use the dataset parameters to set the PAT; the gateway passes it through.
- **Note**: PAT should be a fine-grained token with read-only access to the `Contents` (file contents) of this repo. No writes needed.

---

## 3. M_Creator.py Adaptation

Changes needed from the original:
1. Change scan directory from `"Functions"` to `"PQ Custom Library/Functions"`.
2. Update `GitHubUser` and `GitHubRepo` constants in the M_Code template.
3. Update the tree navigation in M_Code to use recursive approach.
4. Keep the same exclusion list (it filters standard PQ built-ins that shouldn't be remapped).
5. Keep the PAT parameter.

---

## 4. Enhanced Function Template Design

To support a dynamic number of parameters, the template will use:
- Clearly delimited "parameter blocks" with comments like `// --- ADD/REMOVE PARAMETERS ABOVE ---`
- Separate parameter blocks repeated for required vs optional.
- Instructions in comments showing exactly which lines to duplicate/delete for each new parameter.
- A "zero parameter" example and a "multi-parameter" example included as comments.

---

## 5. GitHub Actions Workflow

File: `.github/workflows/generate-mpq.yml`

Trigger: `push` to `main` branch, with path filter `PQ Custom Library/Functions/**/*.pq`.

Steps:
1. `actions/checkout`
2. `actions/setup-python`
3. Run `python "PQ Custom Library/M_Creator.py"`
4. Check if `PQ Custom Library/M.pq` has changed (git diff).
5. If changed: commit and push updated M.pq with `[skip ci]` message to avoid loop.

**Bot commit**: Use `github-actions[bot]` identity for the auto-commit.

---

## 6. Key Implementation Notes

- The `Expression.Evaluate` environment in M.pq must list every native PQ function used across all library functions. M_Creator.py automates this scan.
- `Web.Contents` exclusion from the environment is intentional — it causes a dynamic data source error in PBI Service if included; library functions should not call `Web.Contents` directly.
- Functions calling `Web.Contents` must be loaded as raw text (the `try ... otherwise` fallback in M.pq handles this).
- The `Functions` subdirectory name is significant — it appears in path filtering.
- Category folder names become the first half of the function key (e.g., folder `Date` → `Date.AddBusinessDays`).
- Function file names become the second half (without `.pq` extension).
