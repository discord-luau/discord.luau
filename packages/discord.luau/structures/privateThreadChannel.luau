--!strict

local class = require('@std/class')

-- Structures
local BaseGuildThread = require('@discordluau/discord.luau/structures/baseGuildThread')

local PrivateThreadChannel = {}

PrivateThreadChannel.prototype = {}
PrivateThreadChannel.interface = {}

PrivateThreadChannel.prototype.__type = 'PrivateThreadChannel'

function PrivateThreadChannel.interface.new(
    client: any,
    channelData: ChannelData
): PrivateThreadChannel
    return class({ client = client }, PrivateThreadChannel.prototype):extend(
        BaseGuildThread.new(client, channelData)
    ) :: PrivateThreadChannel
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type PrivateThreadChannel = BaseGuildThread.BaseGuildThread
 & typeof(PrivateThreadChannel.prototype) & {
    client: any,
}

return PrivateThreadChannel.interface
