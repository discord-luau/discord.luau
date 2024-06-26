--!strict

-- Modules
local class = require("@std/class")
local enum = require("@std/enum")

-- API
local ApplicationCommandApi = require("@discordluau/api/payloads/interactions/applicationCommand")
local CommonApi = require("@discordluau/api/payloads/common")

-- Core Package Utilities
local PermissionsBitField = require("@discordluau/discord.luau/utils/PermissionsBitField")

-- Slash Command Options
local SlashCommandOption = require("options")

-- Enumerations
local PermissionFlagBits = CommonApi.PermissionFlagsBits
local ApplicationCommandType = ApplicationCommandApi.ApplicationCommandType
local InteractionContextType = ApplicationCommandApi.InteractionContextType


local SlashCommandBuilder = {}

SlashCommandBuilder.interface = {}
SlashCommandBuilder.prototype = { }

SlashCommandBuilder.prototype.__type = "SlashCommandBuilder"


function SlashCommandBuilder.prototype.setType(self: SlashCommandBuilder, commandType: number): SlashCommandBuilder
	assert(InteractionContextType:is(commandType), `Expected 'commandType' to of enum 'commandType'`)

	self.commandType = commandType

	return self
end

function SlashCommandBuilder.prototype.setLocalization(self: SlashCommandBuilder, localizationCode: string): SlashCommandBuilder
	self.commandLocalization = localizationCode

	return self
end

function SlashCommandBuilder.prototype.setDescription(self: SlashCommandBuilder, description: string): SlashCommandBuilder
	self.commandDescription = description

	return self
end

function SlashCommandBuilder.prototype.setName(self: SlashCommandBuilder, name: string): SlashCommandBuilder
	self.commandName = name

	return self
end

function SlashCommandBuilder.prototype.setNSFW(self: SlashCommandBuilder, isNSFW: boolean): SlashCommandBuilder
	self.commandNSFW = isNSFW

	return self
end

function SlashCommandBuilder.prototype.setDMPermission(self: SlashCommandBuilder, canDM: boolean): SlashCommandBuilder
	self.commandDM = canDM

	return self
end

function SlashCommandBuilder.prototype.setDefaultMemberPermissions(self: SlashCommandBuilder, permissionObject: PermissionsBitField.PermissionsBitField): SlashCommandBuilder
	self.commandPermissions = permissionObject

	return self
end

function SlashCommandBuilder.prototype.addBooleanOption(self: SlashCommandBuilder, callback: (SlashCommandOption.SlashCommandBooleanOption) -> ()): SlashCommandBuilder
	local commandObject = SlashCommandOption.Boolean.new()
	callback(commandObject)

	table.insert(self.options, commandObject)

	return self
end

function SlashCommandBuilder.prototype.addNumberOption(self: SlashCommandBuilder, callback: (SlashCommandOption.SlashCommandNumberOption) -> ()): SlashCommandBuilder
	local commandObject = SlashCommandOption.Number.new()
	callback(commandObject)

	table.insert(self.options, commandObject)

	return self
end

function SlashCommandBuilder.prototype.addIntegerOption(self: SlashCommandBuilder, callback: (SlashCommandOption.SlashCommandIntegerOption) -> ()): SlashCommandBuilder
	local commandObject = SlashCommandOption.Integer.new()
	callback(commandObject)

	table.insert(self.options, commandObject)

	return self
end

function SlashCommandBuilder.prototype.addStringOption(self: SlashCommandBuilder, callback: (SlashCommandOption.SlashCommandStringOption) -> ()): SlashCommandBuilder
	local commandObject = SlashCommandOption.String.new()
	callback(commandObject)

	table.insert(self.options, commandObject)

	return self
end

function SlashCommandBuilder.prototype.addUserOption(self: SlashCommandBuilder, callback: (SlashCommandOption.SlashCommandUserOption) -> ()): SlashCommandBuilder
	local commandObject = SlashCommandOption.User.new()
	callback(commandObject)

	table.insert(self.options, commandObject)

	return self
end

function SlashCommandBuilder.prototype.addAttachmentOption(self: SlashCommandBuilder, callback: (SlashCommandOption.SlashCommandAttachmentOption) -> ()): SlashCommandBuilder
	local commandObject = SlashCommandOption.Attachment.new()
	callback(commandObject)

	table.insert(self.options, commandObject)

	return self
end

function SlashCommandBuilder.prototype.setDefaultPermissionEnabled(self: SlashCommandBuilder, enabled: boolean): SlashCommandBuilder
	self.defaultPermissionEnabled = enabled

	return self
end

function SlashCommandBuilder.prototype.addContext(self: SlashCommandBuilder, context: number): SlashCommandBuilder
	table.insert(self.contexts, context)

	return self
end


function SlashCommandBuilder.prototype.toJSON(self: SlashCommandBuilder)
	local permissions = "0"
    local contexts = {}
	local options = {}

	for _, commandOption in self.options do
		local opt = (commandOption :: any):toJSON()
		-- print('Resolved', opt)
		-- print('Raw', commandOption) 
		table.insert(options, opt)
	end


	if self.commandPermissions then
		permissions = self.commandPermissions:getValue()
	else
		permissions = PermissionsBitField.from(PermissionFlagBits.UseApplicationCommands):getValue()
	end

	if #self.contexts == 0 then
		table.insert(self.contexts, InteractionContextType.Guild)
	end

    for index, context in self.contexts do
		contexts[tostring(index)] = context
	end

	return {
		type = self.commandType,
		name = self.commandName,
		description = self.commandDescription,

		nsfw = self.commandNSFW,

		default_permission = self.defaultPermissionEnabled,
		default_member_permissions = permissions,
		dm_permission = self.commandDM,

		contexts = contexts,

		name_localizations = self.commandLocalization,
		description_localizations = self.commandLocalization,

		options = (#options > 0 and options) or nil,
	}
end

--[=[
	@function new
	@within SlashCommandBuilder

	@return SlashCommandBuilder
]=]
function SlashCommandBuilder.interface.new(type: number?): SlashCommandBuilder
	return (class({
		commandType = type or ApplicationCommandApi.ApplicationCommandType.ChatInput,
		options = {},
		contexts = {}
	}, SlashCommandBuilder.prototype) :: any) :: SlashCommandBuilder
end

export type SlashCommandBuilder = typeof(SlashCommandBuilder.prototype) & {
	commandLocalization: string,
	commandDM: boolean,

	commandDescription: string,
	commandName: string,
	commandType: number,
	commandNSFW: boolean,

    defaultPermissionEnabled: boolean?,

	contexts: { number },
	commandPermissions: PermissionsBitField.PermissionsBitField,
	options: { SlashCommandOption.SlashCommandSharedOption }
}

return SlashCommandBuilder.interface