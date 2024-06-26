local Class = require("@std/class")
local Array = require('@deps/polyfill/array')
local Map = require('@deps/polyfill/map/map')

type Map<K, V> = Map.Map<K, V>
type Array<T> = Array.Array<T>

local Collection = {}
Collection.interface = {}
Collection.prototype = {}
Collection.prototype.__type = 'Collection'

function Collection.prototype.ensure<K, V>(
    self: Collection<K, V>,
    key: K,
    defaultValueGenerator: (key: K, collection: Collection<K, V>) -> V
): V
    if self:has(key) then
        return self:get(key) :: V
    end

    if typeof(defaultValueGenerator) ~= 'function' then
        error(`{defaultValueGenerator} is not a function`)
    end

    local defaultValue = defaultValueGenerator(key, self)
    self:set(key, defaultValue)
    return defaultValue
end

function Collection.prototype.get<K, V>(self: Collection<K, V>, key: K): V? 
    return self._map[key]
end

function Collection.prototype.set<K, V>(self: Collection<K, V>, key: K, value: V): Collection<K, V>
     -- preserve initial insertion order
     if self._map[key] == nil then
        -- Luau FIXME: analyze should know self is Map<K, V> which includes size as a number
        self.size = self.size :: number + 1
        table.insert(self._array, key)
    end
    -- always update value
    self._map[key] = value
    return self
end

function Collection.prototype.last<K, V>(self: Collection<K, V>, amount: number?): V | Array<V> | nil
    local iterator = Array.from(self:values())
    if not amount then
        return Array.at(iterator, -1)
    end

    if amount < 0 then
        return self:first(amount * -1)
    end

    return Array.slice(iterator, -amount)
end

function Collection.prototype.first<K, V>(self: Collection<K, V>, amount: number?): V | Array<V> | nil
    if amount == nil then
        local k, v = next(self:values())
        return k and v or nil
    end

    if amount < 0 then
        return self:last(amount * -1)
    end

    amount = math.min(self.size, amount)
    local iter = self:values()
    return Array.from(iter, function()
        local key, value = next(iter)
        return value
    end) :: Array<V>
end

function Collection.prototype.find<K, V>(
    self: Collection<K, V>,
    fn: (
        value: V,
        key: K,
        collection: Collection<K, V>
    ) -> unknown,
    thisArg: unknown?
): V?
    if typeof(fn) ~= 'function' then
        error(`{fn} is not a function`)
    end

    for key, val in self._map :: any do
        if fn(val, key, self) then
            return val
        end
    end

    return nil
end

function Collection.prototype.filter<K, V>(self: Collection<K, V>, fn: (value: V, key: K, collection: Collection<K, V>) -> unknown): Collection<K, V>
    if typeof(fn) ~= "function" then
        error(`{fn} is not a function`)
    end

    local results = Collection.interface.new()
    for key, val in self._map :: any do
        if fn(val, key, self) then
            results:set(key, val)
        end
    end

    return results
end

function Collection.prototype.toArray<K, V>(self: Collection<K, V>): Array<V>
    return Array.from(self:values()) :: Array<V>
end

function Collection.interface.new<K, V>(iterable: (Array<Array<any>> | Map<K, V>)?): Collection<K, V>
    return Class({}, Collection.prototype):extend(Map.new(iterable))
end

export type Collection<K, V> = typeof(Collection.prototype) & Map<K, V>

return Collection.interface