--!strict

-- Modules
local class = require("@std/class") 

-- Utilities
local is = require("@discordluau/utils/is")
local MessagePayload = require("@discordluau/utils/messagePayload")

-- Builders
local EmbedBuilder = require("embed")
local AttachmentBuilder = require("attachment")
local ActionRowBuilder = require("../components/actionRow")

-- API
local ChannelApi = require("@discordluau/api/payloads/channel")

type MessageComponent = ActionRowBuilder.MessageComponentBuilder
type APIComponent = ChannelApi.APIComponent
type EmbedBuilder = EmbedBuilder.EmbedBuilder
type APIEmbed = ChannelApi.APIEmbed

--[=[
	@class MessageBuilder
]=]
local MessageBuilder = {}

MessageBuilder.interface = {}
MessageBuilder.prototype = {}

MessageBuilder.prototype.__type = "MessageBuilder"

function MessageBuilder.prototype.setContent(self: MessageBuilder, content: string)
	self.content = content

	return self
end

function MessageBuilder.prototype.setNonce(self: MessageBuilder, nonce: string)
	self.nonce = nonce
	self.nonceEnforced = true

	return self
end

function MessageBuilder.prototype.setTTSEnabled(self: MessageBuilder, ttsEnabled: boolean)
	self.ttsEnabled = ttsEnabled

	return self
end

function MessageBuilder.prototype.addEmbed(self: MessageBuilder, embedBuilder: EmbedBuilder.EmbedBuilder | APIEmbed)
	table.insert(self.embeds, embedBuilder)

	return self
end

function MessageBuilder.prototype.addComponent(self: MessageBuilder, discordComponent: MessageComponent | APIComponent)
	table.insert(self.components, discordComponent)

	return self
end

function MessageBuilder.prototype.addStickerId(self: MessageBuilder, stickerId: string)
	table.insert(self.stickerIds, stickerId)

	return self
end

function MessageBuilder.prototype.setFlags(self: MessageBuilder, flags: number)
	self.flags = flags

	return self
end

--[=[
	Add a file to the Message object
]=]
function MessageBuilder.prototype.addFile(self: MessageBuilder, attachment: AttachmentBuilder.AttachmentBuilder)
	table.insert(self.attachments, attachment)

	return self
end

--[=[
]=]
function MessageBuilder.prototype.toJSON(self: MessageBuilder)
	local components = {}
	local embeds = {}
	local attachments = {}

	for _, component: any in self.components :: {} do
		if component.toJSON and typeof(component.toJSON) == "function" then
			table.insert(components, (component :: any):toJSON())
		elseif typeof(component) == "table" then
			table.insert(components, component)
		end
	end

	for _, embed: any in self.embeds :: {} do
		if embed.toJSON and typeof(embed.toJSON) == "function" then
			table.insert(embeds, embed:toJSON())
		elseif typeof(embed) == "table" then
			table.insert(embeds, embed)
		end
	end	

	for index, file in self.attachments do
		table.insert(attachments, {
			id = index - 1,
			description = file.description,
			filename = file.name,
		})
	end

	return {
		content = self.content or "",
		nonce = self.nonce or nil,
		tts = self.ttsEnabled or false,
		flags = self.flags or nil, --fixme: should use a bitfield.
		enforce_nonce = self.nonceEnforced or false,

		attachments = #attachments > 0 and attachments or nil,
		embeds = #embeds > 0 and embeds or nil,
		components = #components > 0 and components or nil,

		sticker_ids = #self.stickerIds > 0 and self.stickerIds or nil,
	}	
end

function MessageBuilder.prototype.toPayload(self: MessageBuilder): MessagePayload.MessagePayload
	local components = {}
	local embeds = {}

	for _, component: any in self.components :: {} do
		if component.toJSON and typeof(component.toJSON) == "function" then
			table.insert(components, (component :: any):toJSON())
		elseif typeof(component) == "table" then
			table.insert(components, component)
		end
	end

	for _, embed: any in self.embeds :: {} do
		if is(embed, 'EmbedBuilder') then
			table.insert(embeds, embed:toJSON())
		elseif typeof(embed) == "table" then
			table.insert(embeds, embed)
		end
	end

	local data = {
		content = self.content or "",
		nonce = self.nonce or nil,
		tts = self.ttsEnabled or false,
		flags = self.flags or nil, --fixme: should use a bitfield.
		enforce_nonce = self.nonceEnforced or false,

		embeds = embeds,
		components = components,

		stickerIds = self.stickerIds,
	}

	if #self.attachments > 0 then
		data['files'] = self.attachments
	end


	return MessagePayload.new(data)
end

--[=[
]=]
function MessageBuilder.interface.new(): MessageBuilder
	return class({
		embeds = {},
		components = {},
		attachments = {},
		stickerIds = {}
	}, MessageBuilder.prototype) :: any
end

function MessageBuilder.interface.transform(messageData: any): MessageBuilder
	local embeds = messageData.embeds or {}
	local components = messageData.components or {}
	local attachments = messageData.attachments or {}
	local stickerIds = messageData.stickerIds or {}

	local self = class({
		embeds = embeds,
		components = components,
		attachments = attachments,
		stickerIds = stickerIds
	}, MessageBuilder.prototype) :: any

	if messageData.content then
		self:setContent(messageData.content)
	end


	if messageData.flags then
		self:setFlags(messageData)
	end

	if messageData.tts then
		self:setTTSEnabled(messageData.tts)
	end

	return self :: MessageBuilder
end

export type MessageBuilder = typeof(MessageBuilder.prototype) & {
	content: string,

	nonce: string,
	nonceEnforced: boolean,

	ttsEnabled: boolean,

	embeds: { EmbedBuilder.EmbedBuilder | APIEmbed },
	components: { MessageComponent | APIComponent },

	attachments: { AttachmentBuilder.AttachmentBuilder },

	stickerIds: { string },

	flags: number
}

return MessageBuilder.interface