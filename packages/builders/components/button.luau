-- Standard Libraries 
local class = require("@std/class")
local enum = require("@std/enum")

-- Dependencies
local Table = require("@deps/table")


-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")

-- Builders 
local ComponentBuilder = require("component")


type APIButtonComponent = ChannelAPI.APIButtonComponent
type APIMessageComponentEmoji = ChannelAPI.APIMessageComponentEmoji

local ButtonBuilder = {}

ButtonBuilder.interface = {}
ButtonBuilder.prototype = {}

ButtonBuilder.prototype.__type = "ButtonBuilder"

ButtonBuilder.interface.Style = enum('ButtonStyle', {
    Primary = 1,
    Secondary = 2,
    Success = 3,
    Danger = 4,
    Link = 5,
    Blurple = 1,
    Grey = 2,
    Gray = 2,
    Green = 3,
    Red = 4,
    Url = 5
})

function ButtonBuilder.prototype.setStyle(self: ButtonBuilder, style: number)
	self.data.style = style

	return self
end

function ButtonBuilder.prototype.setLabel(self: ButtonBuilder, label: string)
	self.data.label = label

	return self
end

function ButtonBuilder.prototype.setEmoji(self: ButtonBuilder, emoji: APIMessageComponentEmoji)
	self.data.emoji = emoji 

	return self
end

function ButtonBuilder.prototype.setURL(self: ButtonBuilder, url: string)
	self.data.url = url	

	return self
end

function ButtonBuilder.prototype.setDisabled(self: ButtonBuilder, disabled: boolean?)
	local disabled = disabled == nil and true or disabled :: boolean
	self.data.disabled = disabled

	return self
end

function ButtonBuilder.prototype.setCustomId(self: ButtonBuilder, customId: string)
	self.data.custom_id = customId	

	return self
end

function ButtonBuilder.interface.new(opt: APIButtonComponent?): ButtonBuilder
	local data = opt or {}
	local fixedData = Table.Reconcile(data, { type = 2 })

    return (class({}, ButtonBuilder.prototype):extend(ComponentBuilder.new(fixedData)) :: any) :: ButtonBuilder
end

export type ButtonBuilder = typeof(ButtonBuilder.prototype) & ComponentBuilder.ComponentBuilder<APIButtonComponent>

return ButtonBuilder.interface