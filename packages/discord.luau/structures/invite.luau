--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Future = require('@deps/future')

-- REST
local RestAPI = require('@discordluau/api/rest')
local Routes = RestAPI.Routes

--[=[
	@class Invite

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local Invite = {}

Invite.prototype = {}
Invite.interface = {}

Invite.prototype.__type = 'Invite'

function Invite.prototype.delete(self: Invite)
    return Future.try(function()
        return self.client.rest:delete(Routes.invite(self.code))
    end)
end

function Invite.prototype.constructor(self: Invite, inviteData: InviteData)
    if inviteData then
        for index, value in inviteData do
            (self :: any)[index] = value
        end
    end
end

function Invite.interface.new(client: any, inviteData: InviteData): Invite
    local self = (class({
        client = client,
    }, Invite.prototype) :: any) :: Invite

    self:constructor(inviteData)

    return self
end

type InviteData = {
    code: string,
}

export type Invite = typeof(Invite.prototype) & {
    client: any,
    code: string,
}

return Invite.interface
