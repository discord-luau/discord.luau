--!strict

local class = require('@std/class')

-- Structures
local BaseGuildTextChannel = require('@discordluau/discord.luau/structures/baseGuildTextChannel')

local TextChannel = {}

TextChannel.prototype = {}
TextChannel.interface = {}

TextChannel.prototype.__type = 'TextChannel'

function TextChannel.interface.new(client: any, channelData: ChannelData): TextChannel
    return class({ client = client }, TextChannel.prototype):extend(
        BaseGuildTextChannel.new(client, channelData)
    ) :: TextChannel
end

type ChannelData = {
    id: string,
    guildId: string,
}

export type TextChannel = BaseGuildTextChannel.BaseGuildTextChannel & typeof(TextChannel.prototype) & {
    client: any,
}

return TextChannel.interface
