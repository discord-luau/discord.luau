--!strict

-- Standard Libraries
local class = require("@std/class")

-- Slash Command Mixins
local ApplicationCommandOptionBase = require("../mixins/applicationCommandOptionBase")



local SlashCommandBooleanOption = {}
SlashCommandBooleanOption.interface = {}
SlashCommandBooleanOption.prototype = {}
SlashCommandBooleanOption.prototype.__type = "SlashCommandBooleanOption"

function SlashCommandBooleanOption.prototype.toJSON(self: SlashCommandBooleanOption): any
    return self.super:toJSON() 
end

function SlashCommandBooleanOption.interface.new(): SlashCommandBooleanOption
    return class({}, SlashCommandBooleanOption.prototype):extend(ApplicationCommandOptionBase.new(ApplicationCommandOptionBase.Type.Boolean))
end

export type SlashCommandBooleanOption = typeof(SlashCommandBooleanOption.prototype) & ApplicationCommandOptionBase.ApplicationCommandOptionBase & {
    super: ApplicationCommandOptionBase.ApplicationCommandOptionBase
}

return SlashCommandBooleanOption.interface