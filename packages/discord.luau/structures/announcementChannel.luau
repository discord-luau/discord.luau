--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local BaseGuildTextChannel = require('@discordluau/discord.luau/structures/baseGuildTextChannel')

local AnnouncementChannel = {}

AnnouncementChannel.prototype = {}
AnnouncementChannel.interface = {}

AnnouncementChannel.prototype.__type = 'AnnouncementChannel'

function AnnouncementChannel.interface.new(
    client: any,
    channelData: ChannelData
): AnnouncementChannel
    return class({ client = client }, AnnouncementChannel.prototype):extend(
        BaseGuildTextChannel.new(client, channelData)
    ) :: AnnouncementChannel
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type AnnouncementChannel =
    BaseGuildTextChannel.BaseGuildTextChannel
    & typeof(AnnouncementChannel.prototype)
    & {
        client: any,
    }

return AnnouncementChannel.interface
