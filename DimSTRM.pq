let
    Source = PowerPlatform.Dataflows(null),
    Workspaces = Source{[Id = "Workspaces"]}[Data],
    #"9ce987dd-bb20-481a-8e3a-29b46e44d9eb" = Workspaces{
        [workspaceId = "9ce987dd-bb20-481a-8e3a-29b46e44d9eb"]
    }[Data],
    #"45d21b8a-3a1f-4930-a41a-1cd8df82f89f" = #"9ce987dd-bb20-481a-8e3a-29b46e44d9eb"{
        [dataflowId = "45d21b8a-3a1f-4930-a41a-1cd8df82f89f"]
    }[Data],
    #"STRM Table_" = #"45d21b8a-3a1f-4930-a41a-1cd8df82f89f"{[entity = "STRM Table", version = ""]}[Data],
    #"Filtered Rows" = Table.SelectRows(
        #"STRM Table_",
        each
            (
                [STRM] = "2174"
                or [STRM] = "2182"
                or [STRM] = "2183"
                or [STRM] = "2184"
                or [STRM] = "2192"
                or [STRM] = "2193"
                or [STRM] = "2194"
                or [STRM] = "2202"
                or [STRM] = "2203"
                or [STRM] = "2204"
                or [STRM] = "2212"
                or [STRM] = "2213"
                or [STRM] = "2214"
                or [STRM] = "2222"
                or [STRM] = "2223"
                or [STRM] = "2224"
                or [STRM] = "2232"
                or [STRM] = "2233"
                or [STRM] = "2234"
                or [STRM] = "2242"
                or [STRM] = "2243"
                or [STRM] = "2244"
                or [STRM] = "2252"
            )
    )
in
    #"Filtered Rows"
