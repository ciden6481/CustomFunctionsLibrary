"""
M_Creator.py — CustomFunctionsLibrary
======================================
Scans all .pq files under Functions/, extracts every native Power Query
Namespace.Function reference used, and regenerates M.pq with a complete
Expression.Evaluate environment block.

Run from anywhere:
    python "PQ Custom Library/M_Creator.py"

Output: PQ Custom Library/M.pq  (sibling of this script)
"""

import os
import re

# ---------------------------------------------------------------------------
# Paths — resolved relative to this script so cwd doesn't matter
# ---------------------------------------------------------------------------
SCRIPT_DIR     = os.path.dirname(os.path.abspath(__file__))
FUNCTIONS_DIR  = os.path.join(SCRIPT_DIR, "Functions")
OUTPUT_PATH    = os.path.join(SCRIPT_DIR, "M.pq")

# Skip template files so placeholder symbols never affect native function scans.
SKIP_FILE_BASENAMES = {
    "functiontemplate.pq",
}

# ---------------------------------------------------------------------------
# Regex: match Namespace.Function tokens (e.g. Date.Year, Text.From).
# Both halves must start with an uppercase letter to match PQ native functions
# and exclude lowercase comment fragments like "e.g" or "e.g."
# ---------------------------------------------------------------------------
PATTERN = r'\b[A-Z][A-Za-z0-9]*\.[A-Z][A-Za-z0-9]*\b'


def strip_m_comments_and_strings(content: str) -> str:
    """Return code with comments and string literals removed.

    This prevents false positives like Category.FunctionName and Date.MyFunc
    from documentation text, examples, and comments.
    """
    result: list[str] = []
    i = 0
    n = len(content)
    block_depth = 0

    while i < n:
        ch = content[i]
        nxt = content[i + 1] if i + 1 < n else ""

        # Inside block comment: support nested /* ... */
        if block_depth > 0:
            if ch == "/" and nxt == "*":
                block_depth += 1
                i += 2
            elif ch == "*" and nxt == "/":
                block_depth -= 1
                i += 2
            else:
                # Preserve line breaks to keep token boundaries stable
                result.append("\n" if ch == "\n" else " ")
                i += 1
            continue

        # Line comment
        if ch == "/" and nxt == "/":
            i += 2
            while i < n and content[i] != "\n":
                i += 1
            continue

        # Block comment
        if ch == "/" and nxt == "*":
            block_depth = 1
            i += 2
            continue

        # String literal (M escapes quotes by doubling "")
        if ch == '"':
            result.append(" ")
            i += 1
            while i < n:
                sch = content[i]
                snxt = content[i + 1] if i + 1 < n else ""
                if sch == '"' and snxt == '"':
                    i += 2
                    continue
                if sch == '"':
                    i += 1
                    break
                result.append("\n" if sch == "\n" else " ")
                i += 1
            continue

        result.append(ch)
        i += 1

    return "".join(result)

# ---------------------------------------------------------------------------
# Exclusion list — URLs, documentation metadata fields, library-specific names,
# and functions that must NOT be remapped in the Expression.Evaluate environment.
# Sourced from OscarValerock/PowerQueryFunctions and extended for this repo.
# ---------------------------------------------------------------------------
EXCLUDE = {
    # Documentation metadata fields (not PQ built-ins)
    'Documentation.AllowedValues',
    'Documentation.Author',
    'Documentation.Category',
    'Documentation.Description',
    'Documentation.Examples',
    'Documentation.FieldCaption',
    'Documentation.FieldDescription',
    'Documentation.LongDescription',
    'Documentation.Name',
    'Documentation.SampleValues',
    'Documentation.Source',
    'Documentation.Version',
    'Formatting.IsCode',
    'Formatting.IsMultiLine',
    # Functions excluded from Expression.Evaluate environment on purpose
    'Web.Contents',      # causes dynamic data source error in PBI Service
    # Library-specific names defined within the .pq files themselves
    'API.WorldBankCountries',
    'Date.Today',
    'List.DotProduct',
    'List.Flatten',
    'List.Norm',
    'OpenAI.AnalyzeTable',
    'PowerPlatform.Dataflows',
    'Table.ToM',
    'Text.CleanString',
    'Text.Collapse',
    'Text.ContainsAll',
    'Text.ContainsAny',
    'Text.ListFromString',
    'Text.ReplaceMany',
    # URL-like fragments that match the regex but aren't PQ functions
    'api.openai',
    'api.worldbank',
    'bibb.pro',
    'blog.crossjoin',
    'bsky.app',
    'co.uk',
    'community.fabric',
    'community.powerbi',
    'datahelpdesk.worldbank',
    'datavolume.xyz',
    'github.com',
    'gorilla.bi',
    'jamesdbartlett3.bsky',
    'linkedin.com',
    'microsoft.com',
    'odata.nextLink',
    'techhub.social',
    'www.linkedin',
    'www.youtube',
    'youtu.be',
}

# Functions that may be used via dynamic/string patterns the regex can miss
MANUAL = [
    'Number.Abs',
    'Value.ReplaceType',
]

# ---------------------------------------------------------------------------
# M.pq template — #TextToReplace is substituted with the environment entries
# ---------------------------------------------------------------------------
M_CODE_TEMPLATE = """\
// =============================================================================
// CustomFunctionsLibrary -- M.pq
// -----------------------------------------------------------------------------
// This query loads all functions from the PQ Custom Library on GitHub and
// exposes them as a record. Functions are called as:
//
//   M[Category.FunctionName](arg1, arg2, ...)
//
// SETUP:
//   1. Paste this entire file into a blank Power Query Advanced Editor window.
//   2. Rename the query to "M".
//   3. Set the PAT parameter (see below) to a GitHub Personal Access Token with
//      read-only Contents scope for the ciden6481/CustomFunctionsLibrary repo.
//      In Power BI Service, set this as a dataset parameter before publishing.
//
// HOW TO CREATE A PAT:
//   https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
//
// NOTE: This file is auto-generated by M_Creator.py. Do not edit the native
//       function environment block manually -- run M_Creator.py instead.
// =============================================================================

let
    // --- Configuration --------------------------------------------------------
    GitHubUser      = "ciden6481",
    GitHubRepo      = "CustomFunctionsLibrary",
    FunctionsPrefix = "PQ Custom Library/Functions/",
    BaseURL         = "https://api.github.com/repos/",
    PAT             = "",  // <-- Paste your GitHub PAT here, or set via dataset parameter

    // --- Auth headers ---------------------------------------------------------
    QueryHeaders = if PAT <> ""
        then [Authorization = "Bearer " & PAT]
        else [],

    // --- Get full recursive tree in one API call ------------------------------
    RawTree = Json.Document(
        Web.Contents(
            BaseURL,
            [
                RelativePath = GitHubUser & "/" & GitHubRepo & "/git/trees/main",
                Query        = [recursive = "1"],
                Headers      = QueryHeaders
            ]
        )
    )[tree],

    // --- Build a table from the tree and filter to function .pq files ---------
    TreeTable = Table.FromRecords(RawTree, {"path", "sha", "type"}, MissingField.UseNull),
    Expanded  = Table.RenameColumns(TreeTable, {{"path", "Path"}, {"sha", "Sha"}, {"type", "Type"}}),
    FunctionFiles = Table.SelectRows(
        Expanded,
        each [Type] = "blob"
            and Text.StartsWith([Path], FunctionsPrefix)
            and Text.EndsWith([Path], ".pq")
    ),

    // --- Derive "Category.FunctionName" keys from file paths ------------------
    // Input:  "PQ Custom Library/Functions/Date/QuarterLabel.pq"
    // Output: "Date.QuarterLabel"
    WithRelPath = Table.AddColumn(
        FunctionFiles,
        "RelPath",
        each Text.Replace(
                Text.Replace([Path], FunctionsPrefix, ""),
                ".pq", ""
             )
    ),
    WithName = Table.AddColumn(
        WithRelPath,
        "Name",
        each Text.Replace([RelPath], "/", ".")
    ),

    // --- Helper: fetch raw base64 blob content from GitHub --------------------
    GetBlob = (sha as text) =>
        Json.Document(
            Web.Contents(
                BaseURL,
                [
                    RelativePath = GitHubUser & "/" & GitHubRepo & "/git/blobs/" & sha,
                    Query        = [],
                    Headers      = QueryHeaders
                ]
            )
        )[content],

    // --- Helper: evaluate blob as an M expression (returns a function) --------
    EvaluateBlob = (sha as text) =>
        let
            raw     = GetBlob(sha),
            decoded = Text.FromBinary(Binary.FromText(raw)),
            result  = Expression.Evaluate(
                decoded,
                [
                    // Native M functions available to evaluated library functions.
                    // This block is auto-generated by M_Creator.py -- do not edit manually.
#TextToReplace
                    // Web.Contents is intentionally excluded -- it causes a dynamic
                    // data source error in Power BI Service when inside Expression.Evaluate.
                    // Library functions must not call Web.Contents directly.
                ]
            )
        in
            result,

    // --- Helper: return raw text for non-evaluatable blobs --------------------
    GetRawText = (sha as text) =>
        Text.FromBinary(Binary.FromText(GetBlob(sha))),

    // --- Fetch + evaluate every function file ---------------------------------
    WithValue = Table.AddColumn(
        WithName,
        "Value",
        each try EvaluateBlob([Sha]) otherwise GetRawText([Sha])
    ),

    // --- Build the output record: {{ "Date.QuarterLabel" = <function>, ... }} --
    FinalTable   = Table.SelectColumns(WithValue, {"Name", "Value"}),
    OutputRecord = Record.FromTable(FinalTable)

in
    OutputRecord
"""


