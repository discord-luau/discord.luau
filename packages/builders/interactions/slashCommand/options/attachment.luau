--!strict

-- Standard Libraries
local class = require("@std/class")

-- Slash Command Mixins
local ApplicationCommandOptionBase = require("../mixins/applicationCommandOptionBase")



local SlashCommandAttachmentOption = {}
SlashCommandAttachmentOption.interface = {}
SlashCommandAttachmentOption.prototype = {}
SlashCommandAttachmentOption.prototype.__type = "SlashCommandAttachmentOption"

function SlashCommandAttachmentOption.prototype.toJSON(self: SlashCommandAttachmentOption): any
    return self.super:toJSON() 
end

function SlashCommandAttachmentOption.interface.new(): SlashCommandAttachmentOption
    return class({}, SlashCommandAttachmentOption.prototype):extend(ApplicationCommandOptionBase.new(ApplicationCommandOptionBase.Type.Attachment))
end

export type SlashCommandAttachmentOption = typeof(SlashCommandAttachmentOption.prototype) & ApplicationCommandOptionBase.ApplicationCommandOptionBase & {
    super: ApplicationCommandOptionBase.ApplicationCommandOptionBase
}

return SlashCommandAttachmentOption.interface