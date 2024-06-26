--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')

-- Utilities
local TypedCollection = require('@discordluau/utils/typedCollection')

-- Structures
local BaseChannel = require('@discordluau/discord.luau/structures/baseChannel')
local Message = require('@discordluau/discord.luau/structures/message')
local User = require('@discordluau/discord.luau/structures/user')

-- Builders
local MessageBuilder = require('@discordluau/builders/messages/message')

-- REST
local RESTUtils = require('@discordluau/rest/utils/utils')

-- API
local GlobalApi = require('@discordluau/api/global')
local RESTApi = require('@discordluau/api/rest')

-- Typings
local MessageTypes = require("@discordluau/discord.luau/typings/message")

-- Voices
local VoiceConnection = require('@discordluau/voice/voiceConnection')

-- Enumerations
local Routes = RESTApi.Routes


-- Functions
local makeURLSearchParams = RESTUtils.makeURLSearchParams

type Future<T> = Future.Future<T>
type Snowflake = GlobalApi.Snowflake

local BaseUserChannel = {}

BaseUserChannel.prototype = {}
BaseUserChannel.interface = {}

BaseUserChannel.prototype.__type = 'BaseUserChannel'

function BaseUserChannel.prototype.triggerTypingIndicator(self: BaseUserChannel)
    return Future.try(function()
        return self.client.rest:post(Routes.channelTyping(self.id))
    end)
end

function BaseUserChannel.prototype.getMessages(
    self: BaseUserChannel,
    limit: number?
): Future.Future<{ [any]: Message.Message }>
    return Future.try(function()
        local query = limit and makeURLSearchParams({ limit = limit }) or nil
        local messageObjects = self.client.rest:get(Routes.channelMessages(self.id), query)

        for index, messageObject in messageObjects do
            if self.messages:get(messageObject.id) then
                messageObjects[index] = self.messages:get(messageObject.id)
            else
                messageObjects[index] = Message.new(self.client, messageObject)
            end
        end

        return messageObjects
    end)
end

function BaseUserChannel.prototype.getMessage(
    self: BaseUserChannel,
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

function BaseUserChannel.prototype.bulkDelete(self: BaseUserChannel, messageIds: { Snowflake })
    return Future.try(function()
        return self.client.rest:post(
            Routes.channelBulkDelete(self.id),
            {
                messages = messageIds,
            } 
        )
    end)
end

function BaseUserChannel.prototype.send(
    self: BaseUserChannel,
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

function BaseUserChannel.prototype.getPinnedMessages(
    self: BaseUserChannel
): Future<{ [any]: Message.Message }>
    return Future.try(function()
        local messages = self.client.rest:get(Routes.channelPins(self.id))

        for index, messageData in messages do
            messages[index] = Message.new(self.client, messageData)
        end

        return messages
    end)
end

function BaseUserChannel.prototype.constructor(self: BaseUserChannel, channelData: ChannelData)
    for index, value in channelData do
        (self :: {})[index] = value
    end
    self.messages = TypedCollection.new(Message, self.client)
end

function BaseUserChannel.interface.new(client: any, channelData: ChannelData): BaseUserChannel
    if channelData.recipients then
        for key, value in channelData.recipients do
            channelData.recipients[key] = User.new(client, value)
        end
    end

    local self: BaseUserChannel = (class({ client = client }, BaseUserChannel.prototype):extend(
        BaseChannel.new(client, channelData)
    ) :: any) :: BaseUserChannel

    self:constructor(channelData)

    return self
end

type ChannelData = {
    id: string,
    [string]: any,
}

export type BaseUserChannelProperties = {
    client: any,
    id: string,
    recipients: { User.User },
    messages: TypedCollection.TypedCollection<string, Message>,
}

export type BaseUserChannel =
    BaseChannel.BaseChannel
    & typeof(BaseUserChannel.prototype)
    & BaseUserChannelProperties

return BaseUserChannel.interface
