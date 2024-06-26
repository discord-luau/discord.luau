--!strict

-- Standard Libraries
local class = require("@std/class")

-- Slash Command Mixins
local ApplicationCommandOptionBase = require("../mixins/applicationCommandOptionBase")

-- Class
local SlashCommandUserOption = {}
SlashCommandUserOption.interface = {}
SlashCommandUserOption.prototype = {}
SlashCommandUserOption.prototype.__type = "SlashCommandUserOption"

function SlashCommandUserOption.prototype.toJSON(self: SlashCommandUserOption): any
    return self.super:toJSON() 
end

function SlashCommandUserOption.interface.new(): SlashCommandUserOption
    return class({}, SlashCommandUserOption.prototype):extend(ApplicationCommandOptionBase.new(ApplicationCommandOptionBase.Type.User))
end

export type SlashCommandUserOption = typeof(SlashCommandUserOption.prototype) & ApplicationCommandOptionBase.ApplicationCommandOptionBase & {
    super: ApplicationCommandOptionBase.ApplicationCommandOptionBase
}

return SlashCommandUserOption.interface