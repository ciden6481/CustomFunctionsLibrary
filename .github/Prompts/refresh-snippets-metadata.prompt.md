---
description: 'Audit snippet headers, fix missing metadata, and refresh Snippets README using repository automation scripts.'
name: 'refresh-snippets-metadata'
agent: 'agent'
argument-hint: 'Scope: staged or all (default all).'
---

# Refresh Snippets Metadata

Run the snippet metadata maintenance workflow end-to-end.

Inputs:

- Scope: ${input:scope:all or staged}

Workflow:

1. Load and follow the snippet-metadata-maintenance skill.
2. If scope is staged:
- Validate staged snippet files only.
- Run: powershell -NoProfile -File scripts/validate-snippet-metadata.ps1 -StagedOnly
3. If scope is all or missing:
- Validate all snippet files.
- Run: powershell -NoProfile -File scripts/validate-snippet-metadata.ps1
4. If validation reports missing metadata:
- Add or update required snippet header comments in each failing file.
- Use concise descriptions focused on snippet purpose.
5. Refresh Snippets index:
- Run: powershell -NoProfile -File scripts/update-snippets-readme.ps1
6. Re-run validation for the selected scope.
7. Return a short report with:
- status pass or fail
- files updated
- any placeholder descriptions that still need user refinement

Rules:

- Keep edits limited to Snippets .pq files and Snippets README unless explicitly asked otherwise.
- Preserve existing query logic while adding metadata headers.
- If scope input is invalid, default to all.
