--!strict

-- Standard Libraries
local class = require("@std/class")

-- REST
local REST = require("@discordluau/rest")

local calculateUserDefaultAvatarIndex = REST.calculateUserDefaultAvatarIndex

local User = {}

User.prototype = {}
User.interface = {}

User.prototype.__type = "User"

function User.prototype.avatarURL(self: User, options: REST.ImageURLOptions?): string?
	return self.avatar and self.client.rest.cdn:avatar(self.id, self.avatar, options) or nil
end

function User.prototype.displayAvatarURL(self: User, options: REST.ImageURLOptions?)
	return self:avatarURL(options) or self.defaultAvatarUrl
end

function User.interface.new(client: any, partialUserData: {
	username: string?,
	flags: number?,
	mfaEnabled: boolean?,
	avatar: string?,
	id: string,
	bot: boolean?,
	verified: boolean?,
	discriminator: string?
}): User
	local self = client.users:fetch(partialUserData.id, function()
		return class({
			id = partialUserData.id,
	
			client = client
		}, User.prototype)
	end)

	if partialUserData then
		for index, value in partialUserData do
			self[index] = value
		end
	end

	local index = self.discriminator == '0' and calculateUserDefaultAvatarIndex(self.id) or tonumber(self.discriminator) :: number % 5
	self.defaultAvatarUrl = self.client.rest.cdn:defaultAvatar(index)
	self.tag = self.discriminator == '0' and self.username or `{self.username}#{self.discriminator}`

	return self
end

export type User = typeof(User.prototype) & {
	client: any,
	username: string?,
	flags: number?,
	mfaEnabled: boolean?,
	avatar: string?,
	id: string,
	bot: boolean?,
	verified: boolean?,
	discriminator: string?,
	defaultAvatarUrl: string,
	tag: string,
}

return User.interface