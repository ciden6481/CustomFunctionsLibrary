---
agent: agent
description: Review a Power Query file and suggest improvements for performance, efficiency, clarity, and readability without changing query results.
tools: [execute, read, agent, edit, search, 'microsoftdocs/mcp/*', 'pqlint-mcp/*']
---

# Power Query Improvement Review

Evaluate a Power Query M query and provide safe, high-value improvement suggestions.

## Inputs
- Target file: ${input:filePath}
- Optional scope: ${input:scope}
- Optional strictness: ${input:strictness}

Input behavior:
- If filePath is empty, use the currently active .pq or .m file.
- If scope is empty, review the full query.
- If strictness is empty, use `balanced`.

Valid strictness values:
- `conservative`: only low-risk suggestions
- `balanced`: low and medium-risk suggestions with rationale
- `aggressive`: include larger refactors, still no result changes

## Objectives
1. Preserve query results exactly.
2. Balance performance, efficiency, clarity, and readability.
3. Preserve query folding when possible.
4. Do not prioritize folding over clearly better clarity/performance decisions.

## Review Process
1. Map the query flow and identify high-cost or hard-to-read steps.
2. Check likely folding boundaries and note where folding may stop.
3. Identify redundant operations, repeated transforms, late filters, and unnecessary materialization.
4. Propose edits that keep output semantics unchanged.
5. When useful, propose splitting into multiple queries/functions and explain why that is preferable.

## Guardrails
- Do not change business logic or output schema unless explicitly requested.
- Do not remove intentional transformations without evidence they are redundant.
- Avoid speculative changes that require unknown source assumptions.
- Prefer parameterization for environment-specific values when practical.

## Suggestion Priorities
- Early row/column reduction where folding allows it.
- Type assignment before type-dependent operations.
- Consolidation of repetitive transforms when it improves readability.
- Clear authored step names and concise intent comments.
- Function extraction or staging queries when complexity is high.

## Required Output Format
Return sections in this order:

1. `Summary`
- 2-4 bullets describing overall query health and biggest opportunities.

2. `Findings`
- Ordered by impact: High, Medium, Low.
- For each finding include:
  - Issue
  - Why it matters
  - Suggested change
  - Risk level
  - Folding impact: Improves, Neutral, or May Reduce

3. `No-Behavior-Change Check`
- State why suggested changes should preserve results.
- List any assumptions that must hold.

4. `Optional Split Plan`
- Include only if splitting is recommended.
- Show proposed query/function boundaries and benefits.

5. `Patch Candidate`
- Always provide a candidate revised query that applies the recommended improvements.
- Keep the patch candidate behavior-preserving and aligned with the selected strictness.

## Style
- Be specific and actionable.
- Prefer concise explanations over long theory.
- Explicitly call out uncertainty instead of guessing.
