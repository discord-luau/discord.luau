local Date = require("@std/datetime")
local Task = require("@std/task")

local Chalk = require("@deps/chalk")

local Constants = require("constants")

local DEFAULT_SCHEMA = Constants.DefaultSchema
local MAXIMUM_CACHED = Constants.MaximumCached
local ARBITRARY_LARGE_NUMBER = Constants.ArbitraryLargeNumber
local PRETTY_TABLE_TAB = Constants.PrettyTableTab
local LOG_LEVEL = Constants.LogLevel
local UUID_TEMPLATE ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

local random = math.random
local randomseed = math.randomseed

local gsub = string.gsub
local format = string.format
local split = string.split

local clear = table.clear
local concat = table.concat
local insert = table.insert
local remove = table.remove
local unpack = table.unpack

local GLOBAL = {
    Level = 1,
    Schema = DEFAULT_SCHEMA,
    Cache = setmetatable({}, { __mode = "kv" }),
    Instances = {}
}

-- Local Functions
local function generateRandomUUID()
    randomseed(os.time())
    local uuid = gsub(UUID_TEMPLATE, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return format('%x', v)
    end)
    return uuid
end

local function addScopeToString(input: string): string
    local inputSplit = split(input, '\n')

    for index, value in inputSplit do
        if index == 1 then
            continue
        end

        inputSplit[index] = string.format('%s%s', PRETTY_TABLE_TAB, value)
    end

    return concat(inputSplit, '\n')
end

local function toPrettyString<T>(...: T): string
    local stringifiedObjects = {}

    for i = 1, select('#', ...) do
        local object = select(i, ...)
        local objectType = typeof(object)

        if objectType == "table" then
            if GLOBAL.Cache[object] then
                table.insert(stringifiedObjects, `RecursiveTable<{tostring(object)}>`)
                continue
            else
                GLOBAL.Cache[object] = true
            end

            local tableSchema = "{\n"
            local entries = 0

            for key, value in object do
                entries += 1
                key = toPrettyString(key)

                if typeof(value) == "table" then
                    value = addScopeToString(toPrettyString(value))
                else
                    value = toPrettyString(value)
                end

                tableSchema ..= format("%s[%s] = %s,\n", PRETTY_TABLE_TAB, key, value)
            end

            insert(stringifiedObjects, entries == 0 and "{ }" or tableSchema .. "}")
        elseif objectType == "string" then
            insert(stringifiedObjects, format('"%s"', object))
        else
            table.insert(stringifiedObjects, tostring(object))
        end
    end

    return concat(stringifiedObjects, " ")
end

