--!strict

-- Standard Libraries
local class = require('@std/class')

-- Structures
local Channel = require("@discordluau/discord.luau/structures/channel")
local User = require("@discordluau/discord.luau/structures/user")

local Widget = {}
Widget.prototype = {}
Widget.interface = {}

Widget.prototype.__type = 'Widget'

function Widget.prototype.constructor(self: Widget, widgetInformation: WidgetInformation)
    if widgetInformation.channels then
		for index, value in widgetInformation.channels do
			widgetInformation.channels[index] = Channel.from(self.client, value)
		end
	end

	if widgetInformation.members then
		for index, value in widgetInformation.members do
			widgetInformation.channels[index] = User.new(self.client, value)
		end
	end

	for index, value in widgetInformation do
		(self :: {})[index] = value
	end
end

function Widget.interface.new(client: any, widgetInformation: WidgetInformation): Widget
    local self: Widget = (class({
        id = widgetInformation.id,
        client = client
    }, Widget.prototype) :: any) :: Widget

    self:constructor(widgetInformation)

    return self
end

type WidgetInformation = {
    id: string,
    [string]: any
}

export type GuildOnboardingPromptProperties = {
    client: any,
    id: string,
    name: string,
	instantInvite: string?,
	channels: { Channel.Channel },
	members: { User.User },
	presenceCount: number,
}

export type Widget = typeof(Widget.prototype) & GuildOnboardingPromptProperties

return Widget.interface