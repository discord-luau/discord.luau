-- Modules
local class = require("@std/class")

local Console = require("@deps/console")

local Messages = require("messages")
local ErrorCodes = require("errorCodes")

local Error = {}
Error.interface = {}
Error.prototype = {}
Error.prototype.__type = "Error"

function Error.prototype._message(self: Error, code: string, args: { string })
    if not ErrorCodes[code] then
        self.reporter:error("Error code must be a valid DiscordLuauErrorCodes")
    end

    local msg = Messages[code]
    if not msg then
        self.reporter:error("No message associated with error code: " .. code)
    end

    if typeof(msg) == "function" then
        return msg(table.unpack(args))
    end

    if #args == 0 then
        return msg
    end

    table.insert(args, 1, msg)
    return string.format(table.unpack(args))
end

function Error.prototype.log(self: Error, code: string, ...: string)
    local args = { ... }
    local errMessage = self:_message(code, args)
    
    self.reporter:error(errMessage)
end

function Error.interface.new(name: string): Error
    return class({
        reporter = Console.new('🚨 ' .. name)
    }, Error.prototype)
end

export type Error = typeof(Error.prototype) & {
    reporter: Console.Console
}

return Error.interface