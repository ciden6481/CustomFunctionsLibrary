let
    Source = (tableName as any) =>
        let
            Source = Oracle.Database("s92qery"), tableFetch = Source{[Schema = "SYSADM", Item = tableName]}[Data]
        in
            tableFetch
in
    Source
