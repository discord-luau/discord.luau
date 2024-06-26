--!strict

-- Standard Libraries
local Class = require("@std/class")
local Date = require("@std/datetime")
local enum = require("@std/enum")

-- Dependencies
local Array = require("@deps/polyfill/array")
local Table = require("@deps/table")

-- API
local ChannelApi = require("@discordluau/api/payloads/channel")

-- Builders Utilities
local normalizeArray = require("../utils/normalizeArray")
local color = require("../utils/color")

export type RestOrArray<Type> = normalizeArray.RestOrArray<Type>

type RGBTuple = { red: number, green: number, blue: number }
type Color = string | number | RGBTuple
type APIEmbed = ChannelApi.APIEmbed

local EmbedBuilder = {}

EmbedBuilder.interface = {}
EmbedBuilder.prototype = {}

EmbedBuilder.prototype.__type = "EmbedBuilder"

EmbedBuilder.interface.EmbedType = enum('EmbedTpye', {
    Rich = "rich",
	Image = "image",
	Video = "video",
	Gif = "gifv",
	Article = "article",
	Link = "link"
})

function EmbedBuilder.prototype.setTitle(self: EmbedBuilder, title: string): EmbedBuilder
	self.data.title = title

	return self
end

function EmbedBuilder.prototype.setType(self: EmbedBuilder, type: ChannelApi.EmbedType): EmbedBuilder
	self.data.type = type

	return self
end

function EmbedBuilder.prototype.setDescription(self: EmbedBuilder, description: string): EmbedBuilder
	self.data.description = description

	return self
end

function EmbedBuilder.prototype.setUrl(self: EmbedBuilder, url: string): EmbedBuilder
	self.data.url = url

	return self
end

function EmbedBuilder.prototype.setTimestamp(self: EmbedBuilder, epoch: number?): EmbedBuilder
	self.data.timestamp = epoch and Date.fromUniversalTime(epoch :: any):toIsoDate() or Date.new():toISOString()

	return self
end

function EmbedBuilder.prototype.setColor(self: EmbedBuilder, clr: Color): EmbedBuilder
	if typeof(clr) == "table" then
		local colorData = color.ValidateRGB(clr)

		self.data.color = colorData
	else
		local colorHex = color.ValidateHex(clr)
		if colorHex then
			self.data.color = colorHex
		end
	end

	return self
end

function EmbedBuilder.prototype.setFooter(self: EmbedBuilder, options: ChannelApi.EmbedFooterOptions?): EmbedBuilder
	if not options then
		self.data.footer = nil
	else
		self.data.footer = { icon_url = options.iconURL, text = options.text }
	end

	return self
end

function EmbedBuilder.prototype.setImage(self: EmbedBuilder, url: string?): EmbedBuilder
	self.data.image = url and { url = url } or nil

	return self
end

function EmbedBuilder.prototype.setThumbnail(self: EmbedBuilder, url: string?): EmbedBuilder
	self.data.thumbnail = url and { url = url } or nil

	return self
end

function EmbedBuilder.prototype.setVideo(self: EmbedBuilder, options: ChannelApi.EmbedVideoOptions): EmbedBuilder
	self.data.video = { url = options.videoURL, height = options.height, width = options.width }

	return self
end

function EmbedBuilder.prototype.setProvider(self: EmbedBuilder, options: ChannelApi.APIEmbedProvider): EmbedBuilder
	self.data.provider = options

	return self
end

function EmbedBuilder.prototype.setAuthor(self: EmbedBuilder, options: ChannelApi.EmbedAuthorOptions): EmbedBuilder
	if not options then
		self.data.author = nil
	end

	self.data.author = { name = options.name, url = options.url, icon_url = options.iconURL }

	return self
end

function EmbedBuilder.prototype.addField(self: EmbedBuilder, field: ChannelApi.APIEmbedField): EmbedBuilder
	if self.data.fields then
		Array.push(self.data.fields, field)
	else
		self.data.fields = field
	end

	return self
end

function EmbedBuilder.prototype.addFields(self: EmbedBuilder, ...: RestOrArray<ChannelApi.APIEmbedField>): EmbedBuilder
	local normalizeFields = normalizeArray({ ... })
	if not self.data.fields or #self.data.fields == 0 then
		self.data.fields = normalizeFields
	else
		Array.push(self.data.fields, Array.spread(normalizeFields))
	end

	return self
end

function EmbedBuilder.prototype.setFields(self: EmbedBuilder, ...: RestOrArray<ChannelApi.APIEmbedField>): EmbedBuilder
	local normalizeFields = normalizeArray({ ... })

	self:spliceFields(0, self.data.fields and #self.data.fields or 0, Array.spread(normalizeFields))
	
	return self
end

function EmbedBuilder.prototype.spliceFields(self: EmbedBuilder, index: number, deleteCount: number, ...: ChannelApi.APIEmbedField): ()
	local normalizeFields = normalizeArray({ ... })

	if self.data.fields and #self.data.fields > 0 then
		Array.splice(self.data.fields, index, deleteCount, Array.spread(normalizeFields))
	else
		self.data.fields = normalizeFields
	end
end

function EmbedBuilder.prototype.toJSON(self: EmbedBuilder): APIEmbed
	return Table.Copy(self.data, true) 
end

function EmbedBuilder.interface.new(embedData: APIEmbed?): EmbedBuilder
    return Class({
        data = embedData or {}
    }, EmbedBuilder.prototype)
end

export type EmbedBuilder = typeof(EmbedBuilder.prototype) & {
    data: APIEmbed
}

return EmbedBuilder.interface