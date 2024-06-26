--!strict

-- Standard Libraries
local class = require("@std/class")

--[=[
	@class WebSocketBuffer
]=]
local WebSocketBuffer = {}

WebSocketBuffer.prototype = {}
WebSocketBuffer.interface = {}

WebSocketBuffer.prototype.__type = "WebSocketBuffer"

function WebSocketBuffer.prototype.flush(self: WebSocketBuffer)
	local data = self.data

	self.data = ""

	return data
end

function WebSocketBuffer.prototype.add(self: WebSocketBuffer, data: string)
	self.data ..= data
end

function WebSocketBuffer.interface.new(): WebSocketBuffer
	return class({
		data = ""
	}, WebSocketBuffer.prototype) :: WebSocketBuffer
end

export type WebSocketBuffer = typeof(WebSocketBuffer.prototype) & {
	data: string
}

return WebSocketBuffer.interface