-- Shard
require("@deps/dotenv").config()

-- Standard Libraries
local process = require("@std/process")
local Task = require("@std/task")
local class = require("@std/class")

-- Dependencies
local Table = require("@deps/table")
local LuauPolyfill = require("@deps/polyfill")
local Console = require("@deps/console")
local Future = require("@deps/future")
local ConsoleConstants = require("@deps/console/constants")

-- Utilities
local TypedCollection = require("@discordluau/utils/typedCollection")

-- Internal Utilities
local IntentsBitField = require("../utils/intentsBitField")
local Options = require("../utils/options")

local DiscordShard = require("../sharding/shard")

-- Errors
local Error = require("../errors/error")
local ErrorCodes = require("../errors/errorCodes")

-- Managers
local ActionsManager = require("@discordluau/discord.luau/client/actionsManager")
local EndpointCacheManager = require("@discordluau/discord.luau/client/endpointCacheManager")
local ShardingManager = require("@discordluau/discord.luau/sharding/shardingManager")
local WebsocketManager = require("@discordluau/discord.luau/client/websocketManager")

-- Structures
local Presence = require("../structures/presence")
local ClientUser = require("../structures/clientUser")
local ApplicationCommand = require("../structures/applicationCommand")
local User = require("../structures/user")
local Guild = require("../structures/guild")
local Message = require("../structures/message")
local Emoji = require("../structures/emoji")
local Channel = require("../structures/channel")
local GuildOnboardingPromptOption = require("../structures/guildOnboardingPromptOption")

-- API
local GlobalApi = require("@discordluau/api/global")
local RestApi = require("@discordluau/api/rest")

-- REST
local REST = require("@discordluau/rest")

-- Enumerations
local Routes = RestApi.Routes
local Array = LuauPolyfill.Array
local String = LuauPolyfill.String

local DiscordLuauError = Error.new("Client")

type DiscordEvent = GlobalApi.DiscordEvent

--[=[
	@class Client

	The base class that implements the various properties, methods and events that developers can use to interact with the Discord API.
]=]
local Client = {}

Client.prototype = {}
Client.interface = {}

Client.prototype.__type = "Client"

function Client.prototype._fetchGateway(self: Client): Future.Future<ClientGatewayResult>
	return Future.try(function()
		self.rest:setEndpointCache(Routes.gatewayBot, EndpointCacheManager.new(10))

		local data= self.rest:get(Routes.gatewayBot)

		local websocketVersion = self.rest.version

		return {
			WebsocketUrl = `{data.url}/?v={websocketVersion}` :: string,
			Concurrency = data.sessionStartLimit.maxConcurrency :: number,
			ShardCount = data.shards :: number
		}
	end)
end

function Client.prototype._connect(self: Client, data: ClientGatewayResult)
	return Future.try(function()
		self.websocketUrl = data.WebsocketUrl

		self.shards:spawn()
		self.shardCount = self.shards.shards.size or data.ShardCount

		self.ws:reload()
	end)
end

function Client.prototype.on(self: Client, targetEventName: DiscordEvent, eventCallback: (...any) -> ())
	(self.actions :: any)[targetEventName].on(function(...)
		eventCallback(...)
	end)
end

function Client.prototype.setVerbose(self: Client, verbose: boolean)
	Console.setGlobalLogLevel(verbose and ConsoleConstants.LogLevel.debug or ConsoleConstants.LogLevel.warn)
end

function Client.prototype._censoredToken(self: Client): string?
	if not self.token then
		return nil
	end

	local arrString = String.split(self.token, '.')
	local mappedString = Array.map(arrString, function(val: string, i: number)
		if i > 1 then
			local changedStr = string.gsub(val, '.', '*')
			return changedStr
		end

		return val
	end)

	return Array.join(mappedString, '.')
end

function Client.prototype.login(self: Client, token: string?)
	local tok = token or self.token

	if not tok or typeof(tok) ~= "string" then
		return self.error:log(ErrorCodes.TokenInvalid)	
	end

	self.rest:setToken(tok)

	self.reporter:debug(`Provided token: {self:_censoredToken()}`)
	
	local gatewayResult = self:_fetchGateway():await()

	self.token = token
	self.ws = WebsocketManager.new(self)

	self.shards = ShardingManager.new(self, { token = tok, totalShards = 'auto', concurrency = gatewayResult.Concurrency })

	self.ws:reload()

	self.reporter:debug(`Connecting to discord Websocket..`)

	local res = Future.try(function()
		self:_connect(gatewayResult):await()

		self.reporter:debug(`Connected to the discord websocket!`)
	end)

	res:await()

	return token
end

function Client.prototype._validateOptions(self: Client)
	local options = self.options
	if options.intents == nil or #options.intents == 0 then
		DiscordLuauError:log(ErrorCodes.ClientMissingIntents)
	else
		options.intents = IntentsBitField.parse(options.intents)
	end
end

function Client.prototype.constructor(self: Client)
    self:_validateOptions()

	self.actions = ActionsManager.new(self)

	self.cache = {
		emojis = TypedCollection.new(Emoji, self) :: any,
		onboardingPromptOption = TypedCollection.new(GuildOnboardingPromptOption, self) :: any
	}
	self.channels = TypedCollection.new(Channel, self) :: any
	self.guilds = TypedCollection.new(Guild, self) :: any
	self.users = TypedCollection.new(User, self) :: any

	if not self.token and process.env['DISCORD_TOKEN'] then
		self.token = process.env['DISCORD_TOKEN']
	end
end

function Client.interface.new(ClientOptions: ClientOptions): Client
	local options = Table.Reconcile(ClientOptions, Options.createDefault()) :: any
	local self = (class({
		options = options,
		token = nil,
		reporter = Console.new("Client"),
		websocketUrl = "",
		shardCount = 0,
		maxConcurrency = 0,
		rest = REST.REST.new(),
		ws = nil,
		presence = Presence.new(),
		error = Error.new('Client'),
	}, Client.prototype) :: any) :: Client

	self:constructor()

	return self
end

Console.setGlobalLogLevel(ConsoleConstants.LogLevel.warn)

export type Client = typeof(Client.prototype) & {
	actions: ActionsManager.ActionsManager,
	rest: REST.REST,
	options: ClientOptions,
	token: string?,

	websocketUrl: string,
	shardCount: number,
	maxConcurrency: number,

	reporter: Console.Console,

	shards: ShardingManager.ShardingManager,

	ws: WebsocketManager.WebSocketManager,

	user: ClientUser.ClientUser,

	error: Error.Error,

	application: ApplicationCommand.ApplicationCommand,

	cache: {
		emojis: TypedCollection.TypedCollection<string, Emoji.Emoji>,
		onboardingPromptOption: TypedCollection.TypedCollection<string, GuildOnboardingPromptOption.GuildOnboardingPromptOption>
	},

	channels: TypedCollection.TypedCollection<string, Channel.Channel>,
	guilds: TypedCollection.TypedCollection<string, Guild.Guild>,
	users: TypedCollection.TypedCollection<string, User.User>,

	presence: Presence.Presence
}

export type ClientOptions = {
	intents: { number }?,
	jsonTransformer: ((...any) -> any)?,
}

export type ClientGatewayResult = {
	WebsocketUrl: string,
	Concurrency: number,
	ShardCount: number
}

return Client.interface