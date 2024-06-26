--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Snowflake = require("@deps/sapphire/snowflake")

-- Enumerations
local DiscordSnowflake = Snowflake.DiscordSnowflake

--[=[
	@class Emoji
]=]
local Emoji = {}

Emoji.prototype = {}
Emoji.interface = {}

Emoji.prototype.__type = "Emoji"

function Emoji.prototype.imageURL(self: Emoji, options)
	return self.id and self.client.rest.cdn:emoji(self.id, options)
end

function Emoji.interface.new(client: any, emojiData: EmojiData): Emoji
	return client.cache.emojis:fetch(emojiData.id, function()
		local emojiStruct = {
			client = client
		}

		local timestamp = DiscordSnowflake:timestampFrom(emojiData.id) :: number

		if not emojiData['createdTimestamp'] then
			emojiData['createdTimestamp'] = timestamp
		end

		for index, value in emojiData do
			emojiStruct[index] = value
		end

		return class(emojiStruct, Emoji.prototype)
	end)
end

export type EmojiData = {
    id: string,
	name: string,
	roles: { string },
	requireColons: boolean,
	managed: boolean,
	animated: boolean,
	avaliable: boolean
}

export type Emoji = typeof(Emoji.prototype) & {
	id: string,
	name: string,
	roles: { string },
	requireColons: boolean,
	managed: boolean,
	animated: boolean,
	avaliable: boolean,
	client: any
}

return Emoji.interface