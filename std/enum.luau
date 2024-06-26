--!strict

local Enumeration = {}
Enumeration.prototype = {}

export type EnumerationItems<S> = S & typeof(Enumeration.prototype) 

export type Enumeration = typeof(setmetatable({} :: typeof(Enumeration), {} :: {
	__call: <S, K>(_: K, name: string, items: S) -> EnumerationItems<S>
}))

function Enumeration.prototype.is<S>(self: EnumerationItems<S>, item: any)
	for _, value in self :: any do
		if item == value then
			return true
		end
	end

	return false
end

function Enumeration.prototype.ToString<S>(self: EnumerationItems<S>): string
	return getmetatable(self :: any)['__type']
end

function Enumeration.new<S>(name: string, items: S): EnumerationItems<S>
	return setmetatable(items :: any, {
		__index = Enumeration.prototype,
		__type = `enumeration.{name}`,
		__iter = function(...)
			return next, ...
		end,
		__tostring = function(self)
			return self:ToString()
		end,
	}) :: any
end

return setmetatable(Enumeration, {
	__call = function<S, K>(_: K, name: string, items: S): EnumerationItems<S>
		return Enumeration.new(name, items) :: EnumerationItems<S>
	end
}) :: Enumeration