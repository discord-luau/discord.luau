-- Standard Libraries 
local class = require("@std/class")

-- Dependencies
local Table = require("@deps/table")

-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")

-- Base Select Menu Class
local BaseSelectMenuBuilder = require("baseSelectMenu")

type APIRoleSelectComponent = ChannelAPI.APIRoleSelectComponent

local RoleSelectMenuBuilder = {}

RoleSelectMenuBuilder.interface = {}
RoleSelectMenuBuilder.prototype = {}

RoleSelectMenuBuilder.prototype.__type = "RoleSelectMenuBuilder"

function RoleSelectMenuBuilder.interface.new(opt: APIRoleSelectComponent?): RoleSelectMenuBuilder
    local data = opt or {}
    local fixedData = Table.Reconcile(data, { type = BaseSelectMenuBuilder.Type.RoleSelection })
    return (class({}, RoleSelectMenuBuilder.prototype):extend(BaseSelectMenuBuilder.new(fixedData)) :: any) :: RoleSelectMenuBuilder
end

export type RoleSelectMenuBuilder = typeof(RoleSelectMenuBuilder.prototype) & BaseSelectMenuBuilder.BaseSelectMenuBuilder<APIRoleSelectComponent>

return RoleSelectMenuBuilder.interface