-- Standard Libraries 
local Process = require("@std/process")
local Task = require("@std/task")
local class = require("@std/class")

-- Modules
local Table = require("@deps/table")
local Future = require("@deps/future")
local Console = require("@deps/console")
local Event = require("@deps/event")

-- Utilities
local Collection = require("@discordluau/utils/collection")

-- Internal Utilities
local Util = require("@discordluau/discord.luau/utils/utils")

-- Websocket
local WebSocket = require("@discordluau/ws/websocket")

-- Structures
local ClientUser = require("../structures/clientUser")
local DiscordApplication = require("../structures/applicationCommand")
local DiscordUser = require("../structures/user")
local DiscordMessage = require("../structures/message")
local DiscordChannel = require("../structures/channel")
local DiscordGuild = require("../structures/guild")
local DiscordInteraction = require("../structures/interaction")
local ChatInputCommandInteraction = require("../structures/chatInputCommandInteraction")

-- API
local InteractionApi = require("@discordluau/api/payloads/interaction")
local RESTApi = require("@discordluau/api/rest")

local WebsocketAPI = RESTApi.Websocket

local InteractionType = InteractionApi.InteractionType
local ApplicationCommandType = InteractionApi.ApplicationCommandType

local WebsocketOperationCodes = WebsocketAPI.WebsocketOperationCodes
local WebsocketOperationKeys = WebsocketAPI.WebsocketOperationKeys
local WebsocketCloseCodes = WebsocketAPI.WebsocketCloseCodes
local WebsocketEvents = WebsocketAPI.WebsocketEvents

-- Shard Skeleton
local Shard = require("shard")

local fetchRecommendedShardCount = Util.fetchRecommendedShardCount

local LIBRARY_IDENTIFIER = "DiscordLuau"

--[=[
	@class Shard

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local ShardingManager = {}

ShardingManager.interface = {}
ShardingManager.prototype = {}

ShardingManager.prototype.__type = "ShardingManager"

local CONCURRENT_IDENTIFY_YIELD = 5

function ShardingManager.prototype.createShard(self: ShardingManager, id: number)
    local shard = Shard.new(self._client, id - 1)
    self.shards:set(id, shard)
end

function ShardingManager.prototype.connectShard(self: ShardingManager, id: number)
    local shard =  self.shards:get(id)
    if shard then
        shard:connect(self._client.websocketUrl):await()
    end
end

function ShardingManager.prototype.get(self: ShardingManager, id: number): Shard.Shard?
    return self.shards:get(id) or nil
end

function ShardingManager.prototype.spawn(self: ShardingManager, opt: ShardingManagerSpawnOptions?)
    local optional = opt or {}
    local option = Table.Reconcile(optional, { concurrency = self.concurrency, amount = self.totalShards })
    local totalShards = option.amount
    local maxConcurrency = option.concurrency
    local amount: number
    if totalShards == 'auto' then
        amount = fetchRecommendedShardCount(self.token):await() :: number
    else
        amount = totalShards :: number
    end

    if self.totalShards == 'auto' or self.totalShards ~= amount then
        self.totalShards = amount
    end

    for shardId = 1, amount do
        self:createShard(shardId)
    end

    for index = 1, amount, maxConcurrency do
        for shardId = index, (index - 1) + maxConcurrency do
            self:connectShard(shardId)
        end

        if amount > maxConcurrency then
            Task.wait(CONCURRENT_IDENTIFY_YIELD)
        end
    end

    for shardId = 1, amount do
        local shard =  self.shards:get(shardId)
        if shard then
            shard:dispatch()
        end
    end

    return self.shards
end

function ShardingManager.interface.new(client: any, options: ShardingManagerOptions?): ShardingManager
    local opt = options or { } :: ShardingManagerOptions
    local fixedOpt = Table.Reconcile(opt, { totalShards = 'auto' :: any, token = "", concurrency = 0 })
	return class({
		_client = client,
        _connected = false,
        shards = Collection.new(),
        totalShards = fixedOpt.totalShards,
        token = fixedOpt.token,
        concurrency = fixedOpt.concurrency
	}, ShardingManager.prototype) :: ShardingManager
end

export type ShardingManager = typeof(ShardingManager.prototype) & {
    _client: any,
    _connected: boolean,
    shards: Collection.Collection<number, Shard.Shard>,
    totalShards: (number | 'auto'),
    token: string,
    concurrency: number,
}

export type ShardingManagerOptions = {
    token: string,
    totalShards: (number | 'auto')?,
    concurrency: number,
}

export type ShardingManagerSpawnOptions = {
    amount: (number | 'auto')?,
    concurrency: number?
}

return ShardingManager.interface