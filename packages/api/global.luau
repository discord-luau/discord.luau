export type DiscordEvent = "Ready" | 
    "messageCreate" | 
    "messageUpdate" | 
    "messageDelete" | 
    "messageDeleteBulk" | 
    "channelCreate" | 
    "channelUpdate" |
    "channelDelete" |
    "userUpdate" |
    "channelPinsUpdate" |
    "guildCreate" |
    "guildUpdate" |
    "guildDelete" |
    "guildBanAdd" |
    "guildBanRemove" |
    "guildMemberAdd" |
    "guildMemberRemove" |
    "guildMemberUpdate" |
    "interactionCreate"

export type CachedType = number

local CachedEnum = {
    User = 1,
	Guild = 2,
	Application = 3,
	Channel = 4,
	TextChannel = 5,
	VoiceChannel = 6,
	Message = 7,
	Member = 8,
	Role = 9,
	Invite = 10,
	AutoModeration = 11,
    ThreadMember = 12,
    GuildRole = 13
}

export type Snowflake = string | number

export type Permissions = string

return {
    CachedType = CachedEnum
}