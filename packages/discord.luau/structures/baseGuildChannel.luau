--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')

-- Builders Class
local ChannelBuilder = require('@discordluau/builders/channel')

-- Core Package Utilities
local PermissionsBitField = require('../utils/permissionsBitField')

-- Structures
local BaseChannel = require('baseChannel')
local Invite = require('invite')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes

local BaseGuildChannel = {}
BaseGuildChannel.prototype = {}
BaseGuildChannel.interface = {}
BaseGuildChannel.prototype.__type = 'BaseGuildChannel'

function BaseGuildChannel.prototype.edit(
    self: BaseGuildChannel,
    channelBuilder: ChannelBuilder.ChannelBuilder
)
    return Future.try(function()
        return self.client.rest:patch(Routes.channel(self.id), channelBuilder:toJSON())
    end)
end

function BaseGuildChannel.prototype.overwriteRolePermissions(
    self: BaseGuildChannel,
    roleId: string,
    allowedPermissions: PermissionsBitField.PermissionsBitField,
    disallowedPermissions: PermissionsBitField.PermissionsBitField
)
    return Future.try(function()
        return self.client.rest:put(Routes.channelPermission(self.id, roleId), {
            allow = allowedPermissions:getValue(),
            deny = disallowedPermissions:getValue(),
            type = 0,
        })
    end)
end

function BaseGuildChannel.prototype.overwriteMemberPermissions(
    self: BaseGuildChannel,
    memberId: string,
    allowedPermissions: PermissionsBitField.PermissionsBitField,
    disallowedPermissions: PermissionsBitField.PermissionsBitField
)
    return Future.try(function()
        return self.client.rest:put(Routes.channelPermission(self.id, memberId), {
            allow = allowedPermissions:getValue(),
            deny = disallowedPermissions:getValue(),
            type = 1,
        })
    end)
end

function BaseGuildChannel.prototype.deletePermissionOverwrite(
    self: BaseGuildChannel,
    roleIdOrUserId: string
)
    return Future.try(function()
        return self.client.rest:delete(Routes.channelPermission(self.id, roleIdOrUserId))
    end)
end

function BaseGuildChannel.prototype.getInvites(self: BaseGuildChannel)
    return Future.try(function()
        local invites = self.client.rest:get(Routes.channelInvites(self.id))

        for index, inviteData in invites do
            invites[index] = Invite.new(self.client, inviteData)
        end

        return invites
    end)
end

function BaseGuildChannel.prototype.createInvite(
    self: BaseGuildChannel,
    maxAge: number?,
    maxUses: number?,
    temporary: boolean?
)
    return Future.try(function()
        local inviteData = self.client.rest:post(Routes.channelInvites(self.id), {
            {
                max_age = maxAge,
                max_uses = maxUses,
                temporary = temporary,
            },
        })

        return Invite.new(self.client, inviteData) :: Invite.Invite
    end)
end

function BaseGuildChannel.prototype.setPosition(
    self: BaseGuildChannel,
    position: number,
    parentId: string?,
    syncPermissions: boolean?
)
    return Future.try(function()
        return self.client.rest:patch(Routes.channelPosition(self.id), {
            id = self.id,
            position = position,
            parent_id = parentId,
            lock_permissions = syncPermissions,
        })
    end)
end

-- Aliases
BaseGuildChannel.prototype.modify = BaseGuildChannel.prototype.edit

function BaseGuildChannel.prototype.constructor(self: BaseGuildChannel, data: ChannelData)
    for key, value in data do
        (self :: any)[key] = value
    end
end

function BaseGuildChannel.interface.new(client: any, channelData: ChannelData): BaseGuildChannel
    local self = (
        class({ client = client }, BaseGuildChannel.prototype):extend(
            BaseChannel.new(client, channelData)
        ) :: any
    ) :: BaseGuildChannel

    self:constructor(channelData)

    return self
end

export type ChannelData = {
    id: string,
    guildId: string?,
}

export type BaseGuildChannelProperties = {
    guildId: string,
}

export type BaseGuildChannel =
    typeof(BaseGuildChannel.prototype)
    & BaseGuildChannelProperties
    & BaseChannel.BaseChannel

return BaseGuildChannel.interface
