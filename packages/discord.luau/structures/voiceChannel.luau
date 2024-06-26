--!strict

-- Standard Libraries
local class = require('@std/class')

-- Structures
local BaseGuildVoiceChannel = require('@discordluau/discord.luau/structures/baseGuildVoiceChannel')

local VoiceChannel = {}

VoiceChannel.prototype = {}
VoiceChannel.interface = {}

VoiceChannel.prototype.__type = 'VoiceChannel'

function VoiceChannel.interface.new(client: any, channelData: ChannelData): VoiceChannel
    return class({ client = client }, VoiceChannel.prototype):extend(
        BaseGuildVoiceChannel.new(client, channelData)
    ) :: VoiceChannel
end

type ChannelData = {
    id: string,
    guildId: string,
}

export type VoiceChannel =
    BaseGuildVoiceChannel.BaseGuildVoiceChannel
    & typeof(VoiceChannel.prototype)
    & {
        client: any,
    }

return VoiceChannel.interface
