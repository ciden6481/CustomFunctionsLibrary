---
name: snippet-metadata-maintenance
description: 'Audit and maintain Snippets metadata and index documentation. Use when asked to check snippet headers, add missing snippet description comments, refresh Snippets/README.md, or prepare snippet files for commit. Triggers: snippet metadata, snippet header, update snippets readme, validate snippets, pre-commit snippet checks.'
argument-hint: 'Optional scope: staged files only or all Snippets files.'
user-invocable: true
---

# Snippet Metadata Maintenance

Keep Snippets files and Snippets README in sync using repository automation scripts.

## When to Use This Skill

- User asks to verify snippet header metadata.
- User asks to refresh Snippets README from snippet files.
- User wants snippet files commit-ready.
- Pre-commit validation fails due to missing snippet metadata.

## Required Metadata Header Format

Use these top-of-file comments in snippet .pq files:

- // @snippet.title: Human-friendly snippet name
- // @snippet.description: One-line purpose of the snippet
- // @snippet.tags: optional, comma-separated tags

## Workflow

1. Determine scope.
- Default to all Snippets .pq files.
- Use staged-only scope when asked for commit-focused validation.

2. Run metadata validation.
- Staged scope: powershell -NoProfile -File scripts/validate-snippet-metadata.ps1 -StagedOnly
- Full scope: powershell -NoProfile -File scripts/validate-snippet-metadata.ps1

3. If validation fails, fix missing headers.
- For each failing file, add at least:
  - // @snippet.description: concise one-line purpose
- Add title and tags when practical.

4. Regenerate Snippets index.
- Run: powershell -NoProfile -File scripts/update-snippets-readme.ps1

5. Re-run validation and report outcome.
- Confirm validation passes.
- Summarize files changed and any placeholders used.

## Quality Checks

- Every target .pq file contains @snippet.description.
- Snippets README is regenerated and aligned with current files.
- Header comments are concise and specific.
- No unrelated files are modified.

## Gotchas

- If a snippet has no metadata, pre-commit will fail until @snippet.description is added.
- Snippets README is generated output; avoid hand-editing sections that the script owns.
- Keep descriptions short and stable to reduce documentation churn.
