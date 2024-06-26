-- Standard Libraries
local Task = require("@std/task")
local class = require("@std/class")

local EndpointCacheManager = {}

EndpointCacheManager.prototype = {}
EndpointCacheManager.interface = {}

EndpointCacheManager.prototype.__type = "EndpointCacheManager"

function EndpointCacheManager.prototype.setExpiry(self: EndpointCacheManager, seconds: number)
	self.expiry = seconds
end

function EndpointCacheManager.prototype.set(self: EndpointCacheManager, value: any)
	self.data = value

	if self.expiryThread then
		Task.cancel(self.expiryThread)
	end

	self.expiryThread = Task.spawn(function()
		Task.wait(self.expiry)

		self.data = nil
		self.expiryThread = nil
	end)
end

function EndpointCacheManager.prototype.get(self: EndpointCacheManager)
	return self.data
end

function EndpointCacheManager.interface.new(expiryTime: number?): EndpointCacheManager
	return class({
		expiry = expiryTime or 5
	}, EndpointCacheManager.prototype) :: EndpointCacheManager
end

export type EndpointCacheManager = typeof(EndpointCacheManager.prototype) & {
	expiry: number,

	data: any?,
	expiryThread: thread?
}

return EndpointCacheManager.interface