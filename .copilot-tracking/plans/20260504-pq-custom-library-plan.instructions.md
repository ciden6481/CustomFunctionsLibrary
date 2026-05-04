---
applyTo: ".copilot-tracking/changes/20260504-pq-custom-library-changes.md"
---

<!-- markdownlint-disable-file -->

# Task Checklist: PQ Custom Library Build

## Overview

Build a modular Power Query custom function library in `PQ Custom Library/` that loads from GitHub via API and is fully compatible with Power BI Service.

## Objectives

- Create an organized function directory structure under `PQ Custom Library/Functions/` with category subdirectories.
- Deliver a `PQ Custom Library/M.pq` load query that fetches and hydrates functions from this GitHub repo at report refresh time.
- Deliver an enhanced `PQ Custom Library/FunctionTemplate.pq` with clear guidance for dynamic parameter counts.
- Deliver an adapted `PQ Custom Library/M_Creator.py` that regenerates `M.pq` when functions are added or changed.
- Set up a GitHub Actions workflow that auto-runs `M_Creator.py` and commits an updated `M.pq` on push.

## Research Summary

### Project Files

- `PQ Custom Library/` - target directory; currently empty, all files to be created here.
- `.github/workflows/` - existing workflows directory for GitHub Actions.

### External References

- #file:../research/20260504-pq-custom-library-research.md - Full analysis of reference project, Power BI Service compatibility findings, structural design decisions.
- Reference repo: https://github.com/OscarValerock/PowerQueryFunctions — source M.pq and M_Creator.py patterns.

### Standards References

- #file:../../.github/instructions/power-query-m-best-practices.instructions.md - PQ M language conventions.

## Implementation Checklist

### [ ] Phase 1: Directory Structure & Sample Functions

- [ ] Task 1.1: Create category subdirectories with placeholder `.gitkeep` files and at least one real sample function per category.

  - Details: .copilot-tracking/details/20260504-pq-custom-library-details.md (Lines 17–62)

### [ ] Phase 2: Function Template

- [ ] Task 2.1: Create `PQ Custom Library/FunctionTemplate.pq` with enhanced multi-parameter template and inline guidance.

  - Details: .copilot-tracking/details/20260504-pq-custom-library-details.md (Lines 64–115)

### [ ] Phase 3: M_Creator.py (Build Script)

- [ ] Task 3.1: Create `PQ Custom Library/M_Creator.py` adapted for this repo's structure and naming.

  - Details: .copilot-tracking/details/20260504-pq-custom-library-details.md (Lines 117–175)

### [ ] Phase 4: M.pq (Load Query)

- [ ] Task 4.1: Create `PQ Custom Library/M.pq` using the recursive GitHub Trees API approach adapted for this repo.

  - Details: .copilot-tracking/details/20260504-pq-custom-library-details.md (Lines 177–250)

### [ ] Phase 5: GitHub Actions Workflow

- [ ] Task 5.1: Create `.github/workflows/generate-mpq.yml` to auto-regenerate `M.pq` on push when function files change.

  - Details: .copilot-tracking/details/20260504-pq-custom-library-details.md (Lines 252–305)

## Dependencies

- Python 3.x (for M_Creator.py, runs in CI via GitHub Actions)
- GitHub repo: `ciden6481/CustomFunctionsLibrary` (confirmed via `git remote get-url origin`)
- GitHub Personal Access Token (PAT) with read-only Contents scope — to be filled into `M.pq`'s PAT parameter by user at publish time
- GitHub Actions workflow permissions: `contents: write` to allow the auto-commit step

## Success Criteria

- `M.pq` can be pasted into Power Query, renamed to `M`, and called as `M[Category.FunctionName](args)`.
- Report using this library publishes and refreshes successfully in Power BI Service without local file dependencies.
- Adding a new `.pq` function file and pushing triggers the workflow, which regenerates and commits `M.pq` automatically.
- `FunctionTemplate.pq` clearly guides creation of functions with any number of required and optional parameters.
