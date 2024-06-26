--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local BaseGuildTextChannel = require('baseGuildTextChannel')

local DirectoryChannel = {}

DirectoryChannel.prototype = {}
DirectoryChannel.interface = {}

DirectoryChannel.prototype.__type = 'DirectoryChannel'

function DirectoryChannel.interface.new(client: any, channelData: ChannelData): DirectoryChannel
    return class({ client = client }, DirectoryChannel.prototype):extend(
        BaseGuildTextChannel.new(client, channelData)
    ) :: DirectoryChannel
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type DirectoryChannel =
    BaseGuildTextChannel.BaseGuildTextChannel
    & typeof(DirectoryChannel.prototype)
    & {
        client: any,
    }

return DirectoryChannel.interface
