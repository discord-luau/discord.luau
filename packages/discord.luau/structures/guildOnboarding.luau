--!strict

-- Standard Libraries 
local class = require('@std/class')

-- Structures
local GuildOnboardingPrompt = require('@discordluau/discord.luau/structures/guildOnboardingPrompt')

local GuildOnboarding = {}
GuildOnboarding.prototype = {}
GuildOnboarding.interface = {}

GuildOnboarding.prototype.__type = 'GuildOnboarding'

function GuildOnboarding.prototype.constructor(
    self: GuildOnboarding,
    onboardingData: OnboardingData
)
    if onboardingData.options then
        for index, value in onboardingData.options do
            onboardingData.options[index] = GuildOnboardingPrompt.new(self.client, value)
        end
    end

    for index, value in onboardingData do
        (self :: {})[index] = value
    end
end

function GuildOnboarding.interface.new(client: any, onboardingData: OnboardingData): GuildOnboarding
    local self: GuildOnboarding = (class({
        id = onboardingData.id,
        client = client,
    }, GuildOnboarding.prototype) :: any) :: GuildOnboarding

    self:constructor(onboardingData)

    return self
end

type OnboardingData = {
    guildId: string,
    [string]: any,
}

export type GuildOnboardingProperties = {
    client: any,
    guildId: string,
    prompts: { GuildOnboardingPrompt.GuildOnboardingPrompt },
    defaultChannelIds: { string },
    enabled: boolean,
    mode: number,
}

export type GuildOnboarding = typeof(GuildOnboarding.prototype) & GuildOnboardingProperties

return GuildOnboarding.interface
