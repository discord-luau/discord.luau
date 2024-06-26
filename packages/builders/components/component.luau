
--!strict

-- Standard Libraries 
local class = require("@std/class")

-- API
local ChannelApi = require("@discordluau/api/payloads/channel")


type APIBaseComponent = ChannelApi.APIBaseComponent

local ComponentBuilder = {}

ComponentBuilder.interface = {}
ComponentBuilder.prototype = {}

ComponentBuilder.prototype.__type = "ComponentBuilder"

function ComponentBuilder.prototype.toJSON<T>(self: ComponentBuilder<T>): T
    return self.data 
end

function ComponentBuilder.interface.new<T>(data: T): ComponentBuilder<T>
	return class({
        data = data,
	}, ComponentBuilder.prototype)
end

export type ComponentBuilder<T> = typeof(ComponentBuilder.prototype) & {
    data: T
} 

return ComponentBuilder.interface