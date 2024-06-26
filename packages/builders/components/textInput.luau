-- Standard Libraries 
local class = require("@std/class")
local enum = require("@std/enum")

-- Dependencies
local Table = require("@deps/table")

-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")

-- Builders
local ComponentBuilder = require("component")

type APITextInputComponent = ChannelAPI.APITextInputComponent

local TextInputBuilder = {}

TextInputBuilder.interface = {}
TextInputBuilder.prototype = {}

TextInputBuilder.prototype.__type = "TextInputBuilder"

TextInputBuilder.interface.Style = enum('TextInputStyle', {
	Short = 1,
	Paragraph = 2
})

function TextInputBuilder.prototype.setStyle(self: TextInputBuilder, style: number): TextInputBuilder
	self.data.style = style

	return self
end

function TextInputBuilder.prototype.setLabel(self: TextInputBuilder, label: string): TextInputBuilder
	self.data.label = label

	return self
end

function TextInputBuilder.prototype.setMinLength(self: TextInputBuilder, length: number): TextInputBuilder
	self.data.min_length = length

	return self
end

function TextInputBuilder.prototype.setMaxLength(self: TextInputBuilder, length: number): TextInputBuilder
	self.data.max_length = length

	return self
end

function TextInputBuilder.prototype.setRequired(self: TextInputBuilder, required: boolean?): TextInputBuilder
	local required = required == nil and true or required :: boolean
	self.data.required = required

	return self
end

function TextInputBuilder.prototype.setDefaultValue(self: TextInputBuilder, value: string): TextInputBuilder
	self.data.value = value

	return self
end

function TextInputBuilder.prototype.setPlaceholder(self: TextInputBuilder, placeholder: string): TextInputBuilder
	self.data.placeholder = placeholder

	return self
end

function TextInputBuilder.prototype.setCustomId(self: TextInputBuilder, customId: string): TextInputBuilder
	self.data.custom_id = customId

	return self
end

function TextInputBuilder.interface.new(opt: APITextInputComponent?): TextInputBuilder
	local data = opt or {}
	local fixedData = Table.Reconcile(data, { type = 4 })

    return (class({}, TextInputBuilder.prototype):extend(ComponentBuilder.new(opt)) :: any) :: TextInputBuilder
end

export type TextInputBuilder = typeof(TextInputBuilder.prototype) & ComponentBuilder.ComponentBuilder<APITextInputComponent> 

return TextInputBuilder.interface