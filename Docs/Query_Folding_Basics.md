<!-- Source: https://learn.microsoft.com/en-us/power-query/query-folding-basics -->
# Query folding basics (overview)

This document explains how Power Query optimizes M scripts by pushing transforms to the data source when possible (query folding).

Key concepts:
- Query folding attempts to translate M transforms into the native query language of the data source (for example SQL) and execute them at the source.
- Outcomes: Full query folding, Partial query folding, No query folding.
- Use the Applied Steps UI and query folding indicators to determine which steps fold.
- Use `Value.NativeQuery` to issue native SQL while preserving folding when supported by the connector.

High-level evaluation steps:
1. M script submitted to Power Query engine
2. Engine optimizes and determines which transforms can fold
3. Data source requested for folded portion
4. Power Query engine handles non-folded transforms
5. Results loaded

Read the full article for examples and diagnostics: https://learn.microsoft.com/en-us/power-query/query-folding-basics
