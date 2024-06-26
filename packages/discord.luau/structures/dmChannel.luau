--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local BaseUserChannel = require('baseUserChannel')

local DMChannel = {}

DMChannel.prototype = {}
DMChannel.interface = {}

DMChannel.prototype.__type = 'DMChannel'

function DMChannel.interface.new(client: any, channelData: ChannelData): DMChannel
    return class({ client = client }, DMChannel.prototype):extend(
        BaseUserChannel.new(client, channelData)
    ) :: DMChannel
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type DMChannelProperties = {
    client: any,
}

export type DMChannel =
    BaseUserChannel.BaseUserChannel
    & typeof(DMChannel.prototype)
    & DMChannelProperties

return DMChannel.interface
