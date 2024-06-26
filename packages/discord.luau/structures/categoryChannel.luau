--!strict

-- Standard Libraries
local class = require('@std/class')

-- Structures
local BaseChannel = require('baseChannel')

local CategoryChannel = {}

CategoryChannel.prototype = {}
CategoryChannel.interface = {}

CategoryChannel.prototype.__type = 'CategoryChannel'

function CategoryChannel.interface.new(client: any, channelData: ChannelData): CategoryChannel
    return class({ client = client }, CategoryChannel.prototype):extend(
        BaseChannel.new(client, channelData)
    )
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type CategoryChannel = BaseChannel.BaseChannel & typeof(CategoryChannel.prototype) & {
    client: any,
}

return CategoryChannel.interface
