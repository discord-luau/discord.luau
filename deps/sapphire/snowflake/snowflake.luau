local bit64 = require("@std/bit")
local Symbol = require("../../polyfill/symbol")
local EpochSymbol = Symbol("@sapphire/snowflake.epoch")

local Snowflake = {}

Snowflake.prototype = {}
Snowflake.interface = {}

Snowflake.prototype.__type = 'Snowflake'

function Snowflake.prototype.timestampFrom(self: Snowflake, id: string)
    local res = bit64(`{id} >> 22`)
    return res + (self :: any)[EpochSymbol]
end

function Snowflake.interface.new(epoch: number | string): Snowflake
    return (setmetatable({
        [EpochSymbol] = tonumber(epoch) :: number
    }, {
        __index = Snowflake.prototype
    }) :: any) :: Snowflake
end

export type Snowflake = { [Symbol.Symbol]: number } & typeof(Snowflake.prototype)

return Snowflake.interface