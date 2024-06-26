--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Object = require("@deps/polyfill/object")

-- Slash Command Mixins
local ApplicationCommandOptionBase = require("../mixins/applicationCommandOptionBase")

-- Class
local SlashCommandIntegerOption = {}
SlashCommandIntegerOption.interface = {}
SlashCommandIntegerOption.prototype = {}
SlashCommandIntegerOption.prototype.__type = "SlashCommandIntegerOption"

function SlashCommandIntegerOption.prototype.setMaxValue(self: SlashCommandIntegerOption, max: number)
    self.max_value = max

    return self
end

function SlashCommandIntegerOption.prototype.setMinValue(self: SlashCommandIntegerOption, min: number)
    self.min_value = min

    return self
end

function SlashCommandIntegerOption.prototype.toJSON(self: SlashCommandIntegerOption): any
    local newData = Object.assign({}, self.super:toJSON(), {
        min_value = self.min_value,
        max_value = self.max_value
    })
    return newData 
end

function SlashCommandIntegerOption.interface.new(): SlashCommandIntegerOption
    return class({ max_value = nil, min_value = nil }, SlashCommandIntegerOption.prototype):extend(ApplicationCommandOptionBase.new(ApplicationCommandOptionBase.Type.Integer))
end

export type SlashCommandIntegerOptionProperties = {
    max_value: number?,
    min_value: number?
}

export type SlashCommandIntegerOption = typeof(SlashCommandIntegerOption.prototype) & SlashCommandIntegerOptionProperties & ApplicationCommandOptionBase.ApplicationCommandOptionBase & {
    super: ApplicationCommandOptionBase.ApplicationCommandOptionBase
}

return SlashCommandIntegerOption.interface