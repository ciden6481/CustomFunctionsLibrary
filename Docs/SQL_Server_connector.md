<!-- Source: https://learn.microsoft.com/en-us/power-query/connectors/sql-server -->
# SQL Server connector (summary)

Key points:

- Connector: `Sql.Database`, `Sql.Databases` (see M function reference).
- Supports Import and DirectQuery (in Power BI Desktop semantic models).
- Authentication: Database/Basic, Windows, Organizational account (if supported), Service principal.
- Advanced options: command timeout, native SQL statement, include relationship columns, navigate using full hierarchy, failover support.
- Limitations: Always Encrypted columns unsupported, some auth types may be unsupported, certificate trust issues may require environment variable or gateway config (`PBI_SQL_TRUSTED_SERVERS`, `SqlTrustedServers`).

Connect: in Navigator choose database and `Transform Data` to edit in Power Query.

Full doc: https://learn.microsoft.com/en-us/power-query/connectors/sql-server
