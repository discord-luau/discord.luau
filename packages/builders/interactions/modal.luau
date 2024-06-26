-- Standard Libraries
local class = require("@std/class")

-- Inner Builders
local ActionRowBuilder = require("../components/actionRow")

type MessageComponent = ActionRowBuilder.MessageComponentBuilder



--[=[
	ModalBuilder is used to construct a modal dialog for a Discord interaction, including title and components.

	Usage:
	```lua
	local modal = ModalBuilder.new("modal_id")
		:setTitle("Example Modal")
		:addComponent(ButtonBuilder.new("button_id"))
	```
]=]
local ModalBuilder = {}

ModalBuilder.interface = {}
ModalBuilder.prototype = {}

ModalBuilder.prototype.__type = "ModalBuilder"

--[=[
	Sets the title of the modal.
]=]
function ModalBuilder.prototype.setTitle(self: ModalBuilder, title: string): ModalBuilder
	self.modalTitle = title

	return self
end

--[=[
	Adds a component to the modal. The modal can contain up to five components.
]=]
function ModalBuilder.prototype.addComponent(self: ModalBuilder, componentObject: MessageComponent): ModalBuilder
	assert(#self.components + 1 <= 5, "Action Row objects can only contain up to five components!")

	table.insert(self.components, componentObject)

	return self
end

--[=[
	Converts the modal to a JSON object that can be sent to the Discord API.
]=]
function ModalBuilder.prototype.toJSON(self: ModalBuilder)
	local components = {}

	for index, componentObject in self.components :: { any } do
		components[index] = componentObject:toJSON()
	end

	return {
		title = self.modalTitle,
		custom_id = self.modalId,
		components = components
	}	
end

--[=[
	Creates a new instance of ModalBuilder.
]=]
function ModalBuilder.interface.new(modalId: string): ModalBuilder
	return class({
		components = {},
		modalId = modalId
	}, ModalBuilder.prototype) :: any
end

export type ModalBuilder = typeof(ModalBuilder.prototype) & {
	components: { MessageComponent },
	modalId: string?,
	modalTitle: string?
}

return ModalBuilder.interface