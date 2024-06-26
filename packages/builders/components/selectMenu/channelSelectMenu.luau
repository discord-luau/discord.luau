-- Standard Libraries 
local class = require("@std/class")
local enum = require("@std/enum")

-- Dependencies
local Table = require("@deps/table")

-- Internal Utilities
local normalizeArray = require('../../utils/normalizeArray')

-- API
local ChannelAPI = require('@discordluau/api/payloads/channel')

-- Builders 
local BaseSelectMenuBuilder = require('baseSelectMenu')

type RestOrArray<Type> = normalizeArray.RestOrArray<Type>
type APIChannelSelectComponent = ChannelAPI.APIChannelSelectComponent

local ChannelSelectMenuBuilder = {}

ChannelSelectMenuBuilder.interface = {}
ChannelSelectMenuBuilder.prototype = {}

ChannelSelectMenuBuilder.prototype.__type = 'ChannelSelectMenuBuilder'

function ChannelSelectMenuBuilder.prototype.setChannelTypes(
    self: ChannelSelectMenuBuilder,
    ...: RestOrArray<number>
): ChannelSelectMenuBuilder
    local normalizedTypes = normalizeArray({ ... })
    self.data.channel_types = normalizedTypes

    return self
end

function ChannelSelectMenuBuilder.interface.new(
    opt: APIChannelSelectComponent?
): ChannelSelectMenuBuilder
    local data = opt or {}

    local fixedData = Table.Reconcile(data, { type = BaseSelectMenuBuilder.Type.ChannelSelection })

    return (class({}, ChannelSelectMenuBuilder.prototype):extend(
        BaseSelectMenuBuilder.new(fixedData)
    ) :: any) :: ChannelSelectMenuBuilder
end

export type ChannelSelectMenuBuilder =
    typeof(ChannelSelectMenuBuilder.prototype)
    & BaseSelectMenuBuilder.BaseSelectMenuBuilder<APIChannelSelectComponent>

return ChannelSelectMenuBuilder.interface
