--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local BaseChannel = require("@discordluau/discord.luau/structures/baseChannel")

--[=[
	@class Objects.ForumChannel
]=]
local ForumChannel = {}

ForumChannel.prototype = {}
ForumChannel.interface = {}

ForumChannel.prototype.__type = "ForumChannel"

function ForumChannel.prototype.constructor(self: ForumChannel, channelData: ChannelData)
    self.defaultSortOrder = channelData.defaultSortOrder
end

function ForumChannel.interface.new(
	client: any,
	channelData: ChannelData 
): ForumChannel
    local self = (class({ client = client }, ForumChannel.prototype):extend(BaseChannel.new(client, channelData)) :: any) :: ForumChannel
    self:constructor(channelData)

    return self
end

type ChannelData = {
    id: string,
    guildId: string,
    [string]: any,
}

export type ForumChannel = BaseChannel.BaseChannel & typeof(ForumChannel.prototype) & {
	client: any,
    defaultSortOrder: number
}

return ForumChannel.interface