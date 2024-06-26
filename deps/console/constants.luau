type LogLevel = {
    ["debug"]: number,
	["log"]: number,
	["warn"]: number,
	["error"]: number,
	["critical"]: number,
}

type ConsoleConstant = {
    DefaultSchema: string,
    MaximumCached: number,
    ArbitraryLargeNumber: number,
    PrettyTableTab: string,
    LogLevel: LogLevel
}

local LogLevel = {
    ["debug"] = 1,
	["log"] = 2,
	["warn"] = 3,
	["error"] = 4,
	["critical"] = 5,
}

return table.freeze {
    DefaultSchema = "%s [%s] %s :: %s (file: %s)",
    MaximumCached = 500,
    ArbitraryLargeNumber = 9999999,
    PrettyTableTab = string.rep("\t", 1),
    LogLevel = LogLevel
} :: ConsoleConstant