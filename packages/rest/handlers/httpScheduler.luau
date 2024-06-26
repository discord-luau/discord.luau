local Task = require("@std/task")
local Class = require("@std/class")

local Console = require("@deps/console")

local DEFAULT_QUEUE_FREQUENCY = 0

--[=[
	@class HTTPScheduler

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local HTTPScheduler = {}

HTTPScheduler.prototype = {}
HTTPScheduler.interface = {}

HTTPScheduler.prototype.__type = "HTTPScheduler"

function HTTPScheduler.prototype.spawnWorker(self: HTTPScheduler)
	table.insert(
		self.workers,
		Task.spawn(function()
			while true do
				self:cycle()

				Task.wait(self.frequency)
			end
		end)
	)
end

function HTTPScheduler.prototype.stopWorker(self: HTTPScheduler)
	local thread = table.remove(self.workers, 1)

	if not thread then
		return
	end

	Task.cancel(thread)
end

function HTTPScheduler.prototype.setFrequency(self: HTTPScheduler, frequency: number)
	self.frequency = frequency
end

function HTTPScheduler.prototype.cycle(self: HTTPScheduler)
	local item = table.remove(self.stack, 1)

	if not item then
		return
	end

	table.insert(self.processing, true)

	local values = { pcall(item) }

	if not values[1] then
		self.reporter:warn(`HTTP Shceduled call failed: '{values[2]}'`)
	end

	table.remove(self.processing, 1)
end

function HTTPScheduler.prototype.isActive(self: HTTPScheduler)
	return #self.processing > 0
end

function HTTPScheduler.prototype.setLimit(self: HTTPScheduler, limit: number)
	self.limit = limit
end

function HTTPScheduler.prototype.removeTask<T>(self: HTTPScheduler, object: (...T) -> ...T)
	local taskIndex = table.find(self.stack, object)

	if taskIndex then
		table.remove(self.stack, taskIndex)
	end
end

function HTTPScheduler.prototype.addTask<T>(self: HTTPScheduler, object: (...T) -> ...T)
	local thread = coroutine.running()

	table.insert(self.stack, function()
		coroutine.resume(thread, object())
	end)

	return coroutine.yield()
end

function HTTPScheduler.interface.new(threadCount: number?): HTTPScheduler
	local source = Class({
		stack = {},
		processing = {},
		workers = {},

		reporter = Console.new("HTTP Scheduler"),

		limit = nil,
		frequency = DEFAULT_QUEUE_FREQUENCY,
	}, HTTPScheduler.prototype)

	for _ = 1, threadCount or 0 do
        source:spawnWorker()
    end

	return source
end

export type HTTPSchedulerProperties = {
    stack: { () -> () },
	processing: { boolean },
	workers: { thread },

	reporter: Console.Console,

	limit: number?,
	frequency: number,
}

export type HTTPScheduler = HTTPSchedulerProperties & typeof(HTTPScheduler.prototype)

return HTTPScheduler.interface