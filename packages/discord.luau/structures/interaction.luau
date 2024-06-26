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
local PermissionsBitField = require('../utils/permissionsBitField')

-- Structures
local DiscordChannel = require('channel')
local DiscordGuild = require('guild')
local DiscordGuildMember = require('guildMember')
local DiscordMessage = require('message')
local DiscordTextChannel = require('textChannel')
local DiscordUser = require('user')
local InteractionOptionResolver =
    require('interactionOptionResolver')

-- API
local InteractionApi = require('@discordluau/api/payloads/interaction')
local MessageApi = require('@discordluau/api/payloads/message')
local RESTApi = require('@discordluau/api/rest')

-- Types
local InteractionTypes = require('../typings/interaction')

-- Enumerations
local ApplicationCommandType = InteractionApi.ApplicationCommandType
local InteractionType = InteractionApi.InteractionType

local Routes = RESTApi.Routes
local MessageFlags = MessageApi.MessageFlags

local DiscordSnowflake = Snowflake.DiscordSnowflake

local Interaction = {}

Interaction.interface = {}
Interaction.prototype = {}

Interaction.prototype.__type = 'Interaction'

function Interaction.prototype.isCommand(self: Interaction)
    return tonumber(self.type) == InteractionType.ApplicationCommand
end

function Interaction.prototype.isChatInputCommand(self: Interaction)
    return tonumber(self.type) == InteractionType.ApplicationCommand
        and self.data.type == ApplicationCommandType.ChatInput
end

function Interaction.prototype.isMessageComponent(self: Interaction)
    return tonumber(self.type) == InteractionType.ModalSubmit
end

function Interaction.interface.new(client: any, jsonData: { [any]: any }): Interaction
    -- local timeNow = Date.getMilisecondsTime()
    local interactionStruct = {
        client = client,
    }

    local user = jsonData.member.user
    jsonData.member.user = nil

    local newTimestamp = DiscordSnowflake:timestampFrom(jsonData.id) :: number

    interactionStruct.type = jsonData.type
    interactionStruct.id = jsonData.id
    interactionStruct.token = jsonData.token
    interactionStruct.applicationId = jsonData.applicationId
    interactionStruct.channelId = jsonData.channel.id or nil
    interactionStruct.guildId = jsonData.guildId or nil
    interactionStruct.version = jsonData.version
    interactionStruct.appPermissions = PermissionsBitField.from(jsonData.appPermissions)
    interactionStruct.createdTimestamp = newTimestamp

    interactionStruct.guild = client.guilds:update(jsonData.guild.id, client, jsonData.guild)
    interactionStruct.channel =
        client.channels:update(jsonData.channel.id, client, jsonData.channel)
    interactionStruct.user = client.users:update(user.id, client, user)
    interactionStruct.member = interactionStruct.guild.members:update(
        user.id,
        client,
        user.id,
        interactionStruct.guildId,
        jsonData.member
    )
    interactionStruct.entitlements = jsonData.entitlements
    interactionStruct.guildLocale = jsonData.guildLocale or nil
    interactionStruct.locale = jsonData.locale
    interactionStruct.entitlementSkuIds = jsonData.entitlementSkuIds
    interactionStruct.data = jsonData.data

    -- interactionStruct.options = InteractionOptionResolver.new(jsonData.data.options)
	local self = class(interactionStruct, Interaction.prototype)
    return (self :: any) :: Interaction
end

type DeferReplyOptions = InteractionTypes.DeferReplyOptions

export type InteractionProperties = {
	client: any,
    type: number,

    channel: DiscordTextChannel.TextChannel,
    guild: DiscordGuild.Guild,
    guildId: string,
    user: DiscordUser.User,

    createdTimestamp: number,

    token: string,
    applicationId: string,
    id: string,
    data: {
        name: string,
        type: number,
        id: string,
    },
    channelId: string,
    guilldId: string,
    version: number,
    appPermissions: PermissionsBitField.PermissionsBitField,
    entitlements: { unknown },
    entitlementSkuIds: { unknown },

    -- options: InteractionOptionResolver.InteractionOptionResolver,

    deferred: boolean,
}

export type Interaction = typeof(Interaction.prototype) & InteractionProperties 

return Interaction.interface
