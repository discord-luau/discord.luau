--!strict

-- Standard Libraries 
local class = require("@std/class")
local enum = require("@std/enum")

-- API
local ChannelAPI = require('@discordluau/api/payloads/channel')

-- Builders
local ComponentBuilder = require('@discordluau/builders/components/component')

type APISelectMenuComponent = ChannelAPI.APISelectMenuComponent

local BaseSelectMenuBuilder = {}

BaseSelectMenuBuilder.interface = {}
BaseSelectMenuBuilder.prototype = {}

BaseSelectMenuBuilder.prototype.__type = 'SelectMenuComponent'
BaseSelectMenuBuilder.interface.Type = enum('SelectMenuType', {
    TextSelection = 3,
    UserSelection = 5,
    RoleSelection = 6,
    MentionableSelection = 7,
    ChannelSelection = 8,
})

function BaseSelectMenuBuilder.prototype.setPlaceholder<T>(
    self: BaseSelectMenuBuilder<T>,
    placeholderText: string
): BaseSelectMenuBuilder<T>
    (self.data :: any).placeholder = placeholderText

    return self
end

function BaseSelectMenuBuilder.prototype.setCustomId<T>(
    self: BaseSelectMenuBuilder<T>,
    customId: string
): BaseSelectMenuBuilder<T>
    (self.data :: any).custom_id = customId

    return self
end

function BaseSelectMenuBuilder.prototype.setDisabled<T>(
    self: BaseSelectMenuBuilder<T>,
    isDisabled: boolean
): BaseSelectMenuBuilder<T>
    (self.data :: any).disabled = isDisabled

    return self
end

function BaseSelectMenuBuilder.prototype.setMinValues<T>(
    self: BaseSelectMenuBuilder<T>,
    minValue: number
): BaseSelectMenuBuilder<T>
    (self.data :: any).min_value = minValue

    return self
end

function BaseSelectMenuBuilder.prototype.setMaxValues<T>(
    self: BaseSelectMenuBuilder<T>,
    maxValue: number
): BaseSelectMenuBuilder<T>
    (self.data :: any).max_value = maxValue

    return self
end

function BaseSelectMenuBuilder.interface.new<T>(opt: T): BaseSelectMenuBuilder<T>
    local data = (opt :: any) :: APISelectMenuComponent

    return class({}, BaseSelectMenuBuilder.prototype):extend(ComponentBuilder.new(opt))
end

export type BaseSelectMenuBuilder<T> =
    typeof(BaseSelectMenuBuilder.prototype)
    & ComponentBuilder.ComponentBuilder<T>

return BaseSelectMenuBuilder.interface