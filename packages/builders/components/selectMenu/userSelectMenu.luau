-- Standard Libraries 
local class = require("@std/class")

-- Dependencies
local Table = require("@deps/table")

-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")

-- Base Select Menu Class
local BaseSelectMenuBuilder = require("baseSelectMenu")

type APIUserSelectComponent = ChannelAPI.APIUserSelectComponent

local UserSelectMenuBuilder = {}

UserSelectMenuBuilder.interface = {}
UserSelectMenuBuilder.prototype = {}

UserSelectMenuBuilder.prototype.__type = "UserSelectMenuBuilder"

function UserSelectMenuBuilder.interface.new(opt: APIUserSelectComponent?): UserSelectMenuBuilder
    local data = opt or {}
    local fixedData = Table.Reconcile(data, { type = BaseSelectMenuBuilder.Type.RoleSelection })
    return (class({}, UserSelectMenuBuilder.prototype):extend(BaseSelectMenuBuilder.new(fixedData)) :: any) :: UserSelectMenuBuilder
end

export type UserSelectMenuBuilder = typeof(UserSelectMenuBuilder.prototype) & BaseSelectMenuBuilder.BaseSelectMenuBuilder<APIUserSelectComponent>

return UserSelectMenuBuilder.interface