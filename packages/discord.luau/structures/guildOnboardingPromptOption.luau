--!strict

-- Standard Libraries 
local class = require('@std/class')

-- Structures
local Emoji = require('@discordluau/discord.luau/structures/emoji')

local GuildOnboardingPromptOption = {}
GuildOnboardingPromptOption.prototype = {}
GuildOnboardingPromptOption.interface = {}

GuildOnboardingPromptOption.prototype.__type = 'GuildOnboardingPromptOption'

function GuildOnboardingPromptOption.prototype.constructor(
    self: GuildOnboardingPromptOption,
    onboardingPromptData: OnboardingPromptData
)
    if onboardingPromptData.emoji then
        onboardingPromptData.emoji = Emoji.new(self.client, onboardingPromptData.emoji)
    end

    for index, value in onboardingPromptData do
        (self :: {})[index] = value
    end
end

function GuildOnboardingPromptOption.interface.new(
    client: any,
    onboardingPromptData: OnboardingPromptData
): GuildOnboardingPromptOption
    local self: GuildOnboardingPromptOption = (class({
        id = onboardingPromptData.id,
        client = client,
    }, GuildOnboardingPromptOption.prototype) :: any) :: GuildOnboardingPromptOption

    self:constructor(onboardingPromptData)

    return self
end

type OnboardingPromptData = {
    id: string,
    [string]: any,
}

export type GuildOnboardingPromptOptionProperties = {
    client: any,
    id: string,
    channelIds: { string },
    roleIds: { string },
    emoji: Emoji.Emoji,
    title: string,
    description: string?,
}

export type GuildOnboardingPromptOption =
    typeof(GuildOnboardingPromptOption.prototype)
    & GuildOnboardingPromptOptionProperties

return GuildOnboardingPromptOption.interface
