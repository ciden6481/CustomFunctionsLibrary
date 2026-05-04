---
agent: agent
model: Claude Sonnet 4.5
---
<!-- markdownlint-disable-file -->

# Implementation Prompt: PQ Custom Library Build

## Implementation Instructions

### Step 1: Create Changes Tracking File

You WILL create `20260504-pq-custom-library-changes.md` in #file:../changes/ if it does not exist.

### Step 2: Execute Implementation

You WILL follow #file:../../.github/instructions/power-query-m-best-practices.instructions.md  
You WILL systematically implement #file:../plans/20260504-pq-custom-library-plan.instructions.md task-by-task  
You WILL follow ALL project standards and conventions

**CRITICAL**: If ${input:phaseStop:true} is true, you WILL stop after each Phase for user review.  
**CRITICAL**: If ${input:taskStop:false} is true, you WILL stop after each Task for user review.

### Implementation Notes

#### Phase 1 — Directory structure and sample function
- Create category folders with `.gitkeep` files for empty folders (Text, Table, List, Number).
- Create `PQ Custom Library/Functions/Date/QuarterLabel.pq` using the exact code in the details file (Lines 17–62).
- The function uses: `Date.Month`, `Date.Year`, `Number.Mod`, `Number.IntegerDivide`, `Number.ToText`, `Value.ReplaceType` — these must all be present in the generated M.pq environment.

#### Phase 2 — Function template
- File goes at `PQ Custom Library/FunctionTemplate.pq` (NOT inside Functions/).
- Include comment blocks labeled `// [REQUIRED PARAM — copy this block to add more]` and `// [OPTIONAL PARAM — copy or remove this block]`.
- Include a naming convention note at the top: folder name becomes the category prefix, file name becomes the function name. Example: `Functions/Date/MyFunc.pq` → `M[Date.MyFunc](args)`.

#### Phase 3 — M_Creator.py
- The script must embed the full M_Code string from Phase 4 with `#TextToReplace` as the placeholder.
- Use `os.path.dirname(os.path.abspath(__file__))` to locate the Functions directory and output M.pq regardless of cwd.
- Scan path: `<script_dir>/Functions/`
- Output path: `<script_dir>/M.pq`
- Keep the original exclusion list from OscarValerock/PowerQueryFunctions verbatim — it is comprehensive and well-maintained. Add `'Text.Replace'` check — the original exclusion of `Text.ReplaceMany` is fine but make sure `Text.Replace` is NOT excluded (it IS a standard PQ function we need).
- Add `manual_strings` for any functions that are used via string/dynamic patterns that regex might miss: at minimum `['Number.Abs', 'Value.ReplaceType']`.

#### Phase 4 — M.pq
- Use the code structure from details Lines 177–250.
- The initial committed version should already have M native functions populated (run M_Creator.py locally after creating the sample function, or hand-craft the environment with the known functions from QuarterLabel.pq plus common ones).
- Minimum required native functions for QuarterLabel.pq: `Binary.FromText`, `Date.Month`, `Date.Year`, `Expression.Evaluate`, `ExtraValues.Error`, `Json.Document`, `Number.IntegerDivide`, `Number.Mod`, `Number.ToText`, `Splitter.SplitByNothing`, `Table.AddColumn`, `Table.ExpandRecordColumn`, `Table.FromList`, `Table.SelectColumns`, `Table.SelectRows`, `Text.EndsWith`, `Text.FromBinary`, `Text.Replace`, `Text.StartsWith`, `Value.ReplaceType`, `Value.ReplaceMetadata`, `Web.Contents`.

#### Phase 5 — GitHub Actions
- File path: `.github/workflows/generate-mpq.yml`
- Use exact YAML from details file (Lines 252–305).
- Do NOT use `git push --force`. The regular `git push` is safe here because `[skip ci]` prevents loops and the workflow always runs on latest main.

### Step 3: Cleanup

When ALL Phases are checked off (`[x]`) and completed you WILL do the following:

1. You WILL provide a markdown style link and a summary of all changes from #file:../changes/20260504-pq-custom-library-changes.md to the user:

   - You WILL keep the overall summary brief
   - You WILL add spacing around any lists
   - You MUST wrap any reference to a file in a markdown style link

2. You WILL provide markdown style links to .copilot-tracking/plans/20260504-pq-custom-library-plan.instructions.md, .copilot-tracking/details/20260504-pq-custom-library-details.md, and .copilot-tracking/research/20260504-pq-custom-library-research.md documents. You WILL recommend cleaning these files up as well.

3. **MANDATORY**: You WILL attempt to delete .copilot-tracking/prompts/implement-pq-custom-library.prompt.md

## Success Criteria

- [ ] Changes tracking file created
- [ ] Phase 1: `PQ Custom Library/Functions/` with 5 category dirs + `Date/QuarterLabel.pq`
- [ ] Phase 2: `PQ Custom Library/FunctionTemplate.pq`
- [ ] Phase 3: `PQ Custom Library/M_Creator.py`
- [ ] Phase 4: `PQ Custom Library/M.pq` (functional, with native function env populated)
- [ ] Phase 5: `.github/workflows/generate-mpq.yml`
- [ ] All plan items implemented
- [ ] Project conventions followed
- [ ] Changes file updated continuously
