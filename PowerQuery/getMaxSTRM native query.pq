MaxSTRM = Value.NativeQuery(
    Source,
    "SELECT 
    EMPLID as EMPLID1,
    MAX(STRM) AS Max_STRM
FROM 
    IR_STUDENT
WHERE 
    STRM <> '2244'
GROUP BY 
    EMPLID",
    null,
    [
        EnableFolding = true
    ]
)
