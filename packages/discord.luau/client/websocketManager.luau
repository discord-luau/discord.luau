--!strict

-- Standard Libraries
local class = require('@std/class')

-- Sharding
local DiscordShard = require("../sharding/shard")

local WebSocketManager = {}

WebSocketManager.interface = {}
WebSocketManager.prototype = {}

WebSocketManager.prototype.__type = "WebSocketManager"

function WebSocketManager.prototype.ping(self: WebSocketManager)
    local total = 0
    for _, shardObject in self.shards do
        total += (shardObject.heartbeatPing or 0)
    end
    return total / #self.shards
end

function WebSocketManager.prototype.reload(self: WebSocketManager)
    self.client.shards.shards:forEach(function(shard)
        if not table.find(self.shards, shard) then
            table.insert(self.shards, shard)
        end
    end)
end

function WebSocketManager.interface.new(client: any): WebSocketManager
	return class({
        client = client,
        shards = {}
	}, WebSocketManager.prototype) :: WebSocketManager
end

export type WebSocketManager = typeof(WebSocketManager.prototype) & {
    shards: { DiscordShard.Shard },
    client: any ,
}

return WebSocketManager.interface