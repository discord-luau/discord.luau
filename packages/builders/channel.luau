local class = require("@std/class")
local enum = require("@std/enum")

-- API
local GlobalApi = require("@discordluau/api/global")
local ChannelApi = require("@discordluau/api/payloads/channel")

-- Core Package Utilities
local PermissionsBitField = require("@discordluau/discord.luau/utils/permissionsBitField")

-- Enumerations
local ChannelType = ChannelApi.ChannelType
local ForumLayoutType = ChannelApi.ForumLayoutType
local OverwriteType = ChannelApi.OverwriteType
local SortOrderType = ChannelApi.SortOrderType
local VideoQualityMode = ChannelApi.VideoQualityMode

type APIChannel = ChannelApi.APIChannel
type ChannelType = ChannelApi.ChannelType
type ForumLayoutType = ChannelApi.ForumLayoutType
type VideoQualityMode = ChannelApi.VideoQualityMode
type Permissions = GlobalApi.Permissions
type SortOrderType = ChannelApi.SortOrderType
type OverwriteType = ChannelApi.OverwriteType

local ChannelBuilder = {}

ChannelBuilder.interface = {}
ChannelBuilder.prototype = {}

ChannelBuilder.prototype.__type = 'ChannelBuilder'

function ChannelBuilder.prototype.setType(self: ChannelBuilder, type: ChannelType)
    local isChannelType = ChannelType:is(type)

    self.type = type

    return self
end

function ChannelBuilder.prototype.setBitrate(self: ChannelBuilder, bitrate: number)
    self.bitrate = bitrate
    
    return self
end

function ChannelBuilder.prototype.setRegion(self: ChannelBuilder, regionId: number)
    self.region = regionId

    return self
end

function ChannelBuilder.prototype.setVideoQualityMode(self: ChannelBuilder, videoQualityMode: VideoQualityMode)
    local isVideoQualityMode = VideoQualityMode:is(videoQualityMode)
    if isVideoQualityMode then
        self.video_quality_mode = videoQualityMode
    end

    return self
end

function ChannelBuilder.prototype.addMemberOverwrite(
    self: ChannelBuilder,
    memberId: string,
    allowedPermissions: PermissionsBitField.PermissionsBitField | Permissions,
    deniedPermissions: PermissionsBitField.PermissionsBitField | Permissions
)
    if typeof(allowedPermissions) == "string" then
        allowedPermissions = PermissionsBitField.from(allowedPermissions)
    end

    if typeof(deniedPermissions) == "string" then
        deniedPermissions = PermissionsBitField.from(deniedPermissions)
    end

    table.insert(self.permission_overwrites, {
        id = memberId,
        type = 1,
        allow = allowedPermissions :: PermissionsBitField.PermissionsBitField,
        deny = deniedPermissions :: PermissionsBitField.PermissionsBitField
    })

    return self
end

function ChannelBuilder.prototype.addRoleOverwrite(
    self: ChannelBuilder,
    roleId: string,
    allowedPermissions: PermissionsBitField.PermissionsBitField | Permissions,
    deniedPermissions: PermissionsBitField.PermissionsBitField | Permissions
)
    if typeof(allowedPermissions) == "string" then
        allowedPermissions = PermissionsBitField.from(allowedPermissions)
    end

    if typeof(deniedPermissions) == "string" then
        deniedPermissions = PermissionsBitField.from(deniedPermissions)
    end

    table.insert(self.permission_overwrites, {
        id = roleId,
        type = 0,
        allow = allowedPermissions :: PermissionsBitField.PermissionsBitField,
        deny = deniedPermissions :: PermissionsBitField.PermissionsBitField
    })

    return self
end

function ChannelBuilder.prototype.setDefaultReactionEmoji(self: ChannelBuilder, emojiId: string, emojiName: string)
    self.default_reaction_emoji = {
        emoji_id = emojiId,
        emoji_name = emojiName
    }

    return self
end

function ChannelBuilder.prototype.setDefaultSortOrder(self: ChannelBuilder, sortOrder: SortOrderType)
    local isSortOrderType = SortOrderType:is(sortOrder)
    if isSortOrderType then
        self.sort_order = sortOrder
    end

    return self
end

function ChannelBuilder.prototype.setDefaultForumLayout(self: ChannelBuilder, forumLayoutType: ForumLayoutType)
    local isForumLayoutType = ForumLayoutType:is(forumLayoutType)
    if isForumLayoutType then
        self.forum_layout = forumLayoutType
    end

    return self
end

function ChannelBuilder.prototype.setPosition(self: ChannelBuilder, position: number)
    self.position = position

    return self
end

function ChannelBuilder.prototype.setTopic(self: ChannelBuilder, topic: string)
    self.topic = topic

    return self
end

function ChannelBuilder.prototype.setNSFW(self: ChannelBuilder, nsfw: boolean)
    self.nsfw = nsfw

    return self
end

function ChannelBuilder.setRateLimitPerUser(self: ChannelBuilder, limit: number)
    self.rate_limit_per_user = limit

    return self
end

function ChannelBuilder.setParentId(self: ChannelBuilder, parentId: string)
    self.parent_id = parentId

    return self
end

function ChannelBuilder.prototype.setDefaultAutoArchiveDuration(self: ChannelBuilder, duration: number)
    self.default_auto_archive_duration = duration

    return self
end

function ChannelBuilder.prototype.setDefaultThreadRateLimitPerUser(self: ChannelBuilder, limit: number)
    self.thread_rate_limit_per_user = limit

    return self
end


function ChannelBuilder.prototype.toJSON(self: ChannelBuilder): APIChannel
    local overwrites = {}

    for _, object in self.permission_overwrites do
        table.insert(overwrites, {
            id = object.id,
            type = object.type,
            allow = object.allow:getValue(),
            deny = object.deny:getValue()
        })
    end

    return {
        name = self.name,
        bitrate = self.bitrate,
        type = self.type,
        rtc_region = self.region,
        video_quality_mode = self.video_quality_mode,
        sort_order = self.sort_order,
        forum_layout = self.forum_layout,
        position = self.position,
        topic = self.topic,
        nsfw = self.nsfw,
        rate_limit_per_user = self.rate_limit_per_user,
        parent_id = self.parent_id,
        default_auto_archive_duration = self.default_auto_archive_duration,
        thread_rate_limit_per_user = self.thread_rate_limit_per_user,
        permission_overwrites = #overwrites > 0 and overwrites or nil,
        default_reaction_emoji = self.default_reaction_emoji
    }
end

function ChannelBuilder.interface.new(opt: APIChannel?): ChannelBuilder
    local actualOpt = opt or {}

    if (actualOpt :: APIChannel).permission_overwrites == nil then
        (actualOpt :: APIChannel).permission_overwrites = {}
    end

    for i, object in (actualOpt :: any).permission_overwrites do
        (actualOpt :: any).permissions[i] = {
            id = object.id,
            type = object.type,
            allow = PermissionsBitField.from(object.allow),
            deny = PermissionsBitField.from(object.deny)
        }
    end

    return (class(actualOpt, ChannelBuilder.prototype) :: any) :: ChannelBuilder
end

export type ChannelBuilder = typeof(ChannelBuilder.prototype) & {
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
        {
            id: string,
            type: number,
            allow: PermissionsBitField.PermissionsBitField,
            deny: PermissionsBitField.PermissionsBitField
        }
    }
}

return ChannelBuilder.interface