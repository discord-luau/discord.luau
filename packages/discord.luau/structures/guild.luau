--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local LuauPolyfill = require("@deps/polyfill")
local Future = require("@deps/future")
local Table = require("@deps/table")

-- Utilities
local TypedCollection = require('@discordluau/utils/typedCollection')

-- Builders
local AutoModerationRuleBuilder = require('@discordluau/builders/guilds/autoModerationRule')
local ChannelBuilder = require('@discordluau/builders/channel')
local GuildBuilder = require('@discordluau/builders/guilds/guild')
local RoleBuilder = require('@discordluau/builders/guilds/role')
local SlashCommandBuilder = require('@discordluau/builders/interactions/slashCommand')

-- Structures
local AutoModerationRule = require('autoModerationRule')
local Channel = require('channel')
local Emoji = require('emoji')
local GuildBan = require('guildBan')
local GuildMember = require('guildMember')
local GuildPreview = require('guildPreview')
local Integration = require('integration')
local Role = require('role')
local User = require('user')

-- API
local GuildApi = require('@discordluau/api/payloads/guild')
local RESTApi = require('@discordluau/api/rest')

-- REST
local RestUtils = require('@discordluau/rest/utils/utils')

-- Enumerations
local Array = LuauPolyfill.Array
local Routes = RESTApi.Routes

-- Functions
local makeURLSearchParams = RestUtils.makeURLSearchParams

local Guild = {}

Guild.prototype = {}
Guild.interface = {}

Guild.prototype.__type = 'Guild'

-- Add
function Guild.prototype.addMember(
    self: Guild,
    userId: string,
    accessToken: string
): Future.Future<GuildMember.GuildMember>
    return Future.try(function()
        local guildMember = self.client.rest:put(Routes.guildMember(self.id, userId), {
            access_token = accessToken,
        })

        return GuildMember.new(self.client, userId, self.id, guildMember)
    end)
end

-- Begin
function Guild.prototype.beginPrune(
    self: Guild,
    options: BeginPruneOptions
): Future.Future<{ pruned: number? }>
    return Future.try(function()
        return self.client.rest:post(Routes.guildPrune(self.id), {
            days = options.days,
            compute_prune_count = options.computePruneCount,
            include_roles = options.includeRoles,
        }) :: {
            pruned: number?,
        }
    end)
end

-- Bulk
function Guild.prototype.bulkBan(self: Guild, options: BulkBanOptions)
    return Future.try(function()
        return self.client.rest:post(Routes.guildBulkBan(self.id), {
            delete_message_seconds = options.deleteMessageSeconds,
            user_ids = options.userIds,
        })
    end)
end

-- Create
function Guild.prototype.createAutoModerationRule(
    self: Guild,
    autoModerationRule: AutoModerationRuleBuilder.AutoModerationRuleBuilder
): Future.Future<
    AutoModerationRule.AutoModerationRule
>
    return Future.try(function()
        local RawAutoModerationRule = self.client.rest:post(
            Routes.guildAutoModerationRules(self.id),
            autoModerationRule:toJSON()
        )

        return AutoModerationRule.new(self.client, RawAutoModerationRule)
    end)
end

function Guild.prototype.createBan(
    self: Guild,
    userId: string,
    options: CreateBanOptions?
): Future.Future<GuildBan.GuildBan>
    return Future.try(function()
        if options and options.deleteMessageDays then
            options.deleteMessageSeconds = options.deleteMessageDays * 86400
        end

        local guildBan = self.client.rest:put(Routes.guildBan(self.id, userId), options and {
            delete_message_seconds = options.deleteMessageSeconds,
        } or nil)

        return GuildBan.new(self.client, guildBan)
    end)
end

function Guild.prototype.createChannel(
    self: Guild,
    channelBuilder: ChannelBuilder.ChannelBuilder
): Future.Future<Channel.Channel>
    return Future.try(function()
        local channelData =
            self.client.rest:post(Routes.guildChannels(self.id), channelBuilder:toJSON())

        return Channel.from(self.client, channelData)
    end)
end

function Guild.prototype.createEmoji(
    self: Guild,
    userId: string,
    options: CreateEmojiOptions
): Future.Future<Emoji.Emoji>
    return Future.try(function()
        local guildEmoji = self.client.rest:post(Routes.guildEmojis(self.id), {
            image = options.image,
            name = options.name,
            roles = options.roles,
        })

        return Emoji.new(self.client, guildEmoji)
    end)
end

