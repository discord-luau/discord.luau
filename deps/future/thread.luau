local Task = require("@std/task")

local Thread = {}
Thread.__index = Thread

function Thread.new(): Thread
	return setmetatable({
		free = {}
	}, Thread)
end

function Thread.spawn<T...>(self: Thread, callback: (T...) -> (), ...: T...)
	local Thread
	if #self.free > 0 then
		Thread = self.free[#self.free]
		self.free[#self.free] = nil
	else
		Thread = coroutine.create(function()
			self:_yielder()
		end)
		coroutine.resume(Thread)
	end

	Task.spawn(Thread, callback, Thread, ...)
end

function Thread._yielder(self: Thread)
	while true do
		self:_runner(coroutine.yield())
	end
end

function Thread._runner(self: Thread, callback, thread, ...)
	callback(...)
	table.insert(self.free, thread)
end

export type Thread = typeof(setmetatable({} :: {
	free: { thread }
}, Thread))

return Thread