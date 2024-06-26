-- Standard Libraries 
local Process = require("@std/process")
local Task = require("@std/task")
local class = require("@std/class")

-- Modules
local Table = require("@deps/table")
local Future = require("@deps/future")
local Console = require("@deps/console")
local Event = require("@deps/event")

-- Websocket
local WebSocket = require("@discordluau/ws/websocket")

-- Structures
local ClientUser = require("../structures/clientUser")
local ApplicationCommand = require("../structures/applicationCommand")
local User = require("../structures/user")
local Message = require("../structures/message")
local Channel = require("../structures/channel")
local Guild = require("../structures/guild")
local Interaction = require("../structures/interaction")
local ChatInputCommandInteraction = require("../structures/chatInputCommandInteraction")

-- API
local InteractionApi = require("@discordluau/api/payloads/interaction")
local RESTApi = require("@discordluau/api/rest")

-- Enumerations
local WebsocketAPI = RESTApi.Websocket

local InteractionType = InteractionApi.InteractionType
local ApplicationCommandType = InteractionApi.ApplicationCommandType

local WebsocketOperationCodes = WebsocketAPI.WebsocketOperationCodes
local WebsocketOperationKeys = WebsocketAPI.WebsocketOperationKeys
local WebsocketCloseCodes = WebsocketAPI.WebsocketCloseCodes
local WebsocketEvents = WebsocketAPI.WebsocketEvents

local LIBRARY_IDENTIFIER = "DiscordLuau"

local Shard = {}

Shard.interface = {}
Shard.prototype = {}

Shard.prototype.__type = "Shard"

function Shard.prototype.observeWebsocketErrors(self: Shard)
	table.insert(self.activeConnections, self.websocket.onSocketDead.on(function(closeCode)
		if closeCode == WebsocketCloseCodes.UnknownError then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.UnknownOperation then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.DecodeError then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.NotAuthenticated then
			self.reporter:error(`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`)
		elseif closeCode == WebsocketCloseCodes.AuthenticationFailed then
			self.reporter:warn(`Failed to authenticate with the Discord API, is your token correct?`)
		elseif closeCode == WebsocketCloseCodes.AlreadyAuthenticated then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.InvalidSequence then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.RateLimited then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.SessionTimedOut then
			self:reconnect()
		elseif closeCode == WebsocketCloseCodes.InvalidShard then
			self.reporter:error(`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`)
		elseif closeCode == WebsocketCloseCodes.InvalidAPIVersion then
			self.reporter:error(`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`)
		elseif closeCode == WebsocketCloseCodes.InvalidIntents then
			self.reporter:error(`Something has gone terribly wrong with Discord-Luau.. please create an issue! [{closeCode}]`)
		elseif closeCode == WebsocketCloseCodes.DisallowedIntents then
			self.reporter:warn(`Discord Bot intents are invalid, are you sure the bot has the chosen intents enabled?`)
		end
	end))
end

function Shard.prototype.observeWebsocketEvents(self: Shard)
	table.insert(self.activeConnections, self.onEvent.on(function(eventName, data)
		if eventName == WebsocketEvents.Ready then
			local websocketVersion = self.client.rest.version

			self.reporter:log(`Shard is active - id: "{data.sessionId}"`)

			self.resumeSessionId = data.sessionId
			self.resumeGatewayUrl = `{data.resumeGatewayUrl}/?v={websocketVersion}`
		end
	end))
end

function Shard.prototype.observeWebsocketOperations(self: Shard)
	table.insert(self.activeConnections, self.websocket.onOperationRecv.on(function(operationCode: any, operationData: any, eventName:  any, sequence: any)
		if operationCode == WebsocketOperationCodes.Dispatch then
			self.dispatchSequence = (sequence :: any) :: number 

			self.onEvent.emit(eventName, operationData)
		elseif operationCode == WebsocketOperationCodes.Hello then
			Task.wait(math.random())

			self.heartbeatInterval = operationData.heartbeatInterval
			self:hearbeat(true):after(function()
				self:heartbeatIn(math.random(self.heartbeatInterval / 2, self.heartbeatInterval))
			end)
		elseif operationCode == WebsocketOperationCodes.Heartbeat then
			self.reporter:log(`Discord Websocket requested heartbeat, sending heartbeat!`)

			self:hearbeat(true)
		elseif operationCode == WebsocketOperationCodes.HeartbeatACK then
			self.heartbeatAck = true
			self.heartbeatPing = os.clock() - self.heartbeatClockTime :: number

			self.reporter:debug(`HeartbeatACK - Ping: {self.heartbeatPing}`)

			if not self.identified then
				self.identified = true

				xpcall(function()
					self:identify():await()
				end, function(exception)
					self.reporter:warn(`:identify call failed: '{exception}'`)

					self.identified = nil
				end)
			end
		elseif operationCode == WebsocketOperationCodes.Reconnect then
			self.reporter:log(`Discord Websocket requested reconnect, attempting to reconnect!`)

			self:reconnect()
		elseif operationCode == WebsocketOperationCodes.InvalidSession then
			self.reporter:warn(`Discord Websocket session invalid!`)

			if operationData == true then
				self.reporter:log(`Attempting to reconnect from Invalid Session!`)
	
				self:reconnect()
			else
				self.reporter:warn(`Unrecoverable InvalidSession, attempting to destroy and recreate websocket.`)

				self.websocket:disconnect(tostring(1005)):await()

				Task.wait(5)

				self:initiateWebsocket()
				self:connect(self.websocketUrl)
			end
		end
	end))
