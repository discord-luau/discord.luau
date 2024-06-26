--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')

-- Builders
local RoleBuilder = require('@discordluau/builders/guilds/role')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes


--[=[
	@class Role

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local Role = {}

Role.prototype = {}
Role.interface = {}

Role.prototype.__type = 'Role'

function Role.prototype.delete(self: Role)
    return Future.try(function()
        return self.client.rest:delete(Routes.guildRole(self.guildId, self.id))
    end)
end

function Role.prototype.updatePosition(self: Role, position: number)
    return Future.try(function()
        return self.client.rest:patch(
            Routes.guildRoles(self.guildId),
            {
                id = self.id,
                position = position,
            } 
        )
    end)
end

function Role.prototype.edit(self: Role, roleBuilder: RoleBuilder.RoleBuilder)
    return Future.try(function()
        return self.client.rest:patch(Routes.guildRole(self.guildId, self.id), roleBuilder:toJSON())
    end)
end

-- Aliases
Role.prototype.modify = Role.prototype.edit

function Role.prototype.constructor(self: Role, guildId: string, roleData: RoleData)
    for index, value in roleData do
        (self :: any)[index] = value
    end

    self.guildId = guildId
end

function Role.interface.new(client: any, guildId: string, roleData: RoleData): Role
    local self = (class({ client = client }, Role.prototype) :: any) :: Role

    self:constructor(guildId, roleData)

    return self
end

type RoleData = {
    id: string,
    name: string,
    permissions: string,
    position: number,
    color: number,
    hoist: boolean,
    managed: boolean,
    mentionable: boolean,
}

export type Role = typeof(Role.prototype) & {
    client: any,
    guildId: string,

    id: string,
    name: string,
    permissions: string,
    position: number,
    color: number,
    hoist: boolean,
    managed: boolean,
    mentionable: boolean,
}

return Role.interface
