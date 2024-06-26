local Task = require("@std/task")
local Class = require("@std/class")

local HTTPRatelimit = {}

HTTPRatelimit.prototype = {}
HTTPRatelimit.interface = {}

HTTPRatelimit.prototype.__type = "HTTPRatelimit"

function HTTPRatelimit.prototype.setRemaining(self: HTTPRatelimit, remaining: number)
	self.remaining = remaining
end

function HTTPRatelimit.prototype.resetAfter(self: HTTPRatelimit, seconds: number)
	Task.delay(seconds, function()
		self.remaining = math.min(self.remaining + 1, self.limit)
	end)
end

function HTTPRatelimit.prototype.setLimit(self: HTTPRatelimit, limit: number)
	self.limit = limit
end

function HTTPRatelimit.prototype.isConsumed(self: HTTPRatelimit)
	return self.remaining <= 0
end

function HTTPRatelimit.interface.new(remaining: number?, limit: number?): HTTPRatelimit
	return Class({
		remaining = remaining or 0,
		limit = limit or 0
	}, HTTPRatelimit.prototype)
end

export type HTTPRateLimitProperties = {
	remaining: number,
	limit: number,

	resetAfterThread: thread?
}

export type HTTPRatelimit = HTTPRateLimitProperties & typeof(HTTPRatelimit.prototype)

return HTTPRatelimit.interface