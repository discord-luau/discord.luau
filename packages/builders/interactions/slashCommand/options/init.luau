local SlashCommandAttachmentOption = require("attachment")
local SlashCommandBooleanOption = require("boolean")
local SlashCommandIntegerOption = require("integer")
local SlashCommandNumberOption = require("number")
local SlashCommandStringOption = require("string")
local SlashCommandUserOption = require("user")

export type SlashCommandAttachmentOption = SlashCommandAttachmentOption.SlashCommandAttachmentOption
export type SlashCommandBooleanOption = SlashCommandBooleanOption.SlashCommandBooleanOption
export type SlashCommandIntegerOption = SlashCommandIntegerOption.SlashCommandIntegerOption
export type SlashCommandNumberOption = SlashCommandNumberOption.SlashCommandNumberOption
export type SlashCommandStringOption = SlashCommandStringOption.SlashCommandStringOption
export type SlashCommandUserOption = SlashCommandUserOption.SlashCommandUserOption

export type SlashCommandSharedOption = SlashCommandAttachmentOption | SlashCommandBooleanOption | SlashCommandIntegerOption | SlashCommandNumberOption | SlashCommandStringOption | SlashCommandUserOption

return {
    Attachment = SlashCommandAttachmentOption,
    Boolean = SlashCommandBooleanOption,
    Integer = SlashCommandIntegerOption,
    Number = SlashCommandNumberOption,
    String = SlashCommandStringOption,
    User = SlashCommandUserOption
}