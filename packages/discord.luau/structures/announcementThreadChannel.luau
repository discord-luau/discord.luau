--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local BaseGuildThread = require('@discordluau/discord.luau/structures/baseGuildThread')

local AnnouncementThreadChannel = {}

AnnouncementThreadChannel.prototype = {}
AnnouncementThreadChannel.interface = {}

AnnouncementThreadChannel.prototype.__type = 'AnnouncementThreadChannel'

function AnnouncementThreadChannel.interface.new(
    client: any,
    channelData: ChannelData
): AnnouncementThreadChannel
    return class({ client = client }, AnnouncementThreadChannel.prototype):extend(
        BaseGuildThread.new(client, channelData)
    ) :: AnnouncementThreadChannel
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type AnnouncementThreadChannel = BaseGuildThread.BaseGuildThread
 & typeof(AnnouncementThreadChannel.prototype) & {
    client: any,
}

return AnnouncementThreadChannel.interface
