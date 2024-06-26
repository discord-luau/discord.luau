--!strict

-- Standard Libraries
local class = require('@std/class')

-- Builders
local AutoModerationRuleBuilder = require('@discordluau/builders/guilds/autoModerationRule')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes

--[=[
    The `DiscordAutomoderationRule` class provides methods to interact with Discord auto-moderation rules, including modifying and deleting rules.
]=]
local AutoModerationRule = {}

AutoModerationRule.prototype = {}
AutoModerationRule.interface = {}

AutoModerationRule.prototype['_type'] = 'AutoModerationRule'

export type AutoModerationRuleProperties = {
    client: any,

    id: string,
    guildId: string,
    name: string,
    creatorId: string,
    eventType: number,
    triggerType: number,
    enabled: boolean?,
    exemptRoles: { string },
    exemptChannels: { string },
    triggerMetadata: {
        keywordFilter: { string },
        regexPatterns: { string },
        presets: { number },
        allowList: { string },
        mentionTotalLimit: number,
        mentionRaidProtectionEnabled: boolean,
    },
    actions: {
        type: number,
        metadata: {
            channelId: string,
            durationSeconds: number,
            customMessage: string?,
        }?,
    },
}

function AutoModerationRule.prototype.delete(self: AutoModerationRule)
    return self.client.rest:delete(Routes.guildAutoModerationRule(self.guildId, self.id))
end

function AutoModerationRule.prototype.edit(self: AutoModerationRule, moderationRuleBuilder: AutoModerationRuleBuilder.AutoModerationRuleBuilder)
    return self.client.rest:patch(
        Routes.guildAutoModerationRule(self.guildId, self.id),
        moderationRuleBuilder:toJSON()
    )
end

-- Aliases
AutoModerationRule.prototype.modify = AutoModerationRule.prototype.edit

function AutoModerationRule.prototype.constructor(
    self: AutoModerationRule,
    autoModerationData: AutoModerationData
)
    for index, value in autoModerationData do
        (self :: any)[index] = value
    end
end

function AutoModerationRule.interface.new(
    client: any,
    autoModerationData: AutoModerationData
): AutoModerationRule
    local self = (class({
        id = autoModerationData.id,
        client = client,
    }, AutoModerationRule.prototype) :: any) :: AutoModerationRule

    self:constructor(autoModerationData)

    return self
end

type AutoModerationData = {
    id: string,
    [string]: any,
}

export type AutoModerationRule = typeof(AutoModerationRule.prototype) & AutoModerationRuleProperties

return AutoModerationRule.interface
