local ChannelApi = require("@discordluau/api/payloads/channel")

local EmbedBuilder = require("@discordluau/builders/messages/embed")
local ActionRowBuilder = require("@discordluau/builders/components/actionRow")

export type MessageComponent = ActionRowBuilder.MessageComponentBuilder
export type Headers = { [string]: string }
export type Files = { any }

export type MessagePayloadOptions = {
    content: string?,
    nonce: string?,
    tts: boolean?,
    flags: number?,
    enforceNonce: boolean?,
    embeds: { ChannelApi.APIEmbed },
    components: { any },
    stickerIds: { string },
    files: Files?,
    headers: Headers?,
}

export type MessageSchema = {
    content: string?,
    nonce: (string | number)?,
    tts: boolean?,
    embeds: { EmbedBuilder.EmbedBuilder }?,
    components: { MessageComponent }?,
    stickerIds: { string }?,
    flags: number?,
    stickerIds: { string },
    files: Files?,
    enforceNonce: boolean?,
}

return {} 