local function formatVaradicArguments<T>(...: T): string
    local args = { ... }
    local message = string.rep("%s ", #args)
    local messageType = typeof(args[1])

    if messageType == "string" then
        local source = remove((args :: any) :: { string }, 1)
        local filteredString = gsub(source :: string, "%%", "%%%%")

        message = filteredString
    end

    for index, value in args do
        args[index] = toPrettyString(value) :: any
    end

    clear(GLOBAL.Cache :: any)

    return format(message, unpack(args))
end

local GLOBAL = {
    Level = 1,
    Schema = DEFAULT_SCHEMA,
    Cache = setmetatable({}, { __mode = "kv" }),
    Instances = {}
}

local Console = {}
Console.prototype = {}

type Log = { level: string, message: string, logId: string }

function Console.prototype._write(self: Console, traceback: boolean, schema: string, source: string, level: string, ...): string
    source = source or debug.info(2, "s")

	local additionalSource = ""

	if traceback then
		local tracebackData = debug.traceback("", 3)

		additionalSource = "\n"
			.. string.format(schema, source, `traceback`, `begin`)
			.. tracebackData
			.. string.format(schema, source, `traceback`, `end`)
	end

    local currentTime = Date.new():toLocale("%Y-%m-%d %H:%M:%S")
    currentTime = Chalk.hex("#89B4FA")(currentTime)

    local hex = "#CDD6F4"

    if level == "error" or level == "critical" then
        hex = "#f85149"
    elseif level == "warn" or level == "debug" then
        hex = "#fab387"                
    end

    source = Chalk.hex(hex)(Chalk.bold(source))

    level = Chalk.hex(hex)(Chalk.bold(string.upper(level)))

	local fileName = ""
	if level == "error" or level == "critical" then
		local info = debug.info(3, "sl")
		fileName = info:match('^%[string "(.-)"%]$')
	else
		local info = debug.info(3, "s")
		fileName = info:match('^%[string "(.-)"%]$')
	end

	local coloredMessage = Chalk.hex(hex)(...)

	local str = format(schema, currentTime, level, source, coloredMessage, fileName)

	return str
end

function Console.prototype.assert(self: Console, condition: boolean, ...): ()
    if not condition then
        self:error(...)
    end
end

function Console.prototype.critical<T>(self: Console, ...: T)
    local output = self:_write(self.traceback, self.schema, self.id, "error", formatVaradicArguments(...))
    local logLevel = if self.level > GLOBAL.Level or self.orphaned then self.level else GLOBAL.Level
    if logLevel > LOG_LEVEL.critical then
        local thread = coroutine.running()

        Task.defer(function()
            Task.cancel(thread)
        end)

        return coroutine.yield()
    end

    error(output, ARBITRARY_LARGE_NUMBER)
end

function Console.prototype.error<T>(self: Console, ...: T)
    local output = self:_write(self.traceback, self.schema, self.id, "error", formatVaradicArguments(...))
    local logLevel = if self.level > GLOBAL.Level or self.orphaned then self.level else GLOBAL.Level
    if logLevel > LOG_LEVEL.error then
        local thread = coroutine.running()

        Task.defer(function()
            Task.cancel(thread)
        end)

        return coroutine.yield()
    end

    error(output, ARBITRARY_LARGE_NUMBER)
end

function Console.prototype.warn<T>(self: Console, ...: T)
    local output = self:_write(self.traceback, self.schema, self.id, "warn", formatVaradicArguments(...))
    local logLevel = if self.level > GLOBAL.Level or self.orphaned then self.level else GLOBAL.Level
    if logLevel > LOG_LEVEL.warn then
       return 
    end

    print(output)
end

function Console.prototype.log<T>(self: Console, ...: T)
    local output = self:_write(self.traceback, self.schema, self.id, "log", formatVaradicArguments(...))
    local logLevel = if self.level > GLOBAL.Level or self.orphaned then self.level else GLOBAL.Level
    if logLevel > LOG_LEVEL.log then
       return 
    end

    print(output)
end

function Console.prototype.debug<T>(self: Console, ...: T)
    local output = self:_write(self.traceback, self.schema, self.id, "debug", formatVaradicArguments(...))
    local logLevel = if self.level > GLOBAL.Level or self.orphaned then self.level else GLOBAL.Level
    if logLevel > LOG_LEVEL.debug then
       return 
    end

    print(output)
end

function Console.prototype.setLogLevel(self: Console, level: number): ()
    self.level = level
end

function Console.prototype.setState(self: Console, state: boolean)
    self.enabled = state
end

function Console.prototype.enable(self: Console)
    if not self.enabled then
        self:setState(true)
    end
end

function Console.prototype.disable(self: Console)
    if self.enabled then
        self:setState(false)
    end
end

function Console.prototype.fetchLogs(self: Console, count: number): { Log }
    local fetchedLogs = {}

	if not count then
		return self.logs
	end

	for index = 1, count do
		if not self.logs[index] then
			return fetchedLogs
		end

		insert(fetchedLogs, self.logs[index])
	end

	return fetchedLogs
end


function Console.prototype.toString(self: Console): string
    return `Console<"{self.id}">`
end

function Console.setGlobalLogLevel(level: number)
    GLOBAL.Level = level
end

function Console.setGlobalSchema(schema: string)
    GLOBAL.Schema = schema
end

function Console.new(logId: string?, schema: string?): Console
    local id = logId or generateRandomUUID() :: string
    local data = {
        id = id,
        level = LOG_LEVEL.debug,
        schema = schema or DEFAULT_SCHEMA,
        traceback = false,
        enabled = true,
        orphaned = false,
        logs = {}
    }

    local self = setmetatable(data, {
        __index = Console.prototype,
        __type = `Console.{id}`,
        __tostring = function(obj: Console)
            return obj:toString() 
        end
    })

    GLOBAL.Instances[self.id] = self

    return (self :: any) :: Console
end

type ConsoleProperties = {
    id: string,
	level: number,
	schema: string,
	enabled: boolean,
	orphaned: boolean,
    traceback: boolean,
	logs: { Log }
}

export type Console = ConsoleProperties & typeof(Console.prototype) 

return Console