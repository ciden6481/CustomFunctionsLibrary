# PQ Custom Library

A collection of reusable Power Query (M) functions that load directly from GitHub at report refresh time — no local files or gateways required. Works in both Power BI Desktop and Power BI Service.

---

## User Guide

This section explains how to load the library into your Power BI or Excel file and call its functions.

### What you'll need

- A GitHub Personal Access Token (PAT) with **read-only Contents** access to this repository. This lets Power Query fetch the function files from GitHub.
  - How to create one: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
  - When creating the token, only the **Contents (read)** permission is needed — nothing else.

### Step 1 — Add the M query to your file

1. In Power BI Desktop, open the **Power Query Editor** (Home → Transform Data).
2. Create a new blank query: **Home → New Source → Blank Query**.
3. With the new query selected, open the **Advanced Editor** (Home → Advanced Editor).
4. Delete all the placeholder text in the editor.
5. Open the file `PQ Custom Library/M.pq` from this repository and **paste its entire contents** into the Advanced Editor.
6. Click **Done**.
7. Rename the query to exactly **`M`** (right-click the query in the left panel → Rename).

> **Why `M`?** That name is how you reference the library in other queries: `M[FunctionName](...)`. You can use any name you like, but these docs assume `M`.

### Step 2 — Set your GitHub PAT

In the `M.pq` code you just pasted, find this line near the top:

```
PAT = "",  // <-- Paste your GitHub PAT here, or set via dataset parameter
```

Paste your token between the quotes:

```
PAT = "github_pat_xxxxxxxxxxxxxxxx",
```

> **Power BI Service note:** Do not paste your PAT directly into the file if you plan to publish to the Service — anyone who can export the `.pbix` could read it. Instead, leave `PAT = ""` in the query and create a **dataset parameter** named `PAT` in Power BI Service after publishing (Semantic model settings → Parameters). The query will use the parameter value automatically.

### Step 3 — Authenticate the data source

The first time you refresh, Power Query will prompt you to authenticate the GitHub API connection.

1. When prompted, choose **Anonymous** (the PAT is passed in the query header, not through Power Query's credential store).
2. Set the privacy level to **Organizational** or **Public**.

### Step 4 — Call a function in another query

With the `M` query loaded, you can call any library function from any other query in your file using this pattern:

```
M[Category.FunctionName](argument1, argument2, ...)
```

**Example** — get a fiscal quarter label for a date:

```
M[Date.QuarterLabel](#date(2026, 3, 15))
// Returns: "Q3 FY2026"
```

**Example** — use a function inside a `Table.AddColumn` call:

```
Table.AddColumn(Source, "FiscalQuarter", each M[Date.QuarterLabel]([DateColumn]))
```

### Available functions

| Function | Description |
|---|---|
| `Date.QuarterLabel` | Returns a fiscal quarter label (e.g. `Q3 FY2026`) from a date and an optional fiscal year start month (default: July). |

---

## Developer Guide

This section explains how to add a new function to the library or update an existing one. No prior experience with GitHub Actions or Python is assumed.

### How the library works (the short version)

- Each function is stored as its own `.pq` file under `Functions/CategoryName/FunctionName.pq`.
- The file `M.pq` is the "loader" query. When a report refreshes, it fetches all the function files from GitHub and assembles them into a single record.
- `M_Creator.py` is a Python script that regenerates `M.pq` automatically whenever function files change. You do not need to edit `M.pq` by hand.
- A GitHub Actions workflow (`.github/workflows/generate-mpq.yml`) runs `M_Creator.py` automatically every time you push changes to function files.

### Folder structure

```
PQ Custom Library/
  Functions/
    Date/
      QuarterLabel.pq       <-- one file per function
    Text/
    Table/
    List/
    Number/
  FunctionTemplate.pq       <-- copy this to create a new function
  M.pq                      <-- auto-generated loader query (do not edit by hand)
  M_Creator.py              <-- script that regenerates M.pq
  README.md                 <-- this file
```

A function's **name in Power Query is derived from its file path** automatically:

```
Functions/Date/QuarterLabel.pq  →  Date.QuarterLabel
Functions/Text/Trim.pq          →  Text.Trim
```

So the category folder name and filename are the function name — choose them carefully.

### Adding a new function

#### Step 1 — Copy the function template

In the `PQ Custom Library/` folder, copy `FunctionTemplate.pq` and save it to the correct category folder with the function's name:

```
Functions/CategoryName/YourFunctionName.pq
```

If the category folder does not exist yet (e.g. you are creating the first `Text` function), create the folder.

#### Step 2 — Fill in the template

Open the new `.pq` file. The template has three numbered sections:

1. **Parameter documentation metadata** — describes each parameter (caption, description, sample values). Add one block per required parameter and include or remove the optional parameter block as needed. Follow the `// [REQUIRED PARAM]` and `// [OPTIONAL PARAM]` comments in the template.

2. **Function-level documentation** — the name, author, and description that appear in the Power Query function dialog. Update `Documentation.Name` to match your `Category.FunctionName` and fill in the description and examples.

3. **Function implementation** — the actual M code. The function name used inside the file (e.g. `QuarterLabel`) must match what is passed to `Value.ReplaceType` at the bottom. The name in the file does not have to match the filename, but keeping them consistent is strongly recommended.

The last line of every function file must follow this pattern:

```
Value.ReplaceType(YourFunctionName, metaDocumentation)
```

#### Step 3 — Commit and push

Once the file is saved, commit it and push to the `main` branch:

```
git add "PQ Custom Library/Functions/CategoryName/YourFunctionName.pq"
git commit -m "feat: add Text.YourFunctionName"
git push
```

> **New to Git?** In VS Code, open the Source Control panel (the branch icon in the left sidebar). You'll see your new file listed under "Changes". Click the **+** icon next to the file to stage it, type a short message in the box at the top (e.g. `add Date.QuarterLabel`), then click **Commit**. After committing, click **Sync Changes** (or the **Push** button) to send it to GitHub.

#### Step 4 — Wait for the workflow to finish

After you push, GitHub Actions automatically runs `M_Creator.py` and commits an updated `M.pq` if the function you added uses any new native Power Query functions. This usually takes less than a minute.

You can watch the progress at:
`https://github.com/ciden6481/CustomFunctionsLibrary/actions`

Once the workflow completes with a green checkmark, `M.pq` in the repository is up to date. The next time a report that uses the library refreshes, it will pick up the new function automatically — no changes needed in the Power BI file.

#### Updating an existing function

Edit the `.pq` file directly, then commit and push. The workflow will re-run and update `M.pq` if needed. Reports will get the updated function on their next refresh.

#### Running M_Creator.py locally (optional)

If you want to preview what `M.pq` will look like before pushing, you can run the script yourself. You need Python 3.10 or later installed.

From the repository root in a terminal:

```
python "PQ Custom Library/M_Creator.py"
```

This overwrites `PQ Custom Library/M.pq` locally with the regenerated version. You can then inspect or copy it before committing.
