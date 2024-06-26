--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')

-- Structures
local Activity = require('activity')
local Presence = require('presence')
local User = require('user')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local WebsocketAPI = RESTApi.Websocket
local WebsocketOperationCodes = WebsocketAPI.WebsocketOperationCodes
local WebsocketOperationKeys = WebsocketAPI.WebsocketOperationKeys

--[=[
	@class ClientUser

]=]
local ClientUser = {}

ClientUser.prototype = {}
ClientUser.interface = {}

ClientUser.prototype.__type = 'ClientUser'

function ClientUser.prototype._set(self: ClientUser)
    return Future.try(function()
        for shardId = 1, self.client.shardCount do
            local shard = self.client.shards.shards:get(shardId)
            if shard then
                shard.websocket
                    :send({
                        [WebsocketOperationKeys.OperationCode] = WebsocketOperationCodes.PresenseUpdate,
                        [WebsocketOperationKeys.Data] = self.client.presence:toJSON(),
                    })
                    :await()
            end
        end
    end)
end

function ClientUser.prototype.setAFK(self: ClientUser, afk: boolean?)
    return Future.try(function()
        if afk == nil then
            afk = true
        end

        self.client.presence:setAfk(afk)

        self:_set():await()
        return true
    end)
end

function ClientUser.prototype.setStatus(self: ClientUser, status: string)
    return Future.try(function()
        self.client.presence:setStatus(status)
        self:_set():await()
        return true
    end)
end

function ClientUser.prototype.setPresence(
    self: ClientUser,
    presence: Presence.PresenceOptions | Presence.Presence
): Future.Future<boolean>
    return Future.try(function()
        if (presence :: any).toJSON == nil then
            if (presence :: any).activities and #(presence :: any).activities > 0 then
                for _, activityData in (presence :: any).activities do
                    local activity = Activity.new()
                    activity = Activity.new()
                    activity:setActivityName(activityData.name)
                    activity:setActivityType(activityData.type)

                    if activityData.url then
                        activity:setStreamingURL(activityData.url)
                    end

                    self.client.presence:addActivity(activity)
                end
            end

            if (presence :: any).afk then
                self.client.presence:setAfK((presence :: any).afk)
            end

            if (presence :: any).status then
                self.client.presence:setStatus((presence :: any).status)
            end
        else
            self.client.presence = presence
        end

        self:_set():await()

        return true
    end)
end

function ClientUser.interface.new(
    client: any,
    partialClientUserData: {
        username: string?,
        flags: number?,
        mfaEnabled: boolean?,
        avatar: string?,
        id: string,
        bot: boolean?,
        verified: boolean?,
        discriminator: string?,
    }
): ClientUser
    return class({}, ClientUser.prototype):extend(User.new(client, partialClientUserData))
end

export type ClientUser = typeof(ClientUser.prototype) & User.User

return ClientUser.interface
