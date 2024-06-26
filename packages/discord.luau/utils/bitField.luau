-- Standard Libraries
local Class = require("@std/class")

-- Dependencies
local Array = require("@deps/polyfill/array")

local BitField = {}

BitField.interface = {}
BitField.prototype = {}

BitField.prototype.__type = "BitField"

function BitField.prototype.resolve(self: BitField, bit: any): any?
    if typeof(self.DefaultBit) == typeof(bit) and bit >= self.DefaultBit then
        return bit
    end

    if bit.bitfield then
        return bit.bitfield
    end

    if Array.isArray(bit) then
        local mappedBits = Array.map(bit, function(bit_)
            return self:resolve(bit_)
        end)

        local reducedBit = Array.reduce(mappedBits, function(prev, bit_)
            return bit32.bor(prev, bit_ :: number)
        end, self.DefaultBit)

        return reducedBit
    end

    if typeof(bit) == "string" then
        if self.Flags and self.Flags[bit] then
            return self.Flags[bit]
        end
    end

    return nil
end

function BitField.prototype.constructor(self: BitField, bit: any?)
    self.bitfield = self:resolve(bit)
end

function BitField.interface.new(bit: any?, flags: any): BitField
	local self = Class({
        DefaultBit = 0,
        Flags = flags or {}
	}, BitField.prototype)

    self:constructor(bit)

    return self
end


export type BitField = typeof(BitField.prototype) & {
	DefaultBit: number,
    Flags: { [string]: number },
    bitfield: number?,
}

return BitField.interface