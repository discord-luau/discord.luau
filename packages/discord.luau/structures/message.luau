--!strict

-- Standard Library
local net = require('@std/net')
local class = require("@std/class")

-- Modules
local Future = require('@deps/future')
local Snowflake = require('@deps/sapphire/snowflake')

-- Builders
local ActionRowBuilder = require('@discordluau/builders/components/actionRow')
local EmbedBuilder = require('@discordluau/builders/messages/embed')
local MessageBuilder = require('@discordluau/builders/messages/message')

-- Structures
local GuildMember = require('guildMember')

-- REST
local RestAPI = require('@discordluau/api/rest')

-- Typings
local MessageTypes = require("@discordluau/discord.luau/typings/message")

-- Enumerations
local Routes = RestAPI.Routes
local DiscordSnowflake = Snowflake.DiscordSnowflake

--[=[
]=]
local Message = {}

Message.prototype = {}
Message.interface = {}

Message.prototype.__type = 'Message'

function Message.prototype.crosspost(self: Message)
    return Future.try(function()
        local messageObject =
            self.client.rest:post(Routes.channelMessageCrosspost(self.channelId, self.id))

        return Message.interface.new(self.client, messageObject)
    end)
end

function Message.prototype.startThread(
    self: Message,
    name: string,
    autoArchiveDuration: number,
    rateLimitPerUser: number?
)
    return Future.try(function()
        local threadChannel = self.client.rest:post(Routes.threads(self.channelId, self.id), {
            name = name,
            auto_archive_duration = autoArchiveDuration,
            rate_limit_per_user = rateLimitPerUser,
        })
        -- fixme: man this sucks, discordChannel requires DiscordMessage - so we can't create the object for you
        -- you'll need to call :getChannel through the client.. sorry.

        return threadChannel.id
    end)
end

function Message.prototype.reply(
    self: Message,
    messageData: MessageBuilder.MessageBuilder | MessageSchema
)
    return Future.try(function()
        local data
        if
            (messageData :: any).toPayload
            and typeof((messageData :: any).toPayload) == 'function'
        then
            data = (messageData :: any):toPayload():resolveBody():resolveFiles():resolveHeaders()
        else
            local discordMessage = MessageBuilder.transform(messageData)
            data = discordMessage:toPayload():resolveBody():resolveFiles():resolveHeaders()
        end
        return self.client.rest:post(Routes.channelMessages(self.channelId), data)
    end)
end

function Message.prototype.delete(self: Message)
    return Future.try(function()
        return self.client.rest:delete(Routes.channelMessage(self.channelId, self.id))
    end)
end

function Message.prototype.pin(self: Message)
    return Future.try(function()
        return self.client.rest:put(Routes.channelPin(self.channelId, self.id))
    end)
end

function Message.prototype.unpin(self: Message)
    return Future.try(function()
        return self.client.rest:delete(Routes.channelPin(self.channelId, self.id))
    end)
end

function Message.prototype.edit(
    self: Message,
    messageData: MessageBuilder.MessageBuilder | MessageSchema
)
    return Future.try(function()
        local data
        if
            (messageData :: any).toPayload
            and typeof((messageData :: any).toPayload) == 'function'
        then
            data = (messageData :: any):toPayload()
        else
            local discordMessage = MessageBuilder.transform(messageData)
            data = discordMessage:toPayload()
        end
        return self.client.rest:patch(Routes.channelMessage(self.channelId, self.id), data)
    end)
end

function Message.prototype.addReaction(self: Message, reaction: string)
    return Future.try(function()
        local isBinary = string.find(reaction, ':') == nil

        return self.client.rest:put(
            Routes.channelMessageOwnReaction(
                self.channelId,
                self.id,
                net.urlEncode(reaction, isBinary)
            )
        )
    end)
end

function Message.prototype.removeReaction(self: Message, reaction: string)
    return Future.try(function()
        local isBinary = string.find(reaction, ':') == nil
        return self.client.rest:delete(
            Routes.channelMessageOwnReaction(
                self.channelId,
                self.id,
                net.urlEncode(reaction, isBinary)
            )
        )
    end)
end

function Message.prototype.removeUserReaction(self: Message, userId: string, reaction: string)
    return Future.try(function()
        local isBinary = string.find(reaction, ':') == nil

        return self.client.rest:delete(
            Routes.channelMessageUserReaction(
                self.channelId,
                self.id,
                net.urlEncode(reaction, isBinary),
                userId
            )
        )
    end)
end

function Message.prototype.getReactions(self: Message, reaction: string)
    return Future.try(function()
        local isBinary = string.find(reaction, ':') == nil

        return self.client.rest:get(
            Routes.channelMessageReaction(
                self.channelId,
                self.id,
                net.urlEncode(reaction, isBinary)
            )
        )
    end)
end

function Message.prototype.removeAllReactions(self: Message)
    return Future.try(function()
        return self.client.rest:delete(Routes.channelNessageAllReactions(self.channelId, self.id))
    end)
end

function Message.prototype.removeAllReactionsForEmoji(self: Message, reaction: string)
    return Future.try(function()
        local isBinary = string.find(reaction, ':') == nil

        return self.client.rest:delete(
            Routes.channelMessageReaction(
                self.channelId,
                self.id,
                net.urlEncode(reaction, isBinary)
            )
        )
    end)
end

function Message.prototype.constructor(self: Message, messageData: MessageData)
    for index, value in messageData do
        (self :: any)[index] = value
    end

    self.createdTimestamp = DiscordSnowflake:timestampFrom(messageData.id) :: number
end

function Message.interface.new(client: any, messageData: MessageData, channel: any?): Message
    if channel then
        messageData.channel = channel
    end

    local self: Message

    if messageData.channel then
        local messageStruct = {
            client = client,
        }

        if messageData.member then
            local discordGuild = client.guilds:get(messageData.guildId)
            if discordGuild then
                messageData.member = discordGuild.members:update(
                    messageData.author.id,
                    client,
                    messageData.author.id,
                    discordGuild.id,
                    messageData.member
                )
                -- messageData.member = discordGuild.members:fetch(messageData.guildId, function()
                -- 	return DiscordGuildMember.new(client, messageData.author.id, messageData.guildId, messageData.member)
                -- end)
            else
                messageData.member = GuildMember.new(
                    client,
                    messageData.author.id,
                    messageData.guildId,
                    messageData.member
                )
            end
        end

        self = (class(messageStruct, Message.prototype) :: any) :: Message
    else
        local messageStruct = {
            client = client,
        }

        if messageData.member then
            local discordGuild = client.guilds:get(messageData.guildId)
            if discordGuild then
                messageData.member = discordGuild.members:update(
                    messageData.author.id,
                    client,
                    messageData.author.id,
                    messageData.guildId,
                    messageData.member
                )
            else
                messageData.member = GuildMember.new(
                    client,
                    messageData.author.id,
                    messageData.guildId,
                    messageData.member
                )
            end
        end

        self = (class(messageStruct, Message.prototype) :: any) :: Message
    end

    self:constructor(messageData)

    return self
end

type MessageComponent = MessageTypes.MessageComponent
type MessageSchema = MessageTypes.MessageSchema

type MessageData = {
    id: string,

    guildId: string,
    channelId: string,

    author: {
        username: string,
        avatar: string,
        id: string,
        bot: boolean,
        discriminator: string,
        publicFlags: number,
    },

    member: {
        [any]: any,
    },

    channel: any,
}

export type MessageProperties = {
    client: any,

    mentionRoles: { string },
    components: { MessageComponent },
    -- attachments: { unknown },
    -- embeds: { unknown },
    tts: boolean,
    mentionEveryone: boolean,
    nonce: string,
    id: string,
    author: {
        username: string,
        globalName: string,
        avatar: string,
        id: string,
        publicFlags: number,
        discriminator: string,
    },
    content: string,
    mentions: { string },
    flags: number,
    timestamp: string,
    createdTimestamp: number,
    type: number,
    pinned: boolean,
    guildId: string,
    channelId: string,
    member: {
        flags: number,
        deaf: boolean,
        roles: { [string]: string },
        pending: boolean,
        mute: boolean,
        joinedAt: string,
    },
}

export type Message = typeof(Message.prototype) & MessageProperties

return Message.interface
