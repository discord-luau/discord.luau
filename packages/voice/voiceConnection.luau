--!strict

-- Standard Libraries
local class = require("@std/class")
local task = require("@std/task")

-- Dependencies
local Future = require("@deps/future")
local Console = require("@deps/console")
local Event = require("@deps/event")

-- Websocket
local DiscordWebsocket = require("@discordluau/ws/websocket")

-- Networking UDP
local VoiceUDP = require("networking/voiceUDP")

-- API
local RESTApi = require("@discordluau/api/rest")
local VoiceAPI = RESTApi.Voice
local WebsocketAPI = RESTApi.Websocket

local VoiceWebsocketOperationCodes = VoiceAPI.VoiceWebsocketOperationCodes
local VoiceWebsocketCloseCodes = VoiceAPI.VoiceWebsocketCloseCode
local WebsocketOperationCodes = WebsocketAPI.WebsocketOperationCodes
local WebsocketOperationKeys = WebsocketAPI.WebsocketOperationKeys
local WebsocketEvents = WebsocketAPI.WebsocketEvents

local BASE_VOICE_CONNECTION_PORT = 1050

--[=[
	@class VoiceConnection

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local VoiceConnection = {}

VoiceConnection.Internal = {}
VoiceConnection.interface = {}
VoiceConnection.prototype = {}

VoiceConnection.prototype.__type = "VoiceConnection"

VoiceConnection.Internal.publicAddress = nil
VoiceConnection.Internal.publicPort = nil

VoiceConnection.Internal.activeConnections = 0

function VoiceConnection.prototype.observeWebsocketErrors(self: VoiceConnection)
	self.voiceWebsocket.onSocketDead.on(function(closeCode)
		if closeCode == VoiceWebsocketCloseCodes.UnknownError then
			self:reconnect()
		elseif closeCode == VoiceWebsocketCloseCodes.UnknownOperation then
			self:reconnect()
		elseif closeCode == VoiceWebsocketCloseCodes.DecodeError then
			self:reconnect()
		elseif closeCode == VoiceWebsocketCloseCodes.NotAuthenticated then
			self.reporter:error(
				`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`
			)
		elseif closeCode == VoiceWebsocketCloseCodes.AuthenticationFailed then
			self.reporter:warn(
				`Failed to authenticate with the Discord Voice Gateway, is your token correct?`
			)
		elseif closeCode == VoiceWebsocketCloseCodes.AlreadyAuthenticated then
			self:reconnect()
		elseif closeCode == VoiceWebsocketCloseCodes.SessionTimedOut then
			self:reconnect()
		elseif closeCode == VoiceWebsocketCloseCodes.ServerNotFound then
			self.reporter:error(
				`Voice Websocket unable to find server; '{self.guildId}'`
			)
		elseif closeCode == VoiceWebsocketCloseCodes.UnknownProtocol then
			self.reporter:error(
				`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`
			)
		elseif closeCode == VoiceWebsocketCloseCodes.Disconnected then
			self.reporter:debug(
				`Disconnected from Voice websocket`
			)
		elseif closeCode == VoiceWebsocketCloseCodes.VoiceServerCrashed then
			self:reconnect()
		elseif closeCode == VoiceWebsocketCloseCodes.UnknownEncryptionMode then
			self.reporter:error(
				`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`
			)
		end
	end)
end

function VoiceConnection.prototype.observeWebsocketOperations(self: VoiceConnection)
	self.voiceWebsocket.onOperationRecv.on(function(operationCode, operationData)
		if operationCode == VoiceWebsocketOperationCodes.Hello then
			task.wait(math.random())

			self.heartbeatInterval = operationData.heartbeatInterval
			self:heartbeat(true):after(function()
				self:heartbeatIn(self.heartbeatInterval)
			end)
		elseif operationCode == VoiceWebsocketOperationCodes.HeartbeatACK then
			self.heartbeatAck = true
			self.heartbeatPing = os.clock() - self.heartbeatClockTime :: number

			if operationData ~= self.heartbeatNonce then
				self.reporter:warn(`HeartbeatACK - nonce recieved was incorrect`)
			end

			self.reporter:debug(`HeartbeatACK - Ping: {self.heartbeatPing}`)
		elseif operationCode == VoiceWebsocketOperationCodes.Ready then
			VoiceConnection.Internal.activeConnections += 1

			local thread = coroutine.running()

			self.voiceUDP = (
				VoiceUDP.new(
				`0.0.0.0:{BASE_VOICE_CONNECTION_PORT + VoiceConnection.Internal.activeConnections}`
				) :: unknown
			) :: VoiceUDP.VoiceUDP
			
			self.voiceUDP.onMessageRecv.once(function(packetData: string)
				local responseData = { string.unpack(">I2I2I4c64I2", packetData) }

				coroutine.resume(thread, responseData[4])
			end)
			
			self.voiceUDP:connect(`{operationData.ip}:{operationData.port}`):await()
			self.voiceUDP:send(
				string.pack(`>I2I2I4c64I2`, 1, 70, operationData.ssrc, operationData.ip, operationData.port)
			)

			local publicIp = coroutine.yield()

			self.voiceWebsocket:send({
				[WebsocketOperationKeys.OperationCode] = VoiceWebsocketOperationCodes.SelectProtocol,
				[WebsocketOperationKeys.Data] = {
					protocol = "udp",
					data = {
						address = publicIp,
						port = BASE_VOICE_CONNECTION_PORT + VoiceConnection.Internal.activeConnections,
						mode = "xsalsa20_poly1305"
					}
				}
			}):await()
		elseif operationCode == VoiceWebsocketOperationCodes.SessionDescription then
			self.encryptionKey = buffer.create(64)
			self.mediaSessionId = operationData.mediaSessionId

			for index = 1, 32 do
				buffer.writei16(self.encryptionKey, index, operationData.secretKey[tostring(index)])
			end
		end
	end)
end

function VoiceConnection.prototype.heartbeat(self: VoiceConnection, ignoreHeartbeatAck: boolean?)
	return Future.try(function()
		if not ignoreHeartbeatAck then
			if not self.heartbeatAck then
				self.reporter:warn(`Discord Websocket state has become zombified, attempting to reconnect!`)

				self:reconnect():await()
			end

			self.heartbeatAck = nil
		end

		self.heartbeatClockTime = os.clock()
		self.heartbeatNonce = math.random(1_000_000_000)

		self.voiceWebsocket:send({
			[WebsocketOperationKeys.OperationCode] = VoiceWebsocketOperationCodes.Heartbeat,
			[WebsocketOperationKeys.Data] = self.heartbeatNonce,
		}):await()
	end)
end

function VoiceConnection.prototype.heartbeatIn(self: VoiceConnection, milliseconds: number)
	if self.heartbeatTask then
		task.cancel(self.heartbeatTask)
	end

	self.heartbeatTask = task.delay(milliseconds / 1000, function()
		self.heartbeatTask = nil

		self:heartbeat():await()
		self:heartbeatIn(milliseconds)
	end)
end

function VoiceConnection.prototype.identify(self: VoiceConnection)
	return Future.try(function()
		
	end)
end

function VoiceConnection.prototype.connect(self: VoiceConnection, guildId: string, channelId: string)
	return Future.try(function()
		local guildObject = self.client.guilds:get(guildId)
		local shard = self.client.shards.shards:get(guildObject.shardId)
		local websocket: DiscordWebsocket.WebSocket = shard.discordWebsocket
		local connection

		connection = shard.onEvent.on(function(eventName, data: {[any]: any})
			if eventName == WebsocketEvents.VoiceServerUpdate then
				if data.guildId == guildId then
					self.voiceServerUpdate = data
				end
			elseif eventName == WebsocketEvents.VoiceStateUpdate then
				if data.userId == self.client.user.id then
					self.voiceStateUpdate = data
				end
			end
		end)

		websocket:send(
			{
				[WebsocketOperationKeys.OperationCode] = WebsocketOperationCodes.VoiceStateUpdate,
				[WebsocketOperationKeys.Data] = {
					guild_id = guildId,
					channel_id = channelId,
					self_mute = false,
					self_deaf = false,
				},
			}
		):await()

		repeat
			task.wait(0.5)
		until self.voiceServerUpdate and self.voiceStateUpdate

		connection.disconnect()

		self.guildId = guildId
		self.channelId = channelId

		self.voiceWebsocket:connect(`wss://{self.voiceServerUpdate.endpoint}/?v=4`):await()
		self.voiceWebsocket:send({
			[WebsocketOperationKeys.OperationCode] = VoiceWebsocketOperationCodes.Identify,
			[WebsocketOperationKeys.Data] = {
				server_id = guildId,
				user_id = self.client.user.id,
				session_id = self.voiceStateUpdate.sessionId,
				token = self.voiceServerUpdate.token
			}
		}):await()

		return true
	end)
end

function VoiceConnection.prototype.resume(self: VoiceConnection)
	return Future.try(function()
		self.voiceWebsocket:connect(`wss://{self.voiceServerUpdate.endpoint}/?v=4`):await()
		self.voiceWebsocket:send({
			[WebsocketOperationKeys.OperationCode] = VoiceWebsocketOperationCodes.Resume,
			[WebsocketOperationKeys.Data] = {
				server_id = self.guildId,
				session_id = self.voiceStateUpdate.sessionId,
				token = self.voiceServerUpdate.token
			}
		}):await()

		return true
	end)
end

function VoiceConnection.prototype.reconnect(self: VoiceConnection)
	if self.heartbeatTask then
		task.cancel(self.heartbeatTask)
	end

	return Future.try(function()
		self.voiceWebsocket:disconnect(tostring(1005)):await()

		task.wait(math.random())
	
		self:resume():await()
	end)
end

function VoiceConnection.prototype.disconnect(self: VoiceConnection)
	return Future.try(function()
		if self.heartbeatTask then
			task.cancel(self.heartbeatTask)
		end

		local guildObject = self.client.guilds:get(self.guildId)
		local shard = self.client.shards.shards:get(guildObject.shardId)
		local websocket: DiscordWebsocket.WebSocket = shard.discordWebsocket

		websocket:send(
			{
				[WebsocketOperationKeys.OperationCode] = WebsocketOperationCodes.VoiceStateUpdate,
				[WebsocketOperationKeys.Data] = {
					guild_id = self.guildId
				},
			}
		):await()

		self.voiceWebsocket:disconnect(tostring(1000)):await()

		VoiceConnection.Internal.activeConnections -= 1
	end)
end

function VoiceConnection.interface.new(client: any, id: string): VoiceConnection
    local self = (class({
        voiceWebsocket = DiscordWebsocket.new(),
		client = client,

		reporter = Console.new(`VoiceConnection {id}`),

		heartbeatTask = nil,
		resumeSessionId = nil,
		heartbeatInterval = nil,

		onEvent = Event.new()
    }, VoiceConnection.prototype) :: any) :: VoiceConnection

	self:observeWebsocketOperations()

	return self
end

export type VoiceConnection = typeof(VoiceConnection.prototype) & {
	voiceWebsocket: DiscordWebsocket.WebSocket,
	voiceUDP: VoiceUDP.VoiceUDP,
	client: any,

	reporter: Console.Console,

	heartbeatTask: thread?,
	resumeSessionId: string,
	heartbeatInterval: number,

	heartbeatAck: boolean?,
	heartbeatPing: number?,
	heartbeatNonce: number?,
	heartbeatClockTime: number?,

	encryptionKey: buffer,
	mediaSessionId: string,

	channelId: string,
	guildId: string,

	voiceServerUpdate: {
		endpoint: string,
		token: string,
		guildId: string,
	},

	voiceStateUpdate: {
		sessionId: string,
	},

	onEvent: unknown,
}

return VoiceConnection.interface