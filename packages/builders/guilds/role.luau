--!strict

-- Standard Libraries
local class = require("@std/class")

-- API
local PermissionsApi = require("@discordluau/api/payloads/permissions")

-- Core Package Utilities
local PermissionsBitField = require("@discordluau/discord.luau/utils/permissionsBitField")

local RoleBuilder = {}

RoleBuilder.interface = {}
RoleBuilder.prototype = {}

RoleBuilder.prototype.__type = 'RoleBuilder'

--[=[
	Sets the name of the Role
]=]
function RoleBuilder.prototype.setName(self: RoleBuilder, name: string)
	self.name = name

	return self
end

--[=[
	Sets the color of the Role.
]=]
function RoleBuilder.prototype.setColor(self: RoleBuilder, color: number)
	self.color = color

	return self
end

--[=[
	Sets weather this role will split users in the roles hierarchy in the guild.
]=]
function RoleBuilder.prototype.setHoisted(self: RoleBuilder, hoisted: boolean)
	self.hoist = hoisted

	return self
end

--[=[
	Sets the Icon for this role, the imageData should be a base64 encoded, 128x128 jpg file.
]=]
function RoleBuilder.prototype.setIcon(self: RoleBuilder, imageData: string)
	self.icon = imageData

	return self
end

--[=[
	Sets the Emoji for this Role
]=]
function RoleBuilder.prototype.setUnicodeEmoji(self: RoleBuilder, unicodeEmoji: string)
	self.unicode_emoji = unicodeEmoji

	return self
end

--[=[
	Set the position of this Role, this will update the roles hierarchy in the guild.
]=]
function RoleBuilder.prototype.setPosition(self: RoleBuilder, position: number)
	self.position = position

	return self
end

--[=[
	Set if discord members can mention this Role.
]=]
function RoleBuilder.prototype.setMentionable(self: RoleBuilder, mentionable: boolean)
	self.mentionable = mentionable

	return self
end

--[=[
	Set the flags for the Guild
]=]
function RoleBuilder.prototype.setFlags(self: RoleBuilder, flags: number)
	self.flags = flags

	return self
end

--[=[
	Converts the role to a JSON object that can be sent to the Discord API.
]=]
function RoleBuilder.prototype.toJSON(self: RoleBuilder): PermissionsApi.APIRole
	return {
		name = self.name,
		color = self.color,
		hoist = self.hoist,
		icon = self.icon,
		unicode_emoji = self.unicode_emoji,
		position = self.position,
		permissions = self.permissions:getValue(),
		mentionable = self.mentionable,
		flags = self.flags,
	} 
end

--[=[
	Creates a new instance of RoleBuilder.
]=]
function RoleBuilder.interface.new(opt: PermissionsApi.APIRole?): RoleBuilder
    local actualOpt = opt or {}

    if (actualOpt :: PermissionsApi.APIRole).permissions then
        (actualOpt :: PermissionsApi.APIRole).permissions = PermissionsBitField.from((actualOpt :: PermissionsApi.APIRole).permissions) :: any
    end

    return (class(actualOpt, RoleBuilder.prototype) :: any) :: RoleBuilder
end

export type RoleBuilderProperties = {
    name: string,
    color: number,
    hoist: boolean,
    icon: string?,
    unicode_emoji: string?,
    position: number,
    permissions: PermissionsBitField.PermissionsBitField,
    mentionable: boolean,
    flags: number
}

export type RoleBuilder = typeof(RoleBuilder.prototype) & RoleBuilderProperties

return RoleBuilder.interface