-- Standard Libraries 
local class = require("@std/class")

-- Dependencies
local Table = require("@deps/table")

-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")

-- Base Select Menu Class
local BaseSelectMenuBuilder = require("baseSelectMenu")

type APIMentionableSelectComponent = ChannelAPI.APIMentionableSelectComponent

local MentionableSelectMenuBuilder = {}

MentionableSelectMenuBuilder.interface = {}
MentionableSelectMenuBuilder.prototype = {}

MentionableSelectMenuBuilder.prototype.__type = "MentionableSelectMenuBuilder"

function MentionableSelectMenuBuilder.interface.new(opt: APIMentionableSelectComponent?): MentionableSelectMenuBuilder
    local data = opt or {}
    local fixedData = Table.Reconcile(data, { type = BaseSelectMenuBuilder.Type.MentionableSelection })
    return (class({}, MentionableSelectMenuBuilder.prototype):extend(BaseSelectMenuBuilder.new(fixedData)) :: any) :: MentionableSelectMenuBuilder
end

export type MentionableSelectMenuBuilder = typeof(MentionableSelectMenuBuilder.prototype) & BaseSelectMenuBuilder.BaseSelectMenuBuilder<APIMentionableSelectComponent>

return MentionableSelectMenuBuilder.interface