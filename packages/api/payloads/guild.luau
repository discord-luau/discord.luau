local enum = require("@std/enum")

local PermissionsApi = require("permissions")
local ChannelApi = require("channel")
local GlobalApi = require("../global")

type APIChannel = ChannelApi.APIChannel
type APIRole = PermissionsApi.APIRole
type Snowflake = GlobalApi.Snowflake
type Permissions = GlobalApi.Permissions

local lshift = bit32.lshift

export type CreateBanOptions = {
    deleteMessageDays: number?,
    deleteMessageSeconds: number?,
}

export type CreateEmojiOptions = {
    image: string,
    name: string,
    roles: { string }?
}

export type BulkBanOptions = {
    deleteMessageSeconds: number?,
    userIds: { string }
}

export type BeginPruneOptions = {
    computePruneCount: boolean?,
    days: number?,
    includeRoles: { string }?
}

export type GuildSystemChannelFlag = number
export type AFKTimeout = number
export type GuildVerificationLevel = number
export type GuildDefaultMessageNotifications = number
export type GuildExplicitContentFilter = number
export type GuildFeature = string

export type EditMemberOptions = {
    channelId: string?,
    communicationDisabledUntil: number?,
    deaf: boolean?,
    flags: number?,
    mute: boolean?,
    nick: string?,
    roles: { string }?
}

export type APIPartialGuild = {
    name: string,
    icon: string?,
    splash: string?,
    banner: string?,
    description: string?,
    features: { string },
    verification_level: GuildVerificationLevel?,
    vanity_url_code: string?,
}

export type APIGuild = APIPartialGuild & {
    discovery_splash: string?,
    premium_progress_bar_enabled: boolean,
    safety_alerts_channel_id: string?,
    owner_id: Snowflake,
    permissions: Permissions?,
    afk_channel_id: Snowflake?,
    afk_timeout: number,
    widget_enabled: boolean?,
    widget_channel_id: string?,
    verification_level: GuildVerificationLevel,
    default_message_notifications: GuildDefaultMessageNotifications,
    explicit_content_filter: GuildExplicitContentFilter,
    roles: { APIRole },
    features: { GuildFeature },
    channels: { APIChannel },
    preferred_locale: string,
    public_updates_channel_id: Snowflake?,
    rules_channel_id: Snowflake?,
    system_channel_id: Snowflake?,
    system_channel_flags: number,
}

local AFKTimeout = enum('AFKTimeout', {
    ['1000'] = 1000,
    ['3600'] = 3600,
    ['60'] = 60,
    ['30'] = 300,
    ['90'] = 900
})

local GuildFeatures = enum('GuildFeatures', {
	AnimatedBanner = "ANIMATED_BANNER",
	AnimatedIcon = "ANIMATED_ICON",
	ApplicationCommandPermissionsV2 = "APPLICATION_COMMAND_PERMISSIONS_V2",
	AutoModeration = "AUTO_MODERATION",
	Banner = "BANNER",
	Community = "COMMUNITY",
	CreatorMonetizableProvisional = "CREATOR_MONETIZABLE_PROVISIONAL",
	CreatorStorePage = "CREATOR_STORE_PAGE",
	DeveloperSupportServer = "DEVELOPER_SUPPORT_SERVER",
	Discoverable = "DISCOVERABLE",
	Featurable = "FEATURABLE",
	InvitesDisabled = "INVITES_DISABLED",
	InviteSplash = "INVITE_SPLASH",
	MemberVerificationGateEnabled = "MEMBER_VERIFICATION_GATE_ENABLED",
	MoreStickers = "MORE_STICKERS",
	News = "NEWS",
	Partnered = "PARTNERED",
	PreviewEnabled = "PREVIEW_ENABLED",
	RaidAlertsDisabled = "RAID_ALERTS_DISABLED",
	RoleIcons = "ROLE_ICONS",
	RoleSubscriptionsAvailableForPurchase = "ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE",
	RoleSubscriptionsEnabled = "ROLE_SUBSCRIPTIONS_ENABLED",
	TicketedEventsEnabled = "TICKETED_EVENTS_ENABLED",
	VanityUrl = "VANITY_URL",
	Verified = "VERIFIED",
	VipRegions = "VIP_REGIONS",
	WelcomeScreenEnabled = "WELCOME_SCREEN_ENABLED",
})

local GuildDefaultMessageNotifications = enum('GuildDefaultMessageNotifications', {
    AllMessages = 0,
    OnlyMentions = 1
})

local GuildExplicitContentFilter = enum('GuildExplicitContentFilter', {
    Disabled = 0,
    MembersWithoutRoles = 1,
    AllMembers = 2
})

local GuildSystemChannelFlags = enum('GuildSystemChannelFlags', {
    SuppressJoinNotifications = lshift(1, 0),
    SuppressPremiumSubscriptions = lshift(1, 1),
    SuppressGuildReminderNotifications = lshift(1, 2),
    SuppressJoinNotificationReplies = lshift(1, 3),
    SuppressRoleSubscriptionPurchaseNotifications = lshift(1, 4),
    SuppressRoleSubscriptionPurchaseNotificationReplies = lshift(1, 5)
})

local GuildVerificationLevel = enum('GuildVerificationLevel', {
    None = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    VeryHigh = 4
})


return {
    AFKTimeout = AFKTimeout,
    GuildDefaultMessageNotifications = GuildDefaultMessageNotifications,
    GuildExplicitContentFilter = GuildExplicitContentFilter,
    GuildFeatures = GuildFeatures,
    GuildSystemChannelFlags = GuildSystemChannelFlags,
    GuildVerificationLevel = GuildVerificationLevel
}