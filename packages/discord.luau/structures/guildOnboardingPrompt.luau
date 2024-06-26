--!strict

-- Standard Libraries 
local class = require('@std/class')

-- Structures
local GuildOnboardingPromptOption =
    require('@discordluau/discord.luau/structures/guildOnboardingPromptOption')

local GuildOnboardingPrompt = {}
GuildOnboardingPrompt.prototype = {}
GuildOnboardingPrompt.interface = {}

GuildOnboardingPrompt.prototype.__type = 'GuildOnboardingPrompt'

function GuildOnboardingPrompt.prototype.constructor(
    self: GuildOnboardingPrompt,
    onboardingPromptData: OnboardingPromptData
)
    if onboardingPromptData.options then
        for index, value in onboardingPromptData.options do
            onboardingPromptData.options[index] =
                GuildOnboardingPromptOption.new(self.client, value)
        end
    end

    for index, value in onboardingPromptData do
        (self :: {})[index] = value
    end
end

function GuildOnboardingPrompt.interface.new(
    client: any,
    onboardingPromptData: OnboardingPromptData
): GuildOnboardingPrompt
    local self: GuildOnboardingPrompt = (class({
        id = onboardingPromptData.id,
        client = client,
    }, GuildOnboardingPrompt.prototype) :: any) :: GuildOnboardingPrompt

    self:constructor(onboardingPromptData)

    return self
end

type OnboardingPromptData = {
    id: string,
    [string]: any,
}

export type GuildOnboardingPromptProperties = {
    client: any,
    id: string,
    type: number,
    options: { GuildOnboardingPromptOption.GuildOnboardingPromptOption },
    title: string,
    singleSelect: boolean,
    required: boolean,
    inOboarding: boolean,
}

export type GuildOnboardingPrompt =
    typeof(GuildOnboardingPrompt.prototype)
    & GuildOnboardingPromptProperties

return GuildOnboardingPrompt.interface