# ---------------------------------------------------------------------------
# Extract Namespace.Function tokens from a single file
# ---------------------------------------------------------------------------
def extract_functions(file_path: str) -> list[str]:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    cleaned = strip_m_comments_and_strings(content)
    matches = re.findall(PATTERN, cleaned)
    return [m for m in matches
            if not re.match(r'^\d+\.\d+$', m) and m not in EXCLUDE]


def should_scan_file(name: str) -> bool:
    return name.endswith('.pq') and name.lower() not in SKIP_FILE_BASENAMES


# ---------------------------------------------------------------------------
# Build the set of library-defined function names (e.g. "Date.QuarterLabel")
# so they are excluded from the native environment block
# ---------------------------------------------------------------------------
def get_library_function_names(directory: str) -> set[str]:
    names = set()
    for root, _dirs, files in os.walk(directory):
        for name in files:
            if should_scan_file(name):
                category = os.path.basename(root)
                func = name[:-3]  # strip .pq
                names.add(f"{category}.{func}")
    return names


# ---------------------------------------------------------------------------
# Walk Functions directory and collect all referenced native functions
# ---------------------------------------------------------------------------
def scan_functions_dir(directory: str) -> list[str]:
    found = []
    for root, _dirs, files in os.walk(directory):
        for name in files:
            if should_scan_file(name):
                found.extend(extract_functions(os.path.join(root, name)))
    return found


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    if not os.path.isdir(FUNCTIONS_DIR):
        raise FileNotFoundError(f"Functions directory not found: {FUNCTIONS_DIR}")

    raw = scan_functions_dir(FUNCTIONS_DIR)

    # Exclude names defined in the library itself (e.g. Date.QuarterLabel)
    library_names = get_library_function_names(FUNCTIONS_DIR)

    # Deduplicate, merge manually specified entries, sort; exclude library names
    unique = sorted((set(raw) | set(MANUAL)) - library_names - EXCLUDE)

    print(f"Found {len(unique)} unique native PQ functions referenced in library:")
    for fn in unique:
        print(f"  {fn}")

    # Build the environment entries block, indented to match the M template
    indent = "                    "
    lines = []
    for i, fn in enumerate(unique):
        comma = "" if i == len(unique) - 1 else ","
        lines.append(f"{indent}{fn} = {fn}{comma}")
    env_block = "\n".join(lines)

    output = M_CODE_TEMPLATE.replace("#TextToReplace", env_block)

    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        f.write(output)

    print(f"\nWrote {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