end

function Shard.prototype.initiateWebsocket(self: Shard)
	self.websocket = WebSocket.new() 

	for _, connection in self.activeConnections do
		connection.disconnect()
	end

	self:observeWebsocketEvents()
	self:observeWebsocketErrors()
	self:observeWebsocketOperations()
end

function Shard.prototype.hearbeat(self: Shard, ignoreHeartbeatAck: boolean?)
	return Future.try(function()
		if not ignoreHeartbeatAck then
			if not self.heartbeatAck then
				self.reporter:warn(`Discord Websocket state has become zombified, attempting to reconnect!`)

				self:reconnect():await()
			end

			self.heartbeatAck = nil
		end

		self.heartbeatClockTime = os.clock()

		self.websocket:send({
			[WebsocketOperationKeys.OperationCode] = WebsocketOperationCodes.Heartbeat,
			[WebsocketOperationKeys.Data] = self.dispatchSequence or false,
		}):await()
	end)
end

function Shard.prototype.heartbeatIn(self: Shard, milliseconds: number)
	if self.heartbeatTask then
		Task.cancel(self.heartbeatTask)
	end

	self.heartbeatTask = Task.delay(milliseconds / 1000, function()
		self.heartbeatTask = nil

		self:hearbeat():await()
		self:heartbeatIn(milliseconds)
	end)
end

function Shard.prototype.identify(self: Shard)
	return Future.try(function()
		self.websocket:send({
			[WebsocketOperationKeys.OperationCode] = WebsocketOperationCodes.Identify,
			[WebsocketOperationKeys.Data] = {
				["token"] = self.client.token,
				["intents"] = self.client.options.intents.bitfield,
				["properties"] = {
					["os"] = Process.os,
					["browser"] = LIBRARY_IDENTIFIER,
					["device"] = LIBRARY_IDENTIFIER,
				},
				["compress"] = true,
				["large_threshold"] = 250,
				["shard"] = {
					self.shardId,
					self.client.shardCount
				},
			},
		}):await()
	end)
end

function Shard.prototype.connect(self: Shard, websocketUrl: string)
	self.websocketUrl = websocketUrl

	return self.websocket:connect(websocketUrl)
end

