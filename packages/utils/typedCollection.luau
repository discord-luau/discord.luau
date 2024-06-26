--!strict

-- Standard Libraries
local Class = require("@std/class")

-- Dependencies
local Console = require("@deps/console")

-- Utilities
local Collection = require("@discordluau/utils/collection")

local Reporter = Console.new('Typed Collection')

-- Class
local TypedCollection = {}
TypedCollection.interface = {}
TypedCollection.prototype = {}
TypedCollection.prototype.__type = 'TypedCollection'

function TypedCollection.prototype.delete<T>(self: TypedCollection<string, T>, key: string)
    return self.super:delete(key)
end

function TypedCollection.prototype.set<T>(self: TypedCollection<string, T>, key: string, value: T): ()
    return self.super:set(key, value)
end

function TypedCollection.prototype.get<T>(self: TypedCollection<string, T>, key: string): T?
    return self.super:get(key)
end

function TypedCollection.prototype._add<T>(self: TypedCollection<string, T>, value: T): T
    if (value :: any).id then
        self:set((value :: any).id, value)

        return value
    else
        local err = error(`TypedCollection: #add: value must have an id property`)
        Reporter:error('TypedCollection#add: value must have an id property')

        return value
    end 
end

function TypedCollection.prototype.update<T, V>(self: TypedCollection<string, T>, id: string, ...: V)
    if self:get(id) then
        return self:get(id) :: T
    end

    local func = (self._baseObject :: any).new or (self._baseObject :: any).from


    local object = func(...) :: T 
    self:_add(object)

    return object
end

function TypedCollection.prototype.fetch<T>(self: TypedCollection<string, T>, id: string, callback: () -> T): T
    local object = self:get(id) :: T

    if not object then
        object = callback()
        self:_add(object :: any)
    end

    return object
end

function TypedCollection.interface.new<V>(baseObject: V, client: any): TypedCollection<string, V>
    return Class({ _baseObject = baseObject, client = client }, TypedCollection.prototype):extend(Collection.new()) :: TypedCollection<string, V>
end

export type ExtraOptions<M, E, C> = {
    construct: (self: any, data: M, ...E) -> C,
    delete: (self: any, key: string) -> ()
}

export type TypedCollection<string, V> = typeof(TypedCollection.prototype) & Collection.Collection<string, V> & {
    super: Collection.Collection<string, V>
} & {
    _baseObject: V,
    client: any
}

return TypedCollection.interface