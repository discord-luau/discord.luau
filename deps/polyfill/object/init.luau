local Class = require("@std/class")
local Table = require("@deps/table")

local Object = {}
Object.prototype = {}
Object.interface = {
	assign = require("./assign"),
	entries = require("./entries"),
	freeze = require("./freeze"),
	is = require("./is"),
	isFrozen = require("./isFrozen"),
	hasOwn = require("./hasOwn"),
	keys = require("./keys"),
	preventExtensions = require("./preventExtensions"),
	seal = require("./seal"),
	values = require("./values"),
	None = require("./none"),
}
Object.prototype.__type = 'Object'

function Object.prototype.keyOf<K, V>(self: Object<K, V>): { K }
	local keys: { K } = {}
	for key in self :: { [K]: V } do
		table.insert(keys, key)	
	end
	return keys
end

function Object.prototype.valueOf<K, V>(self: Object<K, V>): { V }
	local values: { V } = {}
	for _, value in self :: { [K]: V } do
		table.insert(values, value)	
	end
	return values
end


function Object.prototype.toRaw<K, V>(self: Object<K, V>): { [K]: V }
	local obj: { [K]: V } = {}

	for key, value in self :: { [K]: V } do
		obj[key] = value
	end

	return obj
end

function Object.prototype.constructor<K, V>(self: Object<K, V>, data: { [K]: V }?)
	if data then
		for key, value in data do
			(self :: any)[key] = value
		end
	end
end

function Object.prototype.toString<K, V>(self: Object<K, V>)
	return Table.repr(self)
end

function Object.interface.create<K, V>(data: { [K]: V }?): Object<K, V>
	data = data or {}
	local self = Class({}, Object.prototype)
	self:constructor(data)

	return self
end

export type Object<K, V> = typeof(Object.prototype) & { [K]: V }


return setmetatable(Object.interface, {
	__call = function<K, V>(_, data: { [K]: V}?): Object<K, V>
		return Object.interface.create(data)
	end
}) 