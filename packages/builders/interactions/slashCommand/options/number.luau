--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Object = require("@deps/polyfill/object")

-- Slash Command Mixins
local ApplicationCommandOptionBase = require("../mixins/applicationCommandOptionBase")

-- Class
local SlashCommandNumberOption = {}
SlashCommandNumberOption.interface = {}
SlashCommandNumberOption.prototype = {}
SlashCommandNumberOption.prototype.__type = "SlashCommandNumberOption"

function SlashCommandNumberOption.prototype.setMaxValue(self: SlashCommandNumberOption, max: number)
    self.max_value = max

    return self
end

function SlashCommandNumberOption.prototype.setMinValue(self: SlashCommandNumberOption, min: number)
    self.min_value = min

    return self
end

function SlashCommandNumberOption.prototype.toJSON(self: SlashCommandNumberOption)
    local newData = Object.assign({}, self.super:toJSON(), {
        min_value = self.min_value,
        max_value = self.max_value
    })
    return newData 
end

function SlashCommandNumberOption.interface.new(): SlashCommandNumberOption
    return class({ max_value = nil, min_value = nil }, SlashCommandNumberOption.prototype):extend(ApplicationCommandOptionBase.new(ApplicationCommandOptionBase.Type.Number))
end

export type SlashCommandNumberOptionProperties = {
    max_value: number?,
    min_value: number?
}

export type SlashCommandNumberOption = typeof(SlashCommandNumberOption.prototype) & SlashCommandNumberOptionProperties & ApplicationCommandOptionBase.ApplicationCommandOptionBase & {
    super: ApplicationCommandOptionBase.ApplicationCommandOptionBase
}

return SlashCommandNumberOption.interface