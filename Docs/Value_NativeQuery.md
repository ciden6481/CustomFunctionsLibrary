<!-- Source: https://learn.microsoft.com/en-us/powerquery-m/value-nativequery -->
# Value.NativeQuery (reference excerpt)

Syntax:

```
Value.NativeQuery(
    target as any,
    query as text,
    optional parameters as any,
    optional options as nullable record
) as any
```

About:
- Evaluates `query` against `target` (native query language for target, e.g. T-SQL).
- `parameters` can be a list or record for parameter values.
- `options` can affect evaluation behavior and are target-specific.

Use `Value.NativeQuery` when you need to execute a native statement and (when supported) preserve folding for subsequent steps.

Full doc: https://learn.microsoft.com/en-us/powerquery-m/value-nativequery
