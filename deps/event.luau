--!strict

local Event = {}
local Connection = {}

local function connect(event, fn)
	local connection = {
		event = event,
		callback = fn
	}

	event.connections[connection :: any] = true

	function connection.disconnect()
		connection.event = nil :: any
	end

	return connection
end

function Connection.new<T...>(event, fn: (T...) -> ())
	local connection = {
		event = event,
		callback = fn
	}

	event.connections[connection] = true

	function connection.disconnect()
		connection.event = nil :: any
	end

	return connection
end

function Event.new(): Event<...any>
	local event = {
		connections = {}
	}

	function event.on(fn)
		local connection = connect(event, fn)
		return connection
	end

	function event.once<T...>(fn)
		local done = false
		local cn
		cn = event.on(function(...)
			if done then
				return
			end
			done = true
			cn.disconnect()
			fn(...)
		end)

		return cn
	end

	function event.yield(): ...any
		local thread = coroutine.running()
		local cn
		cn = event.on(function(...)
			cn.disconnect()
			task.spawn(thread, ...)
		end)

		return coroutine.yield()
	end

	function event.emit(...)
		if next(event.connections) then
			for cn in event.connections do
				(cn :: any).callback(...)
			end
		end
	end

	function event.disconnectAll()
		table.clear(event.connections)
		table.clear(event)
	end

	return event :: any
end

export type Event<T...> = {
	emit: (T...) -> (),
	yield: () -> T...,
	on: ((T...) -> ()) -> Connection,
	once: ((T...) -> ()) -> Connection,
	disconnectAll: () -> (),
	connections: { [Connection]: boolean },
}
export type Connection = {
	disconnect: () -> ()
}

return Event :: { new: () -> Event<...any>}