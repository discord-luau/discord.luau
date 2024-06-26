--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')
local Snowflake = require('@deps/sapphire/snowflake')
local Table = require('@deps/table')

-- Builders
local MessageBuilder = require('@discordluau/builders/messages/message')
local ModalBuilder = require('@discordluau/builders/interactions/modal')

-- Internal Utilities
local PermissionsBitField = require('@discordluau/discord.luau/utils/permissionsBitField')

-- Structures
local Guild = require('guild')
local GuildMember = require('guildMember')
local Interaction = require('interaction')
local InteractionOptionResolver =
    require('interactionOptionResolver')
local Message = require('message')
local TextChannel = require('textChannel')
local User = require('user')

-- API
local InteractionApi = require('@discordluau/api/payloads/interaction')
local MessageApi = require('@discordluau/api/payloads/message')
local RESTApi = require('@discordluau/api/rest')

-- Types
local InteractionTypes = require('@discordluau/discord.luau/typings/interaction')
local MessageTypes = require("@discordluau/discord.luau/typings/message")

-- Enumerations
local ApplicationCommandType = InteractionApi.ApplicationCommandType
local InteractionType = InteractionApi.InteractionType

local Routes = RESTApi.Routes
local MessageFlags = MessageApi.MessageFlags



local DiscordSnowflake = Snowflake.DiscordSnowflake

type DeferReplyOptions = InteractionTypes.DeferReplyOptions

local ChatInputCommandInteraction = {}

ChatInputCommandInteraction.interface = {}
ChatInputCommandInteraction.prototype = {}

ChatInputCommandInteraction.prototype.__type = 'ChatInputCommandInteraction'

function ChatInputCommandInteraction.prototype.editReply(
    self: ChatInputCommandInteraction,
    messageData: MessageBuilder.MessageBuilder | MessageTypes.MessageSchema
)
    return Future.new(function()
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

        return self.client.rest:patch(
            Routes.webhookMessage(self.client.application.id, self.token),
            data
        )
    end)
end

function ChatInputCommandInteraction.prototype.sendModal(
    self: ChatInputCommandInteraction,
    modalObject: ModalBuilder.ModalBuilder
)
    return Future.new(function()
        return self.client.rest:post(
            Routes.interactionCallback(self.id, self.token),
            {
                type = 9,
                data = modalObject:toJSON(),
            } 
        )
    end)
end

function ChatInputCommandInteraction.prototype.reply(
    self: ChatInputCommandInteraction,
    messageData: MessageBuilder.MessageBuilder | MessageTypes.MessageSchema
)
    if self.deferred then
        return self:editReply(messageData)
    else
        return Future.new(function()
            local payloadObject
            if
                (messageData :: any).toPayload
                and typeof((messageData :: any).toPayload) == 'function'
            then
                payloadObject = (messageData :: any):toPayload():resolveBody():resolveFiles()
            else
                local discordMessage = MessageBuilder.transform(messageData)
                payloadObject = discordMessage:toPayload():resolveBody():resolveFiles()
            end
            return self.client.rest:post(
                Routes.interactionCallback(self.id, self.token),
                payloadObject:update(function(data)
                    return {
                        type = 4,
                        data = data,
                    }
                end)
            )
        end)
    end
end

function ChatInputCommandInteraction.prototype.deferReply(
    self: ChatInputCommandInteraction,
    options: DeferReplyOptions?
): Future.Future<Message.Message?>
    return Future.try(function(): Message.Message?
        local opt = options or {} :: DeferReplyOptions
        local opts = Table.Reconcile(opt, { ephemeral = false, fetchReply = false })
        self.deferred = true

        self.client.rest:post(
            Routes.interactionCallback(self.id, self.token),
            {
                type = 5,
                data = {
                    flags = opts.ephemeral and MessageFlags.Ephemeral or nil,
                },
            } 
        )

        local data = self.client.rest:get(Routes.webhookMessage(self.client.user.id, self.token))
        local messageData = {
            guildId = self.guildId,
            member = (self :: any).rawMember,
            author = data.author,
            id = data.id,
            channelId = data.channelId,
        }

        if opts.fetchReply then
            return Message.new(self.client, messageData, self.channel)
        else
            return nil
        end
    end)
end

function ChatInputCommandInteraction.interface.new(
    client: any,
    jsonData: { [any]: any }
): ChatInputCommandInteraction
    return class(
        { options = InteractionOptionResolver.new(jsonData.data.options), deferred = false },
        ChatInputCommandInteraction.prototype
    ):extend(Interaction.new(client, jsonData)) :: ChatInputCommandInteraction
end

export type ChatInputCommandInteraction =
    typeof(ChatInputCommandInteraction.prototype)
    & Interaction.Interaction
    & {
        options: InteractionOptionResolver.InteractionOptionResolver,
        deferred: boolean,
    }

return ChatInputCommandInteraction.interface
