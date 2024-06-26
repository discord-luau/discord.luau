--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Future = require("@deps/future")

-- Builders
local ChannelBuilder = require('@discordluau/builders/channel')

-- Structures
local BaseUserChannel = require('baseUserChannel')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes

local GroupChannel = {}

GroupChannel.prototype = {}
GroupChannel.interface = {}

GroupChannel.prototype.__type = 'GroupChannel'

function GroupChannel.prototype.edit(
    self: GroupChannel,
    channelBuilder: ChannelBuilder.ChannelBuilder
)
    return Future.try(function()
        return self.client.rest:patch(Routes.channel(self.id), channelBuilder:toJSON())
    end)
end

-- Aliases
GroupChannel.prototype.modify = GroupChannel.prototype.edit

function GroupChannel.interface.new(client: any, channelData: ChannelData): GroupChannel
    return (class({ client = client }, GroupChannel.prototype):extend(
        BaseUserChannel.new(client, channelData)
    ) :: any) :: GroupChannel
end

type ChannelData = {
    id: string,
    [string]: any,
}

export type GroupChannelProperties = {
    client: any,
    icon: string,
    ownerId: string,
    applicationId: string,

    managed: boolean,
}

export type GroupChannel =
    BaseUserChannel.BaseUserChannel
    & typeof(GroupChannel.prototype)
    & GroupChannelProperties

return GroupChannel.interface