function Guild.prototype.createRole(
    self: Guild,
    roleBuilder: RoleBuilder.RoleBuilder
): Future.Future<Role.Role>
    return Future.try(function()
        local rawRole = self.client.rest:post(Routes.guildRoles(self.id), roleBuilder:toJSON())
        return Role.new(self.client, self.id, rawRole)
    end)
end

function Guild.prototype.createSlashCommand(
    self: Guild,
    command: SlashCommandBuilder.SlashCommandBuilder
)
    return Future.try(function()
        return self.client.rest:post(
            Routes.applicationGuildCommands(self.client.application.id, self.id),
            command:toJSON()
        )
    end)
end

-- Delete
function Guild.prototype.delete(self: Guild)
    return Future.try(function()
        return self.client.rest:delete(Routes.guild(self.id))
    end)
end

function Guild.prototype.deleteSlashCommand(self: Guild, commandId: string)
    return Future.try(function()
        return self.client.rest:delete(
            Routes.applicationGuildCommand(self.client.application.id, self.id, commandId)
        )
    end)
end

-- Edit
function Guild.prototype.edit(self: Guild, guildSchema: GuildBuilder.GuildBuilder | GuildSchema)
    return Future.try(function()
        local data: any
        if (guildSchema :: any)['toJSON'] and typeof((guildSchema :: any).toJSON) == 'function' then
            data = (guildSchema :: any):toJSON()
        else
            local schema = guildSchema :: GuildSchema
            data = {
                data = {
                    name = schema.name,
                    region = schema.region,
                    verification_level = schema.verificationLevel,
                    default_message_notifications = schema.defaultMessageNotifications,
                    explicit_content_filter = schema.explicitContentFilter,
                    afk_channel_id = schema.afkChannelId,
                    afk_timeout = schema.afkTimeout,
                    owner_id = schema.ownerId,
                    system_channel_id = schema.systemChannelId,
                    system_channel_flags = schema.systemChannelFlags,
                    rules_channel_id = schema.rulesChannelId,
                    public_update_channel_id = schema.publicUpdateChannelId,
                    preferred_locale = schema.preferredLocale,
                    features = schema.features,
                    description = schema.description,
                    premium_progress_bar_enabled = schema.premiumProgressBarEnabled,
                    safety_alerts_channel_id = schema.safetyAlertsChannelId,
                }
            }
        end
        return self.client.rest:patch(Routes.guild(self.id), data)
    end)
end

function Guild.prototype.editSlashCommand(self: Guild, commandId: string)
    return Future.try(function()
        return self.client.rest:patch(
            Routes.applicationGuildCommand(self.client.application.id, self.id, commandId)
        )
    end)
end

-- Get
function Guild.prototype.getAuditLogs(self: Guild)
    return Future.try(function()
        local guildAuditLogs = self.client.rest:get(Routes.guildAuditLog(self.id))

        for index, channelObject in guildAuditLogs.threads do
            guildAuditLogs.threads[index] = Channel.from(self.client, channelObject)
        end

        for index, userObject in guildAuditLogs.users do
            guildAuditLogs.users[index] = User.new(self.client, userObject)
        end

        return guildAuditLogs
    end)
end

function Guild.prototype.getAutoModerationRule(
    self: Guild,
    ruleId: string
): Future.Future<AutoModerationRule.AutoModerationRule>
    return Future.try(function()
        local RawAutoModerationRule =
            self.client.rest:get(Routes.guildAutoModerationRule(self.id, ruleId))

        return AutoModerationRule.new(self.client, RawAutoModerationRule)
    end)
end

function Guild.prototype.getAutoModerationRules(self: Guild): Future.Future<
    Array<AutoModerationRule.AutoModerationRule>
>
    return Future.try(function()
        local RawAutoModerationRules =
            self.client.rest:get(Routes.guildAutoModerationRules(self.id))
        local autoModerationRulesArrays =
            Array.from({}) :: Array<AutoModerationRule.AutoModerationRule>

        for index, value in RawAutoModerationRules do
            Array.push(autoModerationRulesArrays, AutoModerationRule.new(self.client, value))
        end

        return autoModerationRulesArrays
    end)
end

function Guild.prototype.getBan(self: Guild, userId: string): Future.Future<GuildBan.GuildBan>
    return Future.try(function()
        local guildBan = self.client.rest:get(Routes.guildBan(self.id, userId))

        return GuildBan.new(self.client, guildBan)
    end)
end

function Guild.prototype.getBans(
    self: Guild,
    limit: number?,
    before: string?,
    after: string?
): Future.Future<{ [any]: GuildBan.GuildBan }>
    return Future.try(function()
        local guildBans = self.client.rest:get(
            Routes.guildBans(self.id),
            makeURLSearchParams({ before = before or '', after = after or '', limit = limit or 100 })
        )
        for key, value in guildBans do
            guildBans[key] = GuildBan.new(self.client, value)
        end

        return guildBans
    end)
end

function Guild.prototype.getIntegrations(self: Guild): Future.Future<Array<Integration.Integration>>
    return Future.try(function()
        local guildIntegrations = self.client.rest:get(Routes.guildIntegrations(self.id))
        local integrationArrays = Array.from({}) :: Array<Integration.Integration>

        for key, value in guildIntegrations do
            Array.push(integrationArrays, Integration.new(self.client, self.id, value))
        end

        return integrationArrays
    end)
end

function Guild.prototype.getPreview(self: Guild): Future.Future<GuildPreview.GuildPreview>
    return Future.try(function()
        local previewData = self.client.rest:get(Routes.guildPreview(self.id))

        return GuildPreview.new(self.client, previewData)
    end)
end

function Guild.prototype.getRoles(self: Guild): Future.Future<Array<Role.Role>>
    return Future.try(function()
        local rawGuildRoles = self.client.rest:get(Routes.guildRoles(self.id))
        local guildRoles = Array.from({}) :: Array<Role.Role>

        for _, value in rawGuildRoles do
            Array.push(guildRoles, Role.new(self.client, self.id, value))
        end

        return guildRoles
    end)
end

function Guild.prototype.getSlashCommands(self: Guild)
    return Future.try(function()
        return self.client.rest:get(
            Routes.applicationGuildCommands(self.client.application.id, self.id)
        )
    end)
end

-- Set
function Guild.prototype.setSlashCommands(
    self: Guild,
    commands: { SlashCommandBuilder.SlashCommandBuilder }
)
    return Future.try(function()
        local commandObjects = Array.from({})

        for index, commandBuilder in commands do
            Array.push(commandObjects, commandBuilder:toJSON())
        end

        return self.client.rest:put(
            Routes.applicationGuildCommands(self.client.application.id, self.id),
            commandObjects
        )
    end)
end

-- Extras
Guild.prototype.modify = Guild.prototype.edit

function Guild.prototype.constructor(self, guildData: GuildData)
    local rolesData = guildData.roles
    guildData.roles = nil :: any

    if guildData.emojis then
        for index, value in guildData.emojis do
            guildData.emojis[index] = Emoji.new(self.client, value)
        end
    end

    for index, value in guildData do
        self[index] = value
    end

    self.roles = TypedCollection.new(Role, self.client)
    self.members = TypedCollection.new(GuildMember, self.client)
    self.bans = TypedCollection.new(GuildBan, self.client)

    if rolesData then
        for index, value in rolesData do
            self.roles:set(value.name, value)
        end
    end
end

function Guild.interface.new(client: any, guildData: GuildData): Guild
    local self = (class({
        client = client,
        shardId = ((tonumber(guildData.id) :: number / 2 ^ 22) % client.shardCount) + 1,
    }, Guild.prototype) :: any)

    self:constructor(guildData)

    return self :: Guild
end

type Array<T> = LuauPolyfill.Array<T>

type BeginPruneOptions = GuildApi.BeginPruneOptions
type BulkBanOptions = GuildApi.BulkBanOptions
type CreateBanOptions = GuildApi.CreateBanOptions
type CreateEmojiOptions = GuildApi.CreateEmojiOptions

type GuildData = {
    id: string,
    roles: { any },
    emojis: { any },
}

export type Guild = typeof(Guild.prototype) & {
    client: any,
    shardId: number,

    id: string,

    roles: TypedCollection.TypedCollection<string, Role.Role>,
    emojis: { Emoji.Emoji },
    members: TypedCollection.TypedCollection<string, GuildMember.GuildMember>,
    bans: TypedCollection.TypedCollection<string, GuildBan.GuildBan>,
}

export type GuildSchema = {
    name: string,
    region: string?,
    verificationLevel: number,
    defaultMessageNotifications: number,
    explicitContentFilter: number,
    afkChannelId: string,
    afkTimeout: number,
    ownerId: string,
    systemChannelId: string,
    systemChannelFlags: number,
    rulesChannelId: string,
    publicUpdateChannelId: string,
    preferredLocale: string,
    features: { string },
    description: string,
    premiumProgressBarEnabled: boolean,
    safetyAlertsChannelId: string,
}

return Guild.interface