function Shard.prototype.dispatch(self: Shard)
	self.onEvent.on(function(eventName: string, data: any)
		if eventName == WebsocketEvents.Ready then
			self.client.user = ClientUser.new(self.client, data.user)
			self.client.application = ApplicationCommand.new(self.client :: any, data.application)

			self.client.actions.ready.emit()
		elseif eventName == WebsocketEvents.MessageCreate then
			local channel = self.client.actions.getChannel(data.channelId)
			local message: Message.Message

			if channel then
				local existing = channel.messages:get(data.id)
				if existing then
					message = existing
				else
					message = Message.new(self.client, data, channel)
					channel.messages:set(data.id, message)
				end
			else
				message = Message.new(self.client, data)
			end

			self.client.actions.messageCreate.emit(message)
		elseif eventName == WebsocketEvents.MessageUpdate then
			local channel = self.client.actions.getChannel(data.channelId)
			local message: Message.Message

			if channel then
				local existing = channel.messages:get(data.id)
				if existing then
					message = existing
				else
					message = Message.new(self.client, data, channel)
					channel.messages:set(data.id, message)
				end
			else
				message = Message.new(self.client, data)
			end

			self.client.actions.messageUpdate.emit(message)	
		elseif eventName == WebsocketEvents.MessageDelete then
			local channel = self.client.actions.getChannel(data.channelId)
			local message: Message.Message

			if channel then
				local existing = channel.messages:get(data.id)
				if existing then
					channel.messages:delete(data.id)
					message = existing
				else
					message = Message.new(self.client, data, channel)
				end
			else
				message = Message.new(self.client, data)
			end
			
			self.client.actions.messageDelete.emit(message)
		elseif eventName == WebsocketEvents.InteractionCreate then
			local discordInteraction
			if data.type == InteractionType.ApplicationCommand then
				if data.data.type == ApplicationCommandType.ChatInput then
					discordInteraction = ChatInputCommandInteraction.new(self.client, data)
				else
					discordInteraction = Interaction.new(self.client, data) :: any
				end
			else
				discordInteraction = Interaction.new(self.client, data) :: any
			end
			self.client.actions.interactionCreate.emit(discordInteraction)
		elseif eventName == WebsocketEvents.MessageBulkDelete then
			self.client.actions.messageBulkDelete.emit(data)
		elseif eventName == WebsocketEvents.ChannelCreate then
			local discordChannel = Channel.from(self.client, data)

			self.client.actions.channelCreate.emit(discordChannel)
		elseif eventName == WebsocketEvents.ChannelUpdate then
			local discordChannel = Channel.from(self.client, data)

			self.client.actions.channelUpdate.emit(discordChannel)
		elseif eventName == WebsocketEvents.ChannelDelete then
			local discordChannel = Channel.from(self.client, data)

			self.client.actions.channelDelete.emit(discordChannel)
		elseif eventName == WebsocketEvents.UserUpdate then
			self.client.user = ClientUser.new(self.client, data.user)
			self.client.actions.userUpdate.emit(self.client.user)
		elseif eventName == WebsocketEvents.ChannelPinsUpdate then

			self.client.actions.channelPinsUpdate.emit(data)
		elseif eventName == WebsocketEvents.GuildCreate then
			local discordGuild = Guild.new(self.client, data)

			self.client.actions.guildCreate.emit(discordGuild)
		elseif eventName == WebsocketEvents.GuildUpdate then
			local discordGuild = Guild.new(self.client, data)

			self.client.actions.guildUpdate.emit(discordGuild)
		elseif eventName == WebsocketEvents.GuildDelete then
			local discordGuild = Guild.new(self.client, data)

			self.client.actions.guildDelete.emit(discordGuild)
		elseif eventName == WebsocketEvents.GuildBanAdd then
			data.user = User.new(self.client, data.user)

			self.client.actions.guildBanAdd.emit(data)
		elseif eventName == WebsocketEvents.GuildBanRemove then
			data.user = User.new(self.client, data.user)

			self.client.actions.guildBanRemove.emit(data)
		elseif eventName == WebsocketEvents.GuildMemberAdd then
			data.user = User.new(self.client, data.user)

			self.client.actions.guildMemberAdd.emit(data)
		elseif eventName == WebsocketEvents.GuildMemberRemove then
			data.user = User.new(self.client, data.user)

			self.client.actions.guildMemberRemove.emit(data)
		elseif eventName == WebsocketEvents.GuildMemberUpdate then
			data.user = User.new(self.client, data.user)

			self.client.actions.guildMemberUpdate.emit(data)
		else
			self.reporter:debug(`Unknown Event: '{eventName}'`)
		end
	end)
end

function Shard.prototype.resume(self: Shard)
	return Future.try(function()
		local gatewayUrl = self.resumeGatewayUrl

		self.websocket:connect(gatewayUrl or self.websocketUrl):await()

		if gatewayUrl then
			self.websocket:send({
				[WebsocketOperationKeys.OperationCode] = WebsocketOperationCodes.Resume,
				[WebsocketOperationKeys.Data] = {
					token = self.client.token,
					session_id = self.resumeSessionId,
					seq = self.dispatchSequence
				},
			}):await()
		end
	end)
end

function Shard.prototype.reconnect(self: Shard)
	if self.heartbeatTask then
		Task.cancel(self.heartbeatTask)
	end

	return Future.try(function()
		self.websocket:disconnect(tostring(1005)):await()

		Task.wait(math.random())
	
		self:resume():await()
	end)
end

function Shard.interface.new(client: any, shardId: number): Shard
	local self = (class({
		client = client,
		websocket = nil,
		activeConnections = {},

		websocketUrl = "",

		reporter = Console.new(`Shard {shardId}`),

		heartbeatTask = nil,
		resumeSessionId = nil,
		dispatchSequence = nil,
		heartbeatInterval = nil,

		onEvent = Event.new(),

		shardId = shardId
	}, Shard.prototype) :: any) :: Shard

	self:initiateWebsocket()

	return self :: Shard
end

export type Shard = typeof(Shard.prototype) & {
	websocket: WebSocket.WebSocket,
	client: any,

	websocketUrl: string,

	reporter: Console.Console,

	heartbeatTask: thread?,
	resumeSessionId: string,
	dispatchSequence: number,
	heartbeatInterval: number,
	heartbeatClockTime: number,
	heartbeatPing: number,
	
	identified: boolean?,

	resumeGatewayUrl: string?,

	heartbeatAck: boolean?,

	activeConnections: { Event.Connection },

	onEvent: Event.Event<string, any>,
	
	shardId: number
}

return Shard.interface