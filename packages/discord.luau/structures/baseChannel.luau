--!strict

-- Modules
local class = require("@std/class")

-- Dependencies
local Future = require("@deps/future")

-- API
local RESTApi = require("@discordluau/api/rest")

-- Enumerations
local Routes = RESTApi.Routes

local BaseChannel = {}
BaseChannel.prototype = {}
BaseChannel.interface = {}
BaseChannel.prototype.__type = "BaseChannel"

function BaseChannel.prototype.delete(self: BaseChannel)
    return Future.try(function()
        return self.client.rest:delete(Routes.channel(self.id))
	end)
end

function BaseChannel.prototype.constructor(self: BaseChannel, data: ChannelData)
    for key, value in data do
        (self :: any)[key] = value
    end
end

function BaseChannel.interface.new(client: any, channelData: ChannelData): BaseChannel
    local self = (class({ client = client }, BaseChannel.prototype) :: any) :: BaseChannel

    self:constructor(channelData)

    return self
end


export type ChannelData = {
    id: string,
    [any]: any
}

export type BaseChannel = typeof(BaseChannel.prototype) & {
	client: any,

	id: string,
	type: number,
}

return BaseChannel.interface