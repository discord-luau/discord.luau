--!strict

-- Standard Libraries
local class = require('@std/class')

-- Structures
local BaseGuildVoiceChannel = require('@discordluau/discord.luau/structures/baseGuildVoiceChannel')

local StageChannel = {}

StageChannel.prototype = {}
StageChannel.interface = {}

StageChannel.prototype['_type'] = 'StageChannel'

function StageChannel.interface.new(client: any, channelData: ChannelData): StageChannel
    return class({ client = client }, StageChannel.prototype):extend(
        BaseGuildVoiceChannel.new(client, channelData)
    ) :: StageChannel
end

type ChannelData = {
    id: string,
    guildId: string,
}

export type StageChannel =
    BaseGuildVoiceChannel.BaseGuildVoiceChannel
    & typeof(StageChannel.prototype)
    & {
        client: any,
    }

return StageChannel.interface
