--!stricti

-- Standard Libraries 
local class = require("@std/class")
local enum = require("@std/enum")

-- Dependencies
local Table = require("@deps/table")
local Array = require("@deps/polyfill/array")



-- API
local ChannelAPI = require("@discordluau/api/payloads/channel")

-- Builders 
local BaseSelectMenuBuilder = require("baseSelectMenu")

local StringSelectMenuOptionBuilder = require("stringSelectMenuOption")


type APIStringSelectComponent = ChannelAPI.APIStringSelectComponent
type APISelectMenuOption = ChannelAPI.APISelectMenuOption

local StringSelectMenuBuilder = {}

StringSelectMenuBuilder.interface = {}
StringSelectMenuBuilder.prototype = {}

StringSelectMenuBuilder.prototype.__type = "StringSelectMenuBuilder"

function StringSelectMenuBuilder.prototype.addOption(
	self: StringSelectMenuBuilder, 
	opt: APISelectMenuOption
): StringSelectMenuBuilder
	local data = Array.find(self.options, function(value)
		return value.data.label == opt.label
	end)

	if data then
		data:setLabel(opt.label)
		data:setValue(opt.value)
		data:setDefault(opt.default)
		
		if opt.description then
			data:setDescription(opt.description)
		end

		if opt.emoji then
			data:setEmoji(opt.emoji)
		end
	else
		Array.push(self.options, StringSelectMenuOptionBuilder.new(opt))
	end

	return self
end

function StringSelectMenuBuilder.prototype.removeOption(self: StringSelectMenuBuilder, label: string): StringSelectMenuBuilder
	local data = Array.findIndex(self.options, function(value)
		return value.data.label == label
	end)

	if data then
		Table.remove(self.options, data)
	end

	return self
end

function StringSelectMenuBuilder.prototype.toJSON(self: StringSelectMenuBuilder)
	local selectionOptions

	if #self.options > 0 then
		selectionOptions = Array.map(self.options, function(option: StringSelectMenuOptionBuilder.StringSelectMenuOptionBuilder)
			return option:toJSON()
		end)
	end

	return {
        type = self.data.type,
		custom_id = self.data.custom_id,

		placeholder = self.data.placeholder,

		min_value = self.data.min_value,
		max_value = self.data.max_value,

		disabled = self.data.disabled,

		options = selectionOptions 
	}	
end


function StringSelectMenuBuilder.interface.new(opt: APIStringSelectComponent?): StringSelectMenuBuilder
	local data = opt or {}
	local fixedData = Table.Reconcile(data, { type = BaseSelectMenuBuilder.Type.TextSelection }) :: APIStringSelectComponent

	local options
	if fixedData['options'] and #fixedData['options'] > 0 then
		local opts = Array.map(fixedData.options, function(opt: APISelectMenuOption)
			return StringSelectMenuOptionBuilder.new(opt)
		end)
		options = opts
	else
		options = {}
	end

    return class({ options = options }, StringSelectMenuBuilder.prototype):extend(BaseSelectMenuBuilder.new(fixedData)) :: StringSelectMenuBuilder
end

export type StringSelectMenuBuilder = typeof(StringSelectMenuBuilder.prototype) & BaseSelectMenuBuilder.BaseSelectMenuBuilder<APIStringSelectComponent> & {
	options: { StringSelectMenuOptionBuilder.StringSelectMenuOptionBuilder }
}

return StringSelectMenuBuilder.interface