# Web Connector (Power Query)

Short summary
- The Web connector (`Web.Page`, `Web.Contents`, `Web.BrowserContents`) lets Power Query import data from web pages and web APIs. It supports loading HTML pages, JSON, XML, CSV, PDF and other file types found on HTTP(S) endpoints.

Key capabilities
- Connect to a URL and import page tables or raw content.
- Advanced options: assemble URLs from parts, set command timeout, and provide HTTP request headers (for `Web.Contents`).
- Import files hosted on the web (JSON, CSV, Excel, PDF, XML, etc.) — Power Query will wrap content in appropriate document functions (e.g., `Json.Document`).

Authentication
- Supported auth types: `Anonymous`, `Windows`, `Basic`, `Web API`, `Organizational account`, and `Service principal` (host/product dependent).
- Notes: service principal is not supported with on-premises or VNet gateways. POST requests may be limited to anonymous in some scenarios.

Product differences & prerequisites
- Some features vary across hosts (Power BI Desktop, Power Query Online, Excel, Fabric). `Web.Page` historically required Internet Explorer components; `Web.BrowserContents` requires Edge WebView2 runtime.

Common usage patterns & tips
- Use the Basic dialog for simple URLs; use Advanced when you need to build URLs from parts, add headers, or change timeouts.
- Prefer file-specific connectors when your URL points to a known file type (use `Excel` connector for `.xlsx`, `CSV` connector for `.csv`) to preserve folding and parsing.
- When using Power Query Online with the Web Page connector, an on-premises data gateway is often required because of the browser control.

Limitations and troubleshooting
- Navigator detects HTML tables; use Web View or "Add table using examples" to extract non-tabular content.
- Long-running POST requests may need increased `Command timeout`.
- Authentication scope is applied per URL prefix — set carefully to avoid unintended credential reuse.

Source
- Microsoft Docs: Web connector — https://learn.microsoft.com/en-us/power-query/connectors/web/web
