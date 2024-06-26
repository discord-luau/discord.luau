local enum = require("@std/enum")

local VoiceWebsocketCloseCode = enum('VoiceWebsocketCloseCode',{
	UnknownError = 4000,
	UnknownOperation = 4001,
	DecodeError = 4002,
	NotAuthenticated = 4003,
	AuthenticationFailed = 4004,
	AlreadyAuthenticated = 4005,
	SessionInvalid = 4006,
	SessionTimedOut = 4009,
	ServerNotFound = 4011,
	UnknownProtocol = 4012,
	Disconnected = 4014,
	VoiceServerCrashed = 4015,
	UnknownEncryptionMode = 4016,
})

-- https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes

local VoiceWebsocketOperationCodes = enum('VoiceWebsocketOperationCodes', {
	Identify = 0,
	SelectProtocol = 1,
	Ready = 2,
	Heartbeat = 3,
	SessionDescription = 4,
	Speaking = 5,
	HeartbeatACK = 6,
	Resume = 7,
	Hello = 8,
	Resumed = 9,
	ClientDisconnect = 13
})

return {
    VoiceWebsocketCloseCode = VoiceWebsocketCloseCode,
    VoiceWebsocketOperationCodes = VoiceWebsocketOperationCodes
}