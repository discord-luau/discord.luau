local enum = require("@std/enum")

local GlobalAPI = require("../global")
local PermissionsApi = require("permissions")

type Permissions = GlobalAPI.Permissions
type Snowflake = GlobalAPI.Snowflake

export type ChannelType = number
export type VideoQualityMode = number

export type APIBaseComponent = {
    type: number,
    custom_id: string?
}

export type APIButtonComponent = APIBaseComponent & {
    url: string?,
    disabled: boolean?,
    style: number?,
    label: string?,
    emoji: APIMessageComponentEmoji? 
}

export type APITextInputComponent = APIBaseComponent & {
    min_length: number?,
    max_length: number?,
    required: boolean?,
    value: any?,
    label: string?,
    style: number?,
    placeholder: string?, 
}

export type APISelectMenuComponent = APIBaseComponent & {
    placeholder: string?,
    max_value: number?,
    min_value: number?,
    disabled: boolean?,
}

export type APIChannelSelectComponent = APISelectMenuComponent &{
    channel_types: { number }?
}

export type APIMentionableSelectComponent = APISelectMenuComponent & {}
export type APIRoleSelectComponent = APISelectMenuComponent & {}
export type APIUserSelectComponent = APISelectMenuComponent & {}

export type APISelectMenuOption = {
    label: string,
    value: string,
    default: boolean?,
    description: string?,
    emoji: APIMessageComponentEmoji?
}

export type APIStringSelectComponent = APISelectMenuComponent & {
    options: { APISelectMenuOption }?
}

export type APIMessageComponentEmoji = {
    id: Snowflake?,
    name: string?,
    animated: boolean?
}

export type APIOverwrite = {
    id: Snowflake,
    type: OverwriteType,
    allow: Permissions,
    deny: Permissions
}

export type OverwriteType = number

export type APIChannel = {
    name: string?,
    bitrate: number?,
    type: number?,
    region: number?,
    video_quality_mode: VideoQualityMode?,
    sort_order: SortOrderType?,
    forum_layout: ForumLayoutType?,
    position: number?,
    topic: string?,
    nsfw: boolean?,
    rate_limit_per_user: number?,
    parent_id: string?,
    default_auto_archive_duration: number?,
    thread_rate_limit_per_user: number?,
    default_reaction_emoji: {
        emoji_id: string,
        emoji_name: string
    }?,
    permission_overwrites: {
        APIOverwrite
    }?
}

export type APIComponent = APIButtonComponent | APITextInputComponent | APIChannelSelectComponent | APIMentionableSelectComponent | APIMentionableSelectComponent | APIRoleSelectComponent | APIUserSelectComponent | APIStringSelectComponent

export type EmbedType = 'rich' | 'image' | 'video' | 'gifv' | 'article' | 'link' | 'auto_moderation_message'

export type APIEmbedThumbnail = {
    url: string,
    proxy_url: string?,
    height: number?,
    width: number?
}

export type APIEmbedVideo = {
    url: string?,
    proxy_url: string?,
    height: number?,
    width: number?
}

export type APIEmbedImage = {
    url: string,
    proxy_url: string?,
    height: number?,
    width: number?
}

export type APIEmbedProvider = {
    name: string?,
    url: string?
}

export type APIEmbedAuthor = {
    name: string,
    url: string?,
    icon_url: string?,
    proxy_icon_url: string?
}

export type APIEmbedFooter = {
    text: string,
    icon_url: string?,
    proxy_icon_url: string?,
}

export type APIEmbedField = {
    name: string,
    value: string,
    inline: boolean?
}

export type APIEmbed = {
    title: string?,
    type: EmbedType?,
    description: string?,
    url: string?,
    timestamp: string?,
    color: number?,
    footer: APIEmbedFooter?,
    image: APIEmbedImage?,
    thumbnail: APIEmbedThumbnail?,
    video: APIEmbedVideo?,
    provider: APIEmbedProvider?,
    author: APIEmbedAuthor?,
    fields: { APIEmbedField }?,
}

export type EmbedAuthorOptions = {
    name: string,
    url: string?,
    iconURL: string?,
}

export type EmbedVideoOptions = {
    videoURL: string,
    height: number?,
    width: number? 
}

export type EmbedFooterOptions = {
    iconURL: string?,
    text: string,
}

export type ForumLayoutType = number

export type SortOrderType = number

-- https://discord.com/developers/docs/resources/channel#channel-object-channel-types
local ChannelType = enum('ChannelType', {
	Text = 0,
	DM = 1,
	Voice = 2,
	Group = 3,
	Category = 4,
	Announcement = 5,
	AnnouncementThread = 10,
	PublicThread = 11,
	PrivateThread = 12,
	Stage = 13,
	Directory = 14,
	Forum = 15,
	Media = 16,
})

local VideoQualityMode = enum('VideoQualityMode', {
    Auto = 1,
    Full = 2
})

local SortOrderType = enum('SortOrderType', {
    LatestActivity = 0,
    CreationDate = 1
})

local ForumLayoutType = enum('ForumLayoutType', {
    NotSet = 0,
    ListView = 1,
    GalleryView = 2
})

local OverwriteType = enum('OverwriteType', {
    Role = 0,
    Member = 1
})

return {
    ChannelType = ChannelType,
    ForumLayoutType = ForumLayoutType,
    VideoQualityMode = VideoQualityMode,
    SortOrderType = SortOrderType,
    OverwriteType = OverwriteType
}