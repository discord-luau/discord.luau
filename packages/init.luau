--[=[
    A Discord API wrapper written in Luau, expected to run under the Lune runtime.
]=]
local DiscordLuau = {}

-- API
local GatewayApi = require("api/gateway")
local RESTApi = require("api/rest")

-- Builders
local AttachmentBuilder = require('builders/messages/attachment')
local EmbedBuilder = require('builders/messages/embed')
local MessageBuilder = require('builders/messages/message')

local AutoModerationRuleBuilder = require('builders/guilds/autoModerationRule')
local GuildBuilder = require('builders/guilds/guild')
local MemberBuilder = require('builders/guilds/member')
local RoleBuilder = require('builders/guilds/role')

local ActionRowBuilder = require('builders/components/actionRow')
local ButtonBuilder = require('builders/components/button')
local ChannelSelectMenuBuilder = require('builders/components/selectMenu/channelSelectMenu')
local MentionableSelectMenuBuilder = require('builders/components/selectMenu/mentionableSelectMenu')
local RoleSelectMenuBuilder = require('builders/components/selectMenu/roleSelectMenu')
local StringSelectMenuBuilder = require('builders/components/selectMenu/stringSelectMenu')
local StringSelectMenuOptionBuilder =
    require('builders/components/selectMenu/stringSelectMenuOption')
local TextInputBuilder = require('builders/components/textInput')
local UserSelectMenuBuilder = require('builders/components/selectMenu/userSelectMenu')

local ModalBuilder = require('builders/interactions/modal')
local SlashCommandBuilder = require('builders/interactions/slashCommand')

-- Client
local Client = require('discord.luau/client/client')

-- Structures
local Activity = require('discord.luau/structures/activity')
local AnnouncementChannel = require('discord.luau/structures/announcementChannel')
local AnnouncementThreadChannel = require('discord.luau/structures/announcementThreadChannel')
local ApplicationCommand = require('discord.luau/structures/applicationCommand')
local AutoModerationRule = require('discord.luau/structures/autoModerationRule')
local CategoryChannel = require('discord.luau/structures/categoryChannel')
local Channel = require('discord.luau/structures/channel')
local ChatInputCommandInteraction = require('discord.luau/structures/chatInputCommandInteraction')
local ClientUser = require('discord.luau/structures/clientUser')
local DMChannel = require('discord.luau/structures/dmChannel')
local DirectoryChannel = require('discord.luau/structures/directoryChannel')
local Emoji = require('discord.luau/structures/emoji')
local ForumChannel = require('discord.luau/structures/forumChannel')
local GroupChannel = require('discord.luau/structures/groupChannel')
local Guild = require('discord.luau/structures/guild')
local GuildBan = require('discord.luau/structures/guildBan')
local GuildMember = require('discord.luau/structures/guildMember')
local Integration = require('discord.luau/structures/integration')
local Interaction = require('discord.luau/structures/interaction')
local Invite = require('discord.luau/structures/invite')
local MediaChannel = require('discord.luau/structures/mediaChannel')
local Message = require('discord.luau/structures/message')
local Presence = require('discord.luau/structures/presence')
local PrivateThreadChannel = require('discord.luau/structures/privateThreadChannel')
local PublicThreadChannel = require('discord.luau/structures/publicThreadChannel')
local Role = require('discord.luau/structures/role')
local StageChannel = require('discord.luau/structures/stageChannel')
local Sticker = require('discord.luau/structures/sticker')
local TextChannel = require('discord.luau/structures/textChannel')
local User = require('discord.luau/structures/user')
local VoiceChannel = require('discord.luau/structures/voiceChannel')

-- REST
local REST = require("rest")

-- Utilities Internal
local IntentsBitField = require("discord.luau/utils/intentsBitField")
local PermissionsBitField = require("discord.luau/utils/permissionsBitField")

-- Utils
local Collection = require("utils/collection")
local MessagePayload = require("utils/messagePayload")
local TypedCollection = require("utils/typedCollection")
local Transformers = require("utils/transformers")

-- Add to DiscordLuau class
DiscordLuau.GatewayIntentBits = GatewayApi.GatewayIntentBits
DiscordLuau.Routes = RESTApi.Routes

DiscordLuau.AttachmentBuilder = AttachmentBuilder
DiscordLuau.EmbedBuilder = EmbedBuilder
DiscordLuau.MessageBuilder = MessageBuilder

DiscordLuau.AutoModerationRuleBuilder = AutoModerationRuleBuilder
DiscordLuau.GuildBuilder = GuildBuilder
DiscordLuau.MemberBuilder = MemberBuilder
DiscordLuau.RoleBuilder = RoleBuilder

DiscordLuau.ActionRowBuilder = DiscordLuau.ActionRowBuilder
DiscordLuau.ButtonBuilder = ButtonBuilder
DiscordLuau.ChannelSelectMenuBuilder = ChannelSelectMenuBuilder
DiscordLuau.MentionableSelectMenuBuilder = MentionableSelectMenuBuilder
DiscordLuau.RoleSelectMenuBuilder = RoleSelectMenuBuilder
DiscordLuau.TextInputBuilder = TextInputBuilder
DiscordLuau.StringSelectMenuBuilder = StringSelectMenuBuilder
DiscordLuau.StringSelectMenuOptionBuilder = StringSelectMenuOptionBuilder
DiscordLuau.UserSelectMenuBuilder = UserSelectMenuBuilder

DiscordLuau.SlashCommandBuilder = SlashCommandBuilder
DiscordLuau.ModalBuilder = ModalBuilder

DiscordLuau.Activity = Activity
DiscordLuau.AnnouncementChannel = AnnouncementChannel
DiscordLuau.AnnouncementThreadChannel = AnnouncementThreadChannel
DiscordLuau.ApplicationCommand = ApplicationCommand
DiscordLuau.AutoModerationRule = AutoModerationRule
DiscordLuau.CategoryChannel = CategoryChannel
DiscordLuau.Channel = Channel
DiscordLuau.ChatInputCommandInteraction = ChatInputCommandInteraction
DiscordLuau.ClientUser = ClientUser
DiscordLuau.DirectoryChannel = DirectoryChannel
DiscordLuau.DMChannel = DMChannel
DiscordLuau.Emoji = Emoji
DiscordLuau.ForumChannel = ForumChannel
DiscordLuau.GroupChannel = GroupChannel
DiscordLuau.Guild = Guild
DiscordLuau.GuildBan = GuildBan
DiscordLuau.GuildMember = GuildMember
DiscordLuau.Integration = Integration
DiscordLuau.Interaction = Interaction
DiscordLuau.Invite = Invite
DiscordLuau.MediaChannel = MediaChannel
DiscordLuau.Message = Message
DiscordLuau.Presence = Presence
DiscordLuau.PrivateThreadChannel = PrivateThreadChannel
DiscordLuau.PublicThreadChannel = PublicThreadChannel
DiscordLuau.Role = Role
DiscordLuau.StageChannel = StageChannel
DiscordLuau.Sticker = Sticker
DiscordLuau.TextChannel = TextChannel
DiscordLuau.User = User
DiscordLuau.VoiceChannel = VoiceChannel

DiscordLuau.Client = Client

DiscordLuau.REST = REST.REST
DiscordLuau.CDN = REST.CDN
DiscordLuau.calculateUserDefaultAvatarIndex = REST.calculateUserDefaultAvatarIndex

DiscordLuau.IntentsBitField = IntentsBitField
DiscordLuau.PermissionsBitField = PermissionsBitField

DiscordLuau.Collection = Collection
DiscordLuau.MessagePayload = MessagePayload
DiscordLuau.TypedCollection = TypedCollection
DiscordLuau.Transformers = Transformers

-- Types
export type AttachmentBuilder = AttachmentBuilder.AttachmentBuilder
export type EmbedBuilder = EmbedBuilder.EmbedBuilder
export type MessageBuilder = MessageBuilder.MessageBuilder

export type AutoModerationRuleBuilder = AutoModerationRuleBuilder.AutoModerationRuleBuilder
export type GuildBuilder = GuildBuilder.GuildBuilder
export type MemberBuilder = MemberBuilder.MemberBuilder
export type RoleBuilder = RoleBuilder.RoleBuilder

export type ActionRowBuilder = ActionRowBuilder.ActionRowBuilder
export type ButtonBuilder = ButtonBuilder.ButtonBuilder
export type ChannelSelectMenuBuilder = ChannelSelectMenuBuilder.ChannelSelectMenuBuilder
export type MentionableSelectMenuBuilder = MentionableSelectMenuBuilder.MentionableSelectMenuBuilder
export type RoleSelectMenuBuilder = RoleSelectMenuBuilder.RoleSelectMenuBuilder
export type TextInputBuilder = TextInputBuilder.TextInputBuilder
export type StringSelectMenuBuilder = StringSelectMenuBuilder.StringSelectMenuBuilder
export type StringSelectMenuOptionBuilder = StringSelectMenuOptionBuilder.StringSelectMenuOptionBuilder
export type UserSelectMenuBuilder = UserSelectMenuBuilder.UserSelectMenuBuilder

export type SlashCommandBuilder = SlashCommandBuilder.SlashCommandBuilder
export type ModalBuilder = ModalBuilder.ModalBuilder

export type Activity = Activity.Activity
export type AnnouncementChannel = AnnouncementChannel.AnnouncementChannel
export type AnnouncementThreadChannel = AnnouncementThreadChannel.AnnouncementThreadChannel
export type ApplicationCommand = ApplicationCommand.ApplicationCommand
export type AutoModerationRule = AutoModerationRule.AutoModerationRule
export type CategoryChannel = CategoryChannel.CategoryChannel
export type Channel = Channel.Channel
export type ChatInputCommandInteraction = ChatInputCommandInteraction.ChatInputCommandInteraction
export type ClientUser = ClientUser.ClientUser
export type DirectoryChannel = DirectoryChannel.DirectoryChannel
export type DMChannel = DMChannel.DMChannel
export type Emoji = Emoji.Emoji
export type ForumChannel = ForumChannel.ForumChannel
export type GroupChannel = GroupChannel.GroupChannel
export type Guild = Guild.Guild
export type GuildBan = GuildBan.GuildBan
export type GuildMember = GuildMember.GuildMember
export type Integration = Integration.Integration
export type Interaction = Interaction.Interaction
export type Invite = Invite.Invite
export type MediaChannel = MediaChannel.MediaChannel
export type Message = Message.Message
export type Presence = Presence.Presence
export type PrivateThreadChannel = PrivateThreadChannel.PrivateThreadChannel
export type PublicThreadChannel = PublicThreadChannel.PublicThreadChannel
export type Role = Role.Role
export type StageChannel = StageChannel.StageChannel
export type Sticker = Sticker.Sticker
export type TextChannel = TextChannel.TextChannel
export type User = User.User
export type VoiceChannel = VoiceChannel.VoiceChannel

export type Client = Client.Client

export type REST = REST.REST
export type CDN = REST.CDN

export type IntentsBitField = IntentsBitField.IntentsBitField
export type PermissionsBitField = PermissionsBitField.PermissionsBitField

export type Collection<K, V> = Collection.Collection<K, V>
export type MessagePayload = MessagePayload.MessagePayload
export type TypedCollection<K, V> = TypedCollection.TypedCollection<K, V>

return DiscordLuau
