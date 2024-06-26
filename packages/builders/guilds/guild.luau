--!strict

-- Standard Libraries
local class = require("@std/class")

-- API
local ChannelApi = require("@discordluau/api/payloads/channel")
local GlobalApi = require("@discordluau/api/global")
local GuildApi = require("@discordluau/api/payloads/guild")
local PermissionsApi = require("@discordluau/api/payloads/permissions")

-- Utilities
local is = require("@discordluau/utils/is")

-- Core Package Utilities
local RoleBuilder = require("./role")
local ChannelBuilder = require("../channel")

local PermissionsBitField = require("@discordluau/discord.luau/utils/permissionsBitField")

-- Enumerations
local GuildFeatures = GuildApi.GuildFeatures
local GuildDefaultMessageNotifications = GuildApi.GuildDefaultMessageNotifications
local GuildExplicitContentFilter = GuildApi.GuildExplicitContentFilter
local GuildSystemChannelFlags = GuildApi.GuildSystemChannelFlags
local GuildVerificationLevel = GuildApi.GuildVerificationLevel
local AFKTimeout = GuildApi.AFKTimeout

type Permissions = GlobalApi.Permissions
type Snowflake = GlobalApi.Snowflake

local GuildBuilder = {}

GuildBuilder.interface = {}
GuildBuilder.prototype = {}

GuildBuilder.prototype.__type = 'GuildBuilder'

--[=[
	Sets the name of this discord guild.
]=]
function GuildBuilder.prototype.setName(self: GuildBuilder, name: string)
	self.name = name

	return self
end

--[=[
	Sets the verification level for this guild.
]=]
function GuildBuilder.prototype.setVerificationLevel(self: GuildBuilder, verificationLevel: GuildApi.GuildVerificationLevel)
	local isGuildVerificationLevel = GuildVerificationLevel:is(verificationLevel)

    if isGuildVerificationLevel then
        self.verification_level = verificationLevel
    end

	return self
end

--[=[
	Sets the default message notification level for this guild.
]=]
function GuildBuilder.prototype.setDefaultMessageNotifications(self: GuildBuilder, notificationLevel: GuildApi.GuildDefaultMessageNotifications)
    local isGuildDefaultMessageNotifications = GuildDefaultMessageNotifications:is(notificationLevel)
    if isGuildDefaultMessageNotifications then
        self.default_message_notifications = notificationLevel
    end

    return self
end

--[=[
    Sets the explicit content filter level for this guild.
]=]
function GuildBuilder.prototype.setExplicitContentFilter(self: GuildBuilder, contentFilterLevel: GuildApi.GuildExplicitContentFilter)
    local isExplicitContentFilter = GuildExplicitContentFilter:is(contentFilterLevel)
    if isExplicitContentFilter then
        self.explicit_content_filter = contentFilterLevel
    end

    return self
end

--[=[
	Sets the discord Afk Voice Channel for this guild.
]=]
function GuildBuilder.prototype.setAfkChannelId(self: GuildBuilder, channelId: string)
	self.afk_channel_id = channelId

	return self
end

--[=[
	Sets the timeout for members in discord voice channels. Valid inputs are:

	- 60
	- 300
	- 900
	- 1800
	- 3600
]=]
function GuildBuilder.prototype.setAfkTimeout(self: GuildBuilder, timeout: GuildApi.AFKTimeout)
    local isAFKTimeout = AFKTimeout:is(timeout)

    if isAFKTimeout then
        self.afk_timeout = timeout
    end

	return self
end

--[=[
	Sets the icon of this guild. imageData must be a base64, 1024x1024, encoded binary data for either a png/jpeg/gif
]=]
function GuildBuilder.prototype.setIcon(self: GuildBuilder, imageData: string)
	self.icon = imageData

	return self
end

--[=[
	Sets the owner of this guild.
]=]
function GuildBuilder.prototype.setOwnerId(self: GuildBuilder, ownerId: string)
	self.owner_id = ownerId

	return self
end

function GuildBuilder.prototype.setSplash(self: GuildBuilder, imageData: string)
	self.splash = imageData

	return self
end

function GuildBuilder.prototype.setDiscoverySplash(self: GuildBuilder, imageData: string)
	self.discovery_splash = imageData

	return self
end

function GuildBuilder.prototype.setBanner(self: GuildBuilder, imageData: string)
	self.banner = imageData

	return self
end

function GuildBuilder.prototype.setSystemChannelId(self: GuildBuilder, channelId: Snowflake)
	self.system_channel_id = channelId

	return self
end

function GuildBuilder.prototype.setSystemChannelFlags(self: GuildBuilder, flags: GuildApi.GuildSystemChannelFlag)
    local isFlags = GuildSystemChannelFlags:is(flags)

    if isFlags then
        self.system_channel_flags = flags 
    end

	return self
end

function GuildBuilder.prototype.setRulesChannelId(self: GuildBuilder, channelId: Snowflake)
	self.rules_channel_id = channelId

	return self
end

function GuildBuilder.prototype.setPublicUpdateChannelId(self: GuildBuilder, channelId: Snowflake)
	self.public_updates_channel_id = channelId

	return self
end

function GuildBuilder.setPreferredLocale(self: GuildBuilder, locale: string)
    self.preferred_locale = locale

    return self
