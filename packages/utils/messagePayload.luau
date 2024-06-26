-- Standard Libraries 
local Class = require("@std/class")

-- Dependencies
local Table = require("@deps/table")

-- Utilities
local Transformers = require("@discordluau/utils/transformers")

-- API
local ChannelApi = require("@discordluau/api/payloads/channel")

-- Types
local MessageTypes = require("@discordluau/discord.luau/typings/message")

-- Class
local MessagePayload = {}
MessagePayload.prototype = {}
MessagePayload.interface = {}

MessagePayload.prototype.__type = 'MessagePayload'

function MessagePayload.prototype.resolveBody(self: MessagePayload): MessagePayload
    local content = self:makeContent()
    local tts = self.options.tts or false

    local nonce = self.options.nonce or nil
    local enforce_nonce = self.options.enforceNonce or false
    local components = #self.options.components > 0 and self.options.components or nil
    local embeds = #self.options.embeds > 0 and self.options.embeds or nil
    local flags = self.options.flags or nil
    local stickers = #self.options.stickerIds > 0 and self.options.stickerIds or nil


    self.body = {
        content = content,
        tts = tts,
        nonce = nonce,
        enforce_nonce = enforce_nonce,
        components = components,
        embeds = embeds,
        flags = flags,
        sticker_ids = stickers
    }

    return self
end

function MessagePayload.prototype.resolveFiles(self: MessagePayload): MessagePayload
    if self.options.files then
         self.files = self.options.files
    end

    return self
end

function MessagePayload.prototype.resolveHeaders(self: MessagePayload): MessagePayload
    if self.options.headers then
        self.headers = self.options.headers
    end

    return self
end

function MessagePayload.prototype.update(self: MessagePayload, callback: (data: any) -> any): MessagePayload
	self.body = callback(self.body)

	return self
end

function MessagePayload.prototype.makeContent(self: MessagePayload)
    local content
    if self.options.content == nil then
        content = ''
    else
        content = self.options.content
    end

    return content
end

function MessagePayload.prototype.constructor(self: MessagePayload, options: MessagePayloadOptions)
   self.options = options
   self.body = nil
   self.files = nil
   self.headers = nil
end

function MessagePayload.interface.new(options: MessagePayloadOptions?): MessagePayload
    local opt = options or { components = {}, embeds = {}, stickerIds = {} } :: MessagePayloadOptions
    local self = Class({ options = opt }, MessagePayload.prototype)
    self:constructor(opt)
    return self
end

type APIEmbed = ChannelApi.APIEmbed
type MessagePayloadOptions = MessageTypes.MessagePayloadOptions
type Files = MessageTypes.Files
type Headers = MessageTypes.Headers

export type MessagePayloadProperties = { body: any?, files: Files?, headers: Headers?, options: MessagePayloadOptions }
export type MessagePayload = typeof(MessagePayload.prototype) & MessagePayloadProperties


return MessagePayload.interface