--!strict

-- Standard Libraries 
local class = require("@std/class") 

-- Components Class
local ButtonBuilder = require("button")
local MentionableSelectMenuBuilder = require("selectMenu/mentionableSelectMenu")
local ChannelSelectMenuBuilder = require("selectMenu/channelSelectMenu")
local RoleSelectMenuBuilder = require("selectMenu/roleSelectMenu")
local StringSelectMenuBuilder = require("selectMenu/stringSelectMenu")
local UserSelectMenuBuilder = require("selectMenu/userSelectMenu")
local TextInputBuilder = require("textInput")

local ActionRowBuilder = {}

ActionRowBuilder.interface = {}
ActionRowBuilder.prototype = {}

ActionRowBuilder.prototype.__type = "ActionRowBuilder"

export type MessageActionRowComponentBuilder = ButtonBuilder.ButtonBuilder
	| ChannelSelectMenuBuilder.ChannelSelectMenuBuilder
	| MentionableSelectMenuBuilder.MentionableSelectMenuBuilder
	| RoleSelectMenuBuilder.RoleSelectMenuBuilder
	| StringSelectMenuBuilder.StringSelectMenuBuilder
	| UserSelectMenuBuilder.UserSelectMenuBuilder

export type ModalActionRowComponentBuilder = TextInputBuilder.TextInputBuilder

export type AnyComponentBuilder = MessageActionRowComponentBuilder | ModalActionRowComponentBuilder

export type MessageComponentBuilder = AnyComponentBuilder | ActionRowBuilder

function ActionRowBuilder.prototype.addComponent(
	self: ActionRowBuilder,
	componentObject: MessageComponentBuilder
): ActionRowBuilder
	assert(#self.components + 1 <= 5, "Action Row objects can only contain up to five components!")

	table.insert(self.components, componentObject)

	return self
end

function ActionRowBuilder.prototype.toJSON(self: ActionRowBuilder)
	local components = {}

	for index, componentObject in self.components :: { any } do
		components[index] = componentObject:toJSON()
	end

	return {
		type = 1,
		components = components
	}
end

function ActionRowBuilder.interface.new(): ActionRowBuilder
	return class({
		components = {}
	}, ActionRowBuilder.prototype) :: ActionRowBuilder
end

export type ActionRowBuilder = typeof(ActionRowBuilder.prototype) & {
	components: {
		MessageComponentBuilder
	}
}

return ActionRowBuilder.interface