---
description: 'Git branch and tag naming with PBIP repository layout standards'
applyTo: '**'
---

## Git and Repo Standards

Use main as the default branch.

Use dev as the integration and development branch.

Use feature branches in the form feature/feature-name.

Use hotfix branches in the form hotfix/description.

Create hotfix branches from the current production tag.

Tag releases with this format: ReportName-vYYYY.MM.DD.N.

Use one repository per report solution.

Use PBIP format for the report project.

Keep .github and .vscode folders at the report root.

Keep this report-root layout:

```text
ReportName.pbip
ReportName.Report/
ReportName.SemanticModel/
.github/
.vscode/
```

Use branch-to-environment routing:

- feature/* routes to development-only testing artifacts.
- dev routes to integrated development and UAT artifacts.
- main or release/* routes to production artifacts.
- hotfix/* routes to production, then merges back to dev.

Use this artifact naming pattern by environment:

- Development: Report Name-Dev
- Production: Report Name
