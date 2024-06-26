local enum = require("@std/enum")

local WebsocketCloseCodes = enum('WebsocketCloseCodes', {
	UnknownError = 4000,
	UnknownOperation = 4001,
	DecodeError = 4002,
	NotAuthenticated = 4003,
	AuthenticationFailed = 4004,
	AlreadyAuthenticated = 4005,
	InvalidSequence = 4007,
	RateLimited = 4008,
	SessionTimedOut = 4009,
	InvalidShard = 4010,
	ShardingRequired = 4011,
	InvalidAPIVersion = 4012,
	InvalidIntents = 4013,
	DisallowedIntents = 4014,

	VoiceServerCrashed = 4015,
})

local WebsocketEvents = enum('WebsocketEvents', {
	Ready = "READY",

	MessageCreate = "MESSAGE_CREATE",
	MessageUpdate = "MESSAGE_UPDATE",
	MessageDelete = "MESSAGE_DELETE",
	MessageBulkDelete = "MESSAGE_DELETE_BULK", --

	ChannelCreate = "CHANNEL_CREATE",
	ChannelUpdate = "CHANNEL_UPDATE",
	ChannelDelete = "CHANNEL_DELETE",

	UserUpdate = "USER_UPDATE",

	ChannelPinsUpdate = "CHANNEL_PINS_UPDATE",

	GuildCreate = "GUILD_CREATE",
	GuildUpdate = "GUILD_UPDATE",
	GuildDelete = "GUILD_DELETE",

	GuildBanAdd = "GUILD_BAN_ADDED",
	GuildBanRemove = "GUILD_BAN_REMOVE",

	GuildMemberAdd = "GUILD_MEMBER_JOINED",
	GuildMemberRemove = "GUILD_MEMBER_REMOVE",
	GuildMemberUpdate = "GUILD_MEMBER_UPDATE",

	InteractionCreate = "INTERACTION_CREATE",

	VoiceServerUpdate = "VOICE_SERVER_UPDATE",
	VoiceStateUpdate = "VOICE_STATE_UPDATE"
})

-- https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes

local WebsocketOperationCodes = enum('WebsocketOperationCodes', {
	["Dispatch"] = 0,
	["Heartbeat"] = 1,
	["Identify"] = 2,
	["PresenseUpdate"] = 3,
	["VoiceStateUpdate"] = 4,
	["Resume"] = 6,
	["Reconnect"] = 7,
	["RequestGuildMembers"] = 8,
	["InvalidSession"] = 9,
	["Hello"] = 10,
	["HeartbeatACK"] = 11,
})

-- https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes

local WebsocketOperationKeys = enum('WebsocketOperationKeys', {
	OperationCode = "op",
	Data = "d",
	Sequence = "s",
	EventName = "t",
})

return {
    WebsocketCloseCodes = WebsocketCloseCodes,
    WebsocketEvents = WebsocketEvents,
    WebsocketOperationCodes = WebsocketOperationCodes,
    WebsocketOperationKeys = WebsocketOperationKeys
}