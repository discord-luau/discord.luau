-- Standard Libraries
local Date = require("@std/datetime")
local class = require("@std/class")





local MemberBuilder = {}

MemberBuilder.interface = {}
MemberBuilder.prototype = {}

MemberBuilder.prototype.__type = "MemberBuilder"

--[=[
	Sets the nickname of a discord member
]=]
function MemberBuilder.prototype.setNickname(self: MemberBuilder, nickname: string): MemberBuilder
	self.nick = nickname

	return self
end

--[=[
	Adds a role to a member
]=]
function MemberBuilder.prototype.addRole(self: MemberBuilder, roleId: string): MemberBuilder
	table.insert(self.roles, roleId)

	return self
end

--[=[
	Sets the muted state for this member
]=]
function MemberBuilder.prototype.setMuted(self: MemberBuilder, muted: boolean): MemberBuilder
	self.mute = muted

	return self
end

--[=[
	Sets the deafened state for this member
]=]
function MemberBuilder.prototype.setDeafened(self: MemberBuilder, deafened: boolean): MemberBuilder
	self.deaf = deafened

	return self
end

--[=[
	Allows you to specify the voice channel to move the member too.
]=]
function MemberBuilder.prototype.setActiveVoiceChannel(self: MemberBuilder, voiceChannelId: string): MemberBuilder
	self.channelId = voiceChannelId

	return self
end

--[=[
	Allows you to timeout a members communication.
]=]
function MemberBuilder.prototype.setTimeoutFor(self: MemberBuilder, epoch: number): MemberBuilder
	self.communicationDisabledUntil = epoch

	return self
end

--[=[
	Sets the bitflags for this Member
]=]
function MemberBuilder.prototype.setFlags(self: MemberBuilder, flags: number): MemberBuilder
	self.flags = flags

	return self
end

--[=[
	Converts the member to a JSON object that can be sent to the Discord API.
]=]
function MemberBuilder.prototype.toJSON(self: MemberBuilder)
	local communicationDisabledUntil

	if self.communicationDisabledUntil then
		communicationDisabledUntil = Date.fromUnixTimestamp(os.time() + self.communicationDisabledUntil):toIsoDate()
	end

	return {
		nick = self.nick,
		roles = self.roles,
		mute = self.mute,
		deaf = self.deaf,
		channel_id = self.channelId,
		communication_disabled_until = communicationDisabledUntil,
		flags = self.flags,
	} 
end

--[=[
	Creates a new instance of MemberBuilder.d
]=]
function MemberBuilder.interface.new(): MemberBuilder
	return (class({
		roles = {},
	}, MemberBuilder.prototype) :: unknown) :: MemberBuilder
end

export type MemberBuilderProperties = {
    nick: string,
	roles: { string },
	mute: boolean,
	deaf: boolean,
	channelId: string,
	communicationDisabledUntil: number,
	flags: number,
}

export type MemberBuilder = typeof(MemberBuilder.prototype) & MemberBuilderProperties

return MemberBuilder.interface