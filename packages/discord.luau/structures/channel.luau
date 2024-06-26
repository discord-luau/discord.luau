-- Structures
local AnnouncementChannel = require('@discordluau/discord.luau/structures/announcementChannel')
local AnnouncementThreadChannel =
    require('@discordluau/discord.luau/structures/announcementThreadChannel')
local CategoryChannel = require('@discordluau/discord.luau/structures/categoryChannel')
local DMChannel = require('@discordluau/discord.luau/structures/dmChannel')
local DirectoryChannel = require('@discordluau/discord.luau/structures/directoryChannel')
local ForumChannel = require('@discordluau/discord.luau/structures/forumChannel')
local GroupChannel = require('@discordluau/discord.luau/structures/groupChannel')
local MediaChannel = require('@discordluau/discord.luau/structures/mediaChannel')
local PrivateThreadChannel = require('@discordluau/discord.luau/structures/privateThreadChannel')
local PublicThreadChannel = require('@discordluau/discord.luau/structures/publicThreadChannel')
local StageChannel = require('@discordluau/discord.luau/structures/stageChannel')
local TextChannel = require('@discordluau/discord.luau/structures/textChannel')
local VoiceChannel = require('@discordluau/discord.luau/structures/voiceChannel')

-- API
local ChannelApi = require('@discordluau/api/payloads/channel')

-- Enumeration
local ChannelType = ChannelApi.ChannelType

--[=[
	The `DiscordChannel` class represents a generic Discord channel and provides various methods to interact with and manage the channel.
]=]
local DiscordChannel = {}

DiscordChannel.Prototype = {}
DiscordChannel.Interface = {}

function DiscordChannel.Interface.from(client: any, rawChannelData: RawChannelData): Channel
    if rawChannelData.type == ChannelType.Text then
        return TextChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.DM then
        return DMChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Voice then
        return VoiceChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Group then
        return GroupChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Category then
        return CategoryChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Announcement then
        return AnnouncementChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.AnnouncementThread then
        return AnnouncementThreadChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.PublicThread then
        return PublicThreadChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.PrivateThread then
        return PrivateThreadChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Stage then
        return StageChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Directory then
        return DirectoryChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Forum then
        return ForumChannel.new(client, rawChannelData)
    elseif rawChannelData.type == ChannelType.Media then
        return MediaChannel.new(client, rawChannelData)
    else
        error(`Unknown discord channel type '{rawChannelData.type}'`)
    end
end

type RawChannelData = {
    id: string,
    type: number,

    [any]: any,
}

export type Channel =
    TextChannel.TextChannel
    | DMChannel.DMChannel
    | VoiceChannel.VoiceChannel
    | GroupChannel.GroupChannel
    | CategoryChannel.CategoryChannel
    | AnnouncementChannel.AnnouncementChannel
    | AnnouncementThreadChannel.AnnouncementThreadChannel
    | PublicThreadChannel.PublicThreadChannel
    | PrivateThreadChannel.PrivateThreadChannel
    | StageChannel.StageChannel
    | DirectoryChannel.DirectoryChannel
    | ForumChannel.ForumChannel
    | MediaChannel.MediaChannel

return DiscordChannel.Interface
