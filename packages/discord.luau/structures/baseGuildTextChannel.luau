--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Array = require('@deps/polyfill/array')
local Future = require('@deps/future')
local Snowflake = require('@deps/sapphire/snowflake')

-- Utilities
local TypedCollection = require('@discordluau/utils/typedCollection')

-- Structures
local BaseGuildChannel = require('baseGuildChannel')
local Message = require('message')

-- Builders
local MessageBuilder = require('@discordluau/builders/messages/message')

-- REST
local RESTUtils = require('@discordluau/rest/utils/utils')

-- API
local GlobalApi = require('@discordluau/api/global')
local RESTApi = require('@discordluau/api/rest')

-- Typings
local MessageTypes = require('@discordluau/discord.luau/typings/message')

-- Enumerations
local Routes = RESTApi.Routes

-- Functions
local makeURLSearchParams = RESTUtils.makeURLSearchParams

type Future<T> = Future.Future<T>
type Array<T> = Array.Array<T>
type Snowflake = GlobalApi.Snowflake

-- Class
local BaseGuildTextChannel = {}

BaseGuildTextChannel.prototype = {}
BaseGuildTextChannel.interface = {}

BaseGuildTextChannel.prototype.__type = 'BaseGuildTextChannel'

function BaseGuildTextChannel.prototype.triggerTypingIndicator(self: BaseGuildTextChannel)
    return Future.try(function()
        return self.client.rest:post(Routes.channelTyping(self.id))
    end)
end

function BaseGuildTextChannel.prototype.getMessages(
    self: BaseGuildTextChannel,
    limit: number?
): Future.Future<Array<Message.Message>>
    return Future.try(function()
        local query = limit and makeURLSearchParams({ limit = limit }) or nil
        local messageObjects = self.client.rest:get(Routes.channelMessages(self.id), query)
        local messageArray = Array.from({}) :: Array<Message>

        for index, messageObject in messageObjects do
            if self.messages:get(messageObject.id) then
                Array.push(messageArray, self.messages:get(messageObject.id) :: any)
            else
                Array.push(messageArray, Message.new(self.client, messageObject))
            end
        end

        return messageArray
    end)
end

function BaseGuildTextChannel.prototype.getMessage(
    self: BaseGuildTextChannel,
    messageId: string
): Future<Message.Message>
    return Future.try(function()
        local messageObject = self.client.rest:get(Routes.channelMessage(self.id, messageId))

        if self.messages:get(messageObject.id) then
            return self.messages:get(messageObject.id) :: Message.Message
        end

        return Message.new(self.client, messageObject)
    end)
end

function BaseGuildTextChannel.prototype.bulkDelete(
    self: BaseGuildTextChannel,
    messageIds: { Snowflake }
)
    return Future.try(function()
        return self.client.rest:post(Routes.channelBulkDelete(self.id), {
            messages = messageIds,
        })
    end)
end

function BaseGuildTextChannel.prototype.send(
    self: BaseGuildTextChannel,
    message: MessageBuilder.MessageBuilder | MessageTypes.MessageSchema
)
    return Future.try(function()
        local data
        if (message :: any).toPayload and typeof((message :: any).toPayload) == 'function' then
            data = (message :: any):toPayload():resolveBody():resolveFiles():resolveHeaders()
        else
            local discordMessage = MessageBuilder.transform(message)
            data = discordMessage:toPayload():resolveBody():resolveFiles():resolveHeaders()
        end
        return self.client.rest:post(Routes.channelMessages(self.id), data)
    end)
end

function BaseGuildTextChannel.prototype.getPinnedMessages(
    self: BaseGuildTextChannel
): Future<{ [any]: Message.Message }>
    return Future.try(function()
        local messages = self.client.rest:get(Routes.channelPins(self.id))

        for index, messageData in messages do
            messages[index] = Message.new(self.client, messageData)
        end

        return messages
    end)
end

function BaseGuildTextChannel.prototype.constructor(
    self: BaseGuildTextChannel,
    channelData: ChannelData
)
    for index, value in channelData do
        (self :: {})[index] = value
    end
end

function BaseGuildTextChannel.interface.new(
    client: any,
    channelData: ChannelData
): BaseGuildTextChannel
    local self = (
        class(
            { client = client, messages = TypedCollection.new(Message, client) },
            BaseGuildTextChannel.prototype
        ):extend(BaseGuildChannel.new(client, channelData)) :: any
    ) :: BaseGuildTextChannel

    self:constructor(channelData)

    return self
end

type ChannelData = {
    id: string,
    guildId: string,
}

export type BaseGuildTextChannelProperties = {
    lastPinTimestamp: string,
    lastMessageId: string?,
    messages: TypedCollection.TypedCollection<string, Message>,
}

export type BaseGuildTextChannel =
    BaseGuildChannel.BaseGuildChannel
    & typeof(BaseGuildTextChannel.prototype)
    & BaseGuildTextChannelProperties

return BaseGuildTextChannel.interface