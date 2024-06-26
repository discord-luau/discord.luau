--!strict

-- Standard Libraries
local class = require('@std/class')

-- Structures
local Channel = require("channel")

local WelcomeScreen = {}
WelcomeScreen.prototype = {}
WelcomeScreen.interface = {}

WelcomeScreen.prototype.__type = 'WelcomeScreen'

function WelcomeScreen.prototype.constructor(self: WelcomeScreen, welcomeScreenData: WelscomeScreenData)
    if welcomeScreenData.welcomeChannels then
		for index, value in welcomeScreenData.channels do
			welcomeScreenData.welcomeChannels[index] = Channel.from(self.client, value)
		end
	end

	for index, value in welcomeScreenData do
		(self :: {})[index] = value
	end
end

function WelcomeScreen.interface.new(client: any, welcomeScreenData: WelscomeScreenData): WelcomeScreen
    local self: WelcomeScreen = (class({
        id = welcomeScreenData.id,
        client = client
    }, WelcomeScreen.prototype) :: any) :: WelcomeScreen

    self:constructor(welcomeScreenData)

    return self
end

type WelscomeScreenData = {
    id: string,
    [string]: any
}

export type GuildOnboardingPromptProperties = {
    client: any,
    id: string,
    description: string,
    welcomeChannels: { Channel.Channel }
}

export type WelcomeScreen = typeof(WelcomeScreen.prototype) & GuildOnboardingPromptProperties

return WelcomeScreen.interface