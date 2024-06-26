local Enumeration = {}

Enumeration.Type = "Enumeration"

Enumeration.interface = {}
Enumeration.prototype = {}

function Enumeration.prototype:Is(item)
	for _, value in self do
		if item == value then
			return true
		end
	end

	return false
end

function Enumeration.prototype:Assert(item)
	assert(self:Is(item), `EnumItem is invalid!`)
end

function Enumeration.prototype:ToString()
	return `{Enumeration.Type}<"{getmetatable(self)['__meta']}">`
end

function Enumeration.interface.new<S>(name: string, items: S): S & typeof(Enumeration.prototype) 
	return setmetatable(items :: any, {
		__index = Enumeration.prototype,
		__type = `{Enumeration.Type}.{name}`,
		__meta = name,
		__iter = function(...)
			return next, ...
		end,
		__tostring = function(self)
			return self:ToString()
		end,
	})
end

export type Enumeration<S> = S & typeof(Enumeration.prototype)


return setmetatable(Enumeration.interface, {
	__call = function<S>(t, name: string, items: S): S & typeof(Enumeration.prototype)
		return t.new(name, items) :: S & typeof(Enumeration.prototype) 
	end
})