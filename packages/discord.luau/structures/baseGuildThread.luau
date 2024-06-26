--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')
local Snowflake = require('@deps/sapphire/snowflake')

-- Structures
local BaseGuildTextChannel = require('baseGuildTextChannel')
local Emoji = require('emoji')
local GuildMember = require('guildMember')

-- API
local GlobalApi = require('@discordluau/api/global')
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes

local BaseGuildThread = {}

BaseGuildThread.prototype = {}
BaseGuildThread.interface = {}

BaseGuildThread.prototype.__type = 'BaseGuildThread'

type Future<T> = Future.Future<T>
type Snowflake = GlobalApi.Snowflake

function BaseGuildThread.prototype.join(self: BaseGuildThread): Future<any>
    return Future.try(function()
        return self.client.rest:put(Routes.threadMembers(self.id))
    end)
end

function BaseGuildThread.prototype.leave(self: BaseGuildThread): Future<any>
    return Future.try(function()
        return self.client.rest:delete(Routes.threadMembers(self.id))
    end)
end

function BaseGuildThread.prototype.addMember(self: BaseGuildThread, userId: Snowflake): Future<any>
    return Future.try(function()
        return self.client.rest:put(Routes.threadMembers(self.id, userId))
    end)
end

function BaseGuildThread.prototype.removeMember(
    self: BaseGuildThread,
    userId: Snowflake
): Future<any>
    return Future.try(function()
        return self.client.rest:delete(Routes.threadMembers(self.id, userId))
    end)
end

function BaseGuildThread.prototype.getMember(
    self: BaseGuildThread,
    userId: Snowflake
): Future<GuildMember.GuildMember>
    return Future.try(function()
        local memberObject = self.client.rest:get(Routes.threadMembers(self.id, userId))
        memberObject = GuildMember.new(self.client, memberObject.userId, self.guildId, memberObject)

        return memberObject
    end)
end

function BaseGuildThread.prototype.constructor(self: BaseGuildThread, channelData: ChannelData)
    for index, value in channelData do
        (self :: {})[index] = value
    end
end

function BaseGuildThread.interface.new(client: any, channelData: ChannelData): BaseGuildThread
    if channelData.defaultReactionEmoji then
        channelData.defaultReactionEmoji = Emoji.new(client, channelData.defaultReactionEmoji)
    end
    local self = (class({ client = client }, BaseGuildThread.prototype):extend(
        BaseGuildTextChannel.new(client, channelData)
    ) :: any) :: BaseGuildThread

    self:constructor(channelData)

    return self
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type BaseGuildThreadProperties = {
    ownerId: string,

    messageCount: number,
    memberCount: number,
    totalMessageSent: number?,

    threadMetadata: {
        archived: boolean,
        autoArchiveDuration: number,
        archiveTimestamp: string,
        locked: boolean,
        invitable: boolean?,
        createTimestamp: string?,
    },

    availableTags: {
        {
            id: string,
            name: string,
            moderated: boolean,
            emojiId: string?,
            emojiName: string?,
        }
    },

    appliedTags: { string },
    defaultReactionEmoji: Emoji.Emoji,
}

export type BaseGuildThread =
    BaseGuildTextChannel.BaseGuildTextChannel
    & typeof(BaseGuildThread.prototype)
    & BaseGuildThreadProperties

return BaseGuildThread.interface
