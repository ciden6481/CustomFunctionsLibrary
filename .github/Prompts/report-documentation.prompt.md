---
description: 'Generate report documentation using the organizational report documentation template'
name: 'report-documentation'
agent: 'ask'
---

# Report Documentation Generator

Use this input:

- Report name: ${input:reportName}

Use this template source and preserve its section structure:

- docs/410-report-documentation-template.md

Gather available context from open project files such as TMDL, BIM, M queries, and README content to prefill sections when possible.

Generate a complete markdown document with these sections populated:

1. Business Purpose
2. Audience
3. Data Sources
4. Key Tables
5. Critical Measures
6. Model Deviations from Standard
7. Change Log stub

When information is missing, insert a clear placeholder stating what the developer must provide.

Output a complete markdown document suitable to save as docs/{reportName}-documentation.md.
