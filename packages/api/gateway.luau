local Table = require("@deps/table")
local GatewayIntentBits = {
	Guilds = bit32.lshift(1, 0),
	GuildMembers = bit32.lshift(1, 1),
	GuildModeration = bit32.lshift(1, 2),
	GuildEmojisAndStickers = bit32.lshift(1, 3),
	GuildIntegrations = bit32.lshift(1, 4),
	GuildWebhooks = bit32.lshift(1, 5),
	GuildInvites = bit32.lshift(1, 6),
	GuildVoiceState = bit32.lshift(1, 7),
	GuildPresences = bit32.lshift(1, 8),
	GuildMessage = bit32.lshift(1, 9),
	GuildMessageReactions = bit32.lshift(1, 10),
	GuildMessageTyping = bit32.lshift(1, 11),

	DirectMessage = bit32.lshift(1, 12),
	DirectMessageReactions = bit32.lshift(1, 13),
	DirectMessageTyping = bit32.lshift(1, 14),

	GuildMessageContent = bit32.lshift(1, 15),
	GuildScheduledEvents = bit32.lshift(1, 16),
	GuildModerationConfiguration = bit32.lshift(1, 20),
	GuildModerationExecution = bit32.lshift(1, 21),
}

local All = Table.Values(GatewayIntentBits) :: { number }
local Default = Table.ValuesExcept(GatewayIntentBits, { 'GuildPresence', 'GuildMembers', 'GuildMessageContent' }) :: { number}

GatewayIntentBits.All = All
GatewayIntentBits.Default = Default

return {
    GatewayIntentBits = GatewayIntentBits
} 