--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Object = require("@deps/polyfill/object")

-- Slash Command Mixins
local ApplicationCommandOptionBase = require("../mixins/applicationCommandOptionBase")

-- Class
local SlashCommandStringOption = {}
SlashCommandStringOption.interface = {}
SlashCommandStringOption.prototype = {}
SlashCommandStringOption.prototype.__type = "SlashCommandStringOption"

function SlashCommandStringOption.prototype.setMaxLength(self: SlashCommandStringOption, max: number)
    self.max_length = max

    return self
end

function SlashCommandStringOption.prototype.setMinLength(self: SlashCommandStringOption, min: number)
    self.min_length = min

    return self
end

function SlashCommandStringOption.prototype.toJSON(self: SlashCommandStringOption)
    local newData = Object.assign({}, self.super:toJSON(), {
        min_length = self.min_length,
        max_length = self.max_length
    })
    return newData 
end

function SlashCommandStringOption.interface.new(): SlashCommandStringOption
    return class({ max_length = nil, min_length = nil }, SlashCommandStringOption.prototype):extend(ApplicationCommandOptionBase.new(ApplicationCommandOptionBase.Type.String))
end

export type SlashCommandStringOptionProperties = {
    max_length: number?,
    min_length: number?
}

export type SlashCommandStringOption = typeof(SlashCommandStringOption.prototype) & SlashCommandStringOptionProperties & ApplicationCommandOptionBase.ApplicationCommandOptionBase & {
    super: ApplicationCommandOptionBase.ApplicationCommandOptionBase
}

return SlashCommandStringOption.interface