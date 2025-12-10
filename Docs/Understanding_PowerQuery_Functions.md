<!-- Source: https://learn.microsoft.com/en-us/powerquery-m/understanding-power-query-m-functions -->
# Understanding Power Query M functions (excerpt)

This document explains M functions, parameters, recursion, and the `each` shorthand. Key points:

- Functions are values and are defined using `(params) => expression`.
- Use `as <type>` annotations when you need explicit typing (e.g., `(x as number) as number => x + 1`).
- `each` is shorthand for `(_) => ...` and is commonly used in table transforms.
- Recursive functions use the `@` operator to reference themselves.

Example (explicit):

```powerquery
let
    AddOne = (x as number) as number => x + 1,
    CalcAddOne = AddOne(5)
in
    CalcAddOne
```

Example (`each`):

```powerquery
Table.SelectRows(myTable, each [Weight] > 12)
```

Source and full doc: https://learn.microsoft.com/en-us/powerquery-m/understanding-power-query-m-functions
