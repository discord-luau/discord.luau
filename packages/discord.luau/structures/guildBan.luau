--!strict

-- Standard Libraries 
local class = require('@std/class')

-- Structures
local User = require('user')

--[=[
	The `GuildBan` class provides a way for developers to interact with guild bans.
]=]
local GuildBan = {}

GuildBan.prototype = {}
GuildBan.interface = {}

GuildBan.prototype.__type = 'GuildBan'

function GuildBan.prototype.constructor(self: GuildBan, client: any, data: { [string]: any })
    if data.user then
        data.user = User.new(client, data.user)
    end

    for key, value in data do
        (self :: {})[key] = value
    end

    return self
end

function GuildBan.interface.new(client: any, data: { [string]: any }): GuildBan
    local self = (class({}, GuildBan.prototype) :: any) :: GuildBan
    self:constructor(client, data)

    return self
end

export type GuildBan = typeof(GuildBan.prototype) & {
    user: User.User,
    reason: string?,
}

return GuildBan.interface
