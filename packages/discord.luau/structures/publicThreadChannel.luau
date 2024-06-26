--!strict

local class = require('@std/class')

-- Structures
local BaseGuildThread = require('@discordluau/discord.luau/structures/baseGuildThread')

local PublicThreadChannel = {}

PublicThreadChannel.prototype = {}
PublicThreadChannel.interface = {}

PublicThreadChannel.prototype.__type = 'PublicThreadChannel'

function PublicThreadChannel.interface.new(
    client: any,
    channelData: ChannelData
): PublicThreadChannel
    return class({ client = client }, PublicThreadChannel.prototype):extend(
        BaseGuildThread.new(client, channelData)
    ) :: PublicThreadChannel
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type PublicThreadChannel = BaseGuildThread.BaseGuildThread
 & typeof(PublicThreadChannel.prototype) & {
    client: any,
}

return PublicThreadChannel.interface
