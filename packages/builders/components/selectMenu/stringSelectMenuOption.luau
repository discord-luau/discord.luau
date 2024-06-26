-- Standard Libraries
local class = require("@std/class")

-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")
local GlobalAPI = require("@discordluau/api/global")

type APISelectMenuOption = ChannelAPI.APISelectMenuOption
type APIMessageComponentEmoji = ChannelAPI.APIMessageComponentEmoji
type Snowflake = GlobalAPI.Snowflake

local StringSelectMenuOptionBuilder = {}

StringSelectMenuOptionBuilder.interface = {}
StringSelectMenuOptionBuilder.prototype = {}

StringSelectMenuOptionBuilder.prototype.__type = "StringSelectMenuOptionBuilder"

function StringSelectMenuOptionBuilder.prototype.setLabel(self: StringSelectMenuOptionBuilder, label: string): StringSelectMenuOptionBuilder
    self.data.label = label

    return self
end

function StringSelectMenuOptionBuilder.prototype.setValue(self: StringSelectMenuOptionBuilder, value: string): StringSelectMenuOptionBuilder
    self.data.value = value

    return self
end

function StringSelectMenuOptionBuilder.prototype.setDescription(self: StringSelectMenuOptionBuilder, description: string): StringSelectMenuOptionBuilder
    self.data.description = description

    return self
end

function StringSelectMenuOptionBuilder.prototype.setDefault(self: StringSelectMenuOptionBuilder, isDefault: boolean?): StringSelectMenuOptionBuilder
    local isDefault = isDefault == nil and true or isDefault :: boolean

    self.data.default = isDefault

    return self
end

function StringSelectMenuOptionBuilder.prototype.setEmoji(self: StringSelectMenuOptionBuilder, emoji: APIMessageComponentEmoji): StringSelectMenuOptionBuilder
    self.data.emoji = emoji

    return self
end

function StringSelectMenuOptionBuilder.prototype.toJSON(self: StringSelectMenuOptionBuilder): APISelectMenuOption
    return self.data
end

function StringSelectMenuOptionBuilder.interface.new(data: APISelectMenuOption?): StringSelectMenuOptionBuilder
    local data = data or {}

    return (class({ data = data }, StringSelectMenuOptionBuilder.prototype) :: any) :: StringSelectMenuOptionBuilder
end

export type StringSelectMenuOptionBuilder = typeof(StringSelectMenuOptionBuilder.prototype) & {
    data: APISelectMenuOption
}

return StringSelectMenuOptionBuilder.interface