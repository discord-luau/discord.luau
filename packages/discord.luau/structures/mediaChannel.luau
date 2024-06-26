--!strict

-- Standard Libraries
local class = require('@std/class')

-- Structures
local BaseChannel = require('baseChannel')

local MediaChannel = {}

MediaChannel.prototype = {}
MediaChannel.interface = {}

MediaChannel.prototype.__type = 'MediaChannel'

function MediaChannel.prototype.constructor(self: MediaChannel, channelData: ChannelData)
    self.defaultForumLayout = channelData.defaultForumLayout
end

function MediaChannel.interface.new(client: any, channelData: ChannelData): MediaChannel
    local self = (class({ client = client }, MediaChannel.prototype):extend(
        BaseChannel.new(client, channelData)
    ) :: any) :: MediaChannel

    self:constructor(channelData)

    return self
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type MediaChannel = BaseChannel.BaseChannel & typeof(MediaChannel.prototype) & {
    client: any,
    defaultForumLayout: number,
}

return MediaChannel.interface
