--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Future = require('@deps/future')

-- Structures
local ApplicationCommand = require('applicationCommand')
local User = require('user')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes

local Integration = {}

Integration.interface = {}
Integration.prototype = {}

Integration.prototype.__type = 'Integration'

function Integration.prototype.delete(self: Integration)
    return Future.try(function()
        return self.client.rest:delete(Routes.guildIntegration(self.guildId, self.id))
    end)
end

function Integration.prototype.constructor(self: Integration, integrationData: RawIntegrationData)
    if integrationData.user then
        integrationData.user = User.new(self.client, integrationData.user)
    end

    if integrationData.application then
        integrationData.application =
            ApplicationCommand.new(self.client, integrationData.application)
    end

    for index, value in integrationData do
        (self :: {})[index] = value
    end
end

function Integration.interface.new(
    client: any,
    guildId: string,
    integrationData: RawIntegrationData
): Integration
    local self = (class({ client = client, guildId = guildId }, Integration.prototype) :: any) :: Integration

    self:constructor(integrationData)

    return self
end

type RawIntegrationData = {
    id: string,
    [string]: any,
}

export type Integration = typeof(Integration.prototype) & {
    client: any,
    guildId: string,

    id: string,
    name: string,
    type: string,
    enabled: boolean,
    syncing: boolean?,
    roleId: string?,
    enableEmoticons: boolean?,
    expireBehaviour: number?,
    expireGracePeriod: number?,
    user: User.User?,
    account: { id: string, name: string }?,
    syncedAt: string?,
    subscriberCount: number?,
    revoked: boolean?,
    application: ApplicationCommand.ApplicationCommand?,
    scopes: { string }?,
}

return Integration.interface