end

function GuildBuilder.addFeature(self: GuildBuilder, feature: GuildApi.GuildFeature)
    local isFeature = GuildFeatures:is(feature)

    if isFeature then
        table.insert(self.features, feature)
    end

    return self
end

function GuildBuilder.prototype.setDescription(self: GuildBuilder, description: string)
    self.description = description

    return self
end

function GuildBuilder.prototype.setPremiumProgressBarEnabled(self: GuildBuilder, enabled: boolean)
   self.premium_progress_bar_enabled = enabled

    return self
end

function GuildBuilder.prototype.addRole(self: GuildBuilder, role: RoleBuilder.RoleBuilder | PermissionsApi.APIRole)
    if not is(role, 'RoleBuilder') then
        role = RoleBuilder.new(role :: PermissionsApi.APIRole)
    end

    table.insert(self.roles, role :: RoleBuilder.RoleBuilder)

    return self
end

function GuildBuilder.prototype.addChannel(self: GuildBuilder, channel: ChannelBuilder.ChannelBuilder | ChannelApi.APIChannel)
    if not is(channel, 'ChannelBuilder') then
        channel = ChannelBuilder.new(channel :: ChannelApi.APIChannel) 
    end

    table.insert(self.channels, channel :: ChannelBuilder.ChannelBuilder)

    return self
end

function GuildBuilder.prototype.toJSON(self: GuildBuilder): GuildApi.APIGuild
    local roleObjects = {}
	local channelObjects = {}

	for _, role in self.roles do
		table.insert(roleObjects, role:toJSON())
	end

	for _, channel in self.channels do
		table.insert(channelObjects, channel:toJSON())
	end

    return {
        name = self.name,
        icon = self.icon,
        splash = self.splash,
        banner = self.banner,
        description = self.description,
        features = self.features,
        vanity_url_code = self.vanity_url_code,
        verification_level = self.verification_level,
        discovery_splash = self.discovery_splash,
        premium_progress_bar_enabled = self.premium_progress_bar_enabled,
        safety_alterts_channel_id = self.safety_alerts_channel_id,
        owner_id = self.owner_id,
        permissions = self.permissions,
        afk_channel_id = self.afk_channel_id,
        afk_timeout = self.afk_timeout,
        widget_enabled = self.widget_enabled,
        widget_channel_id = self.widget_channel_id,
        default_message_notifications = self.default_message_notifications,
        explicit_content_filter = self.explicit_content_filter,
        roles = roleObjects,
        channels = channelObjects,
        preferred_locale = self.preferred_locale or 'en-US',
        public_updates_channel_id = self.public_updates_channel_id,
        rules_channel_id = self.rules_channel_id,
        system_channel_id = self.system_channel_id,
        system_channel_flags = self.system_channel_flags,
    }
end


--[=[
	Creates a new instance of GuildBuilder.
]=]
function GuildBuilder.interface.new(opt: GuildApi.APIGuild?): GuildBuilder
    local actualOpt = opt or {}

    if not (actualOpt :: any).channels then
        (actualOpt :: any).channels = {}
    end

    if not (actualOpt :: any).roles then
        (actualOpt :: any).roles = {}
    end

    if not (actualOpt :: any).features then
        (actualOpt :: any).features = {}
    end

    if #(actualOpt :: GuildApi.APIGuild).channels then
        for i, channel in (actualOpt :: any).channels do
            (actualOpt :: any).channels[i] = ChannelBuilder.new(channel)
        end
    end

    if #(actualOpt :: GuildApi.APIGuild).roles then
        for i, role in (actualOpt :: any).roles do
            (actualOpt :: any).channels[i] = RoleBuilder.new(role)
        end
    end

    if (actualOpt :: PermissionsApi.APIRole).permissions then
        (actualOpt :: PermissionsApi.APIRole).permissions = PermissionsBitField.from((actualOpt :: PermissionsApi.APIRole).permissions) :: any
    end

    return (class(actualOpt, GuildBuilder.prototype) :: any) :: GuildBuilder
end

export type GuildBuilderProperties = {
    name: string,
    icon: string?,
    splash: string?,
    banner: string?,
    description: string?,
    features: { string },
    verification_level: GuildApi.GuildVerificationLevel,
    vanity_url_code: string?,
    discovery_splash: string?,
    premium_progress_bar_enabled: boolean,
    safety_alerts_channel_id: string?,
    owner_id: Snowflake,
    permissions: Permissions?,
    afk_channel_id: Snowflake?,
    afk_timeout: number,
    widget_enabled: boolean?,
    widget_channel_id: string?,
    default_message_notifications: GuildApi.GuildDefaultMessageNotifications,
    explicit_content_filter: GuildApi.GuildExplicitContentFilter,
    roles: { RoleBuilder.RoleBuilder },
    features: { GuildApi.GuildFeature },
    channels: { ChannelBuilder.ChannelBuilder },
    preferred_locale: string,
    public_updates_channel_id: Snowflake?,
    rules_channel_id: Snowflake?,
    system_channel_id: Snowflake?,
    system_channel_flags: number,
}

export type GuildBuilder = typeof(GuildBuilder.prototype) & GuildBuilderProperties

return GuildBuilder.interface