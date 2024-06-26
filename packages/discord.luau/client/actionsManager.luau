--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Event = require("@deps/event")

-- Structures
local DiscordMessage = require("../structures/message")
local DiscordChannel = require("../structures/channel")
local DiscordUser = require("../structures/user")
local DiscordGuild = require("../structures/guild")
local DiscordGuildMember = require("../structures/guildMember")
local DiscordInteraction = require("../structures/interaction")
local ChatInputCommandInteraction = require("../structures/chatInputCommandInteraction")


-- API
local RESTApi = require("@discordluau/api/rest")

-- Enumerations
local Routes = RESTApi.Routes

--[=[
	@class ActionsManager

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local ActionsManager = {}

ActionsManager.prototype = {}
ActionsManager.interface = {}

ActionsManager.prototype["_type"] = "ActionsManager"

function ActionsManager.interface.new(client): ActionsManager
	local self = class({
		client = client,
		getChannel = function(channelId: string?): DiscordChannel.Channel?
			if not channelId then
				return nil
			end
			local channel = client.channels:fetch(channelId, function(): DiscordChannel.Channel?
				local channelData = client.rest:get(Routes.channel(channelId))
				local data: DiscordChannel.Channel? = nil
				if channelData then
					data = DiscordChannel.from(client, channelData) :: DiscordChannel.Channel
				end
	
				return data
			end)

			return channel
		end,
		ready = Event.new(),

		messageCreate = Event.new(),
		messageUpdate = Event.new(),
		messageDelete = Event.new(),
		MessageBulkDelete = Event.new(),

		channelCreate = Event.new(),
		ChannelUpdate = Event.new(),
		channelDelete = Event.new(),

		userUpdate = Event.new(),

		channelPinsCreate = Event.new(),

		guildMember = Event.new(),
		guildUpdate = Event.new(),
		onGuildDelete = Event.new(),

		guildBanAdd = Event.new(),
		guildBanRemove = Event.new(),

		guildMemberAdd = Event.new(),
		guildMemberLeft = Event.new(),
		guildMemberUpdate = Event.new(),

		interactionCreate = Event.new(),
	}, ActionsManager.prototype)
	return (self :: any) :: ActionsManager
end

export type ActionsManager = typeof(ActionsManager.prototype) & {
	client: any,
	getChannel: (channelId: string) -> DiscordChannel.Channel?,
	ready: Event.Event<nil>,

	messageCreate: Event.Event<DiscordMessage.Message>,
	messageUpdate: Event.Event<DiscordMessage.Message>,
	messageDelete: Event.Event<DiscordMessage.Message>,
	messageBulkDelete: Event.Event<{ channelId: string, guildId: string, ids: { string } }>,

	channelCreate: Event.Event<DiscordChannel.Channel>,
	channelUpdate: Event.Event<DiscordChannel.Channel>,
	channelDelete: Event.Event<DiscordChannel.Channel>,

	userUpdate: Event.Event<DiscordUser.User>,

	channelPinsUpdate: Event.Event<{ guildId: string, channelId: string, lastPinTimestamp: string }>,

	guildCreate: Event.Event<DiscordGuild.Guild>,
	guildUpdate: Event.Event<DiscordGuild.Guild>,
	guildDelete: Event.Event<DiscordGuild.Guild>,

	guildBanAdd: Event.Event<{ guildId: string, user: DiscordUser.User }>,
	guildBanRemove: Event.Event<{ guildId: string, user: DiscordUser.User }>,

	guildMemberAdd: Event.Event<DiscordGuildMember.GuildMember & { guildId: string }>,
	guildMemberRemove: Event.Event<{ guildId: string, user: DiscordUser.User }>,
	guildMemberUpdate: Event.Event<{
		guildId: string,
		roles: { string },
		user: DiscordUser.User,
		nick: string?,
		avatar: string,
		joinedAt: string,
		premiumSince: string,
		deaf: boolean?,
		mute: boolean?,
		pending: boolean?,
		communicationDisabledUntil: string?
	}>,

	interactionCreate: Event.Event<DiscordInteraction.Interaction | ChatInputCommandInteraction.ChatInputCommandInteraction>,
}

return ActionsManager.interface