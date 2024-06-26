type Snowflake = string | number
local Array = require("@deps/polyfill/array")
local Voice = require("voice")
local Websocket = require("websocket")

local API_VERSION = 10

local RouteBases = {
    api = `https://discord.com/api/v{API_VERSION}`,
    cdn = 'https://cdn.discordapp.com',
	invite =  'https://discord.gg',
	template = 'https://discord.new',
	gift = 'https://discord.gift',
	scheduledEvent = 'https://discord.com/events',
}

local Routes = {
    gateway = "/gateway",
    gatewayBot = "/gateway/bot",
    guildAutoModerationRules = function (guildId: Snowflake)
		return `/guilds/{guildId}/auto-moderation/rules`
	end,
	guildAutoModerationRule = function(guildId: Snowflake, ruleId: Snowflake)
		return `/guilds/{guildId}/auto-moderation/rules/{ruleId}`
    end,
    channelPosition = function(channelId: Snowflake)
        return `/channels/{channelId}/channels`
    end,
    channel = function(channelId: Snowflake)
        return `/channels/{channelId}`
    end,
    channelMessages = function(channelId: Snowflake)
        return `/channels/{channelId}/messages`
    end,
    channelMessage = function(channelId: Snowflake, messageId: Snowflake)
        return `/channels/{channelId}/messages/{messageId}`
    end,
    channelMessageCrosspost = function(channelId: Snowflake, messageId: Snowflake)
        return `/channels/{channelId}/messages/{messageId}/crosspost`
    end,
    channelMessageOwnReaction = function(channelId: Snowflake, messageId: Snowflake, emoji: Snowflake)
        return `/channels/{channelId}/messages/{messageId}/reactions/{emoji}/@me`
    end,
    channelMessageUserReaction = function(channelId: Snowflake, messageId: Snowflake, emoji: Snowflake, userId: Snowflake)
        return `/channels/{channelId}/messages/{messageId}/reactions/{emoji}/{userId}`
    end,
    channelMessageReaction = function(channelId: Snowflake, messageId: Snowflake, emoji: Snowflake)
        return `/channels/{channelId}/messages/{messageId}/reactions/{emoji}`
    end,
    channelNessageAllReactions = function(channelId: Snowflake, messageId: Snowflake)
        return `/channels/{channelId}/messages/{messageId}/reactions/`
    end,
    channelBulkDelete = function(channelId: Snowflake)
        return `/channels/{channelId}/messages/bulk-delete`
    end,
    channelPermission = function(channelId: Snowflake, overwriteId: Snowflake)
        return `/channels/{channelId}/permissions/{overwriteId}`
    end,
    channelInvites = function(channelId: Snowflake)
        return `/channels/{channelId}/invites`
    end,
    channelFollowers = function(channelId: Snowflake)
        return `/channels/{channelId}/followers`
    end,
    channelTyping = function(channelId: Snowflake)
        return `/channels/{channelId}/typing`
    end,
    channelPins = function(channelId: Snowflake)
        return `/channels/{channelId}/pins`
    end,
    channelPin = function(channelId: Snowflake, messageId: Snowflake)
        return `/channels/{channelId}/pins/{messageId}`
    end,
    channelRecipient = function(channelId: Snowflake, userId: Snowflake)
        return `/channels/{channelId}/recipients/{userId}`
    end,
    guildEmojis = function(guildId: Snowflake)
        return `/guilds/{guildId}/emojis`
    end,
    guildEmoji = function(guildId: Snowflake, emojiId: Snowflake)
        return `/guilds/{guildId}/emojis/{emojiId}`
    end,
    guilds = function()
        return `/guilds`
    end,
    guildAuditLog = function(guildId: Snowflake)
        return `/guilds/{guildId}/audit-logs`
    end,
    guild = function(guildId: Snowflake)
        return `/guilds/{guildId}`
    end,
    guildBulkBan = function(guildId: Snowflake)
        return `/guilds/{guildId}`
    end,
    guildPreview = function(guildId: Snowflake)
        return `/guilds/{guildId}/bulk-ban`
    end,
    guildChannels = function(guildId: Snowflake)
        return `/guilds/{guildId}/channels`
    end,
    guildMember = function(guildId: Snowflake, userId: Snowflake?)
        local user = userId or '@me'
        return `/guilds/{guildId}/members/{user}`
    end,
    guildMembers = function(guildId: Snowflake)
        return `/guilds/{guildId}/members`
    end,
    guildMembersWithLimit = function(guildId: Snowflake, limit: Snowflake, after: Snowflake)
        return `/guilds/{guildId}/members?limit={limit}&after={after}`
    end,
    guildMembersSearch = function(guildId: Snowflake)
        return `/guilds/{guildId}/members/search`
    end,
    guildMembersSearchQuery = function(guildId: Snowflake, query: Snowflake, limit: Snowflake)
        return `/guilds/{guildId}/members/search?query={query}&limit={limit}`
    end,
    guildCurrentMemberNickname = function(guildId: Snowflake)
        return `/guilds/{guildId}/members/@me/nick`
    end,
    guildMemberRole = function(guildId: Snowflake, memberId: Snowflake, roleId: Snowflake)
        return `/guilds/{guildId}/members/{memberId}/roles/{roleId}`
    end,
    guildMFA = function(guildId: Snowflake)
        return `/guilds/{guildId}/mfa`
    end,
    guildBans = function(guildId: Snowflake)
        return `/guilds/{guildId}/bans`
    end,
    guildBan = function(guildId: Snowflake, userId: Snowflake)
        return `/guilds/{guildId}/bans/{userId}`
    end,
    guildRoles = function(guildId: Snowflake)
        return `/guilds/{guildId}/roles`
    end,
    guildRole = function(guildId: Snowflake, roleId: Snowflake)
        return `/guilds/{guildId}/roles/{roleId}`
    end,
    guildPrune = function(guildId: Snowflake)
        return `/guilds/{guildId}/prune`
    end,
    guildInvites = function(guildId: Snowflake)
        return `/guilds/{guildId}/invites`
    end,
    guildIntegrations = function(guildId: Snowflake)
        return `/guilds/{guildId}/integrations`
    end,
    guildIntegration = function(guildId: Snowflake, integrationId: Snowflake)
        return `/guilds/{guildId}/integrations/{integrationId}`
    end,
    invite = function(code: Snowflake)
        return `/invites/{code}`
    end,
	threads = function(parentId: Snowflake, messageId: Snowflake?)
		local parts = { '', 'channels', tostring(parentId) }

        if messageId then
            Array.push(parts, 'messages', tostring(messageId))
        end

        Array.push(parts, 'threads')

        return Array.join(parts, '/')
    end,
    threadMembers = function(threadId: Snowflake, userId: Snowflake?)
        local id: string = userId and tostring(userId) or '@me'
        local parts = { '', 'channels', tostring(threadId), 'thread-members', id }

        return Array.join(parts, '/') 
    end,
    userGuilds = function()
        return `/users/@me/guilds`
    end,
    userGuildMember = function(guildId: Snowflake)
        return `/users/@me/guilds/{guildId}/member`
    end,
    userGuild = function(guildId: Snowflake)
        return `/users/@me/guilds/{guildId}`
    end,
    userChannels = function()
        return `/users/@me/channels`
    end,
    userConnections = function()
        return `/users/@me/connections`
    end,
    channelWebhooks = function(channelId: Snowflake)
        return `/channels/{channelId}/webhooks`
    end,
    guildWebhooks = function(guildId: Snowflake)
        return `/guilds/{guildId}/webhooks`
    end,
    webhook = function(webhookId: Snowflake, webhookToken: Snowflake?)
        local parts = { '', 'webhooks', tostring(webhookId)}
        if webhookToken then
            table.insert(parts, tostring(webhookToken))
        end

        return table.concat(parts, "/")
    end,
    webhookMessage = function(webhookId: Snowflake, webhookToken: Snowflake, messageId: Snowflake?)
        local id = messageId or '@original'
        return `/webhooks/{webhookId}/{webhookToken}/messages/{id}`
    end,
    applicationCommands = function(applicationId: Snowflake)
        return `/applications/{applicationId}/commands`
    end,
    applicationCommand = function(applicationId: Snowflake, commandId: Snowflake)
        return `/applications/{applicationId}/commands/{commandId}`
    end,
    applicationGuildCommands = function(applicationId: Snowflake, guildId: Snowflake)
        return `/applications/{applicationId}/guilds/{guildId}/commands`
    end,
    applicationGuildCommand = function(applicationId: Snowflake, guildId: Snowflake, commandId: Snowflake)
        return `/applications/{applicationId}/guilds/{guildId}/commands/{commandId}`
    end,
    interactionCallback = function(interactionId: Snowflake, interactionToken: Snowflake)
        return `/interactions/{interactionId}/{interactionToken}/callback`
    end
}

return {
    Routes = Routes,
    APIVersion = API_VERSION,
    RouteBases = RouteBases,
    Voice = Voice,
    Websocket = Websocket
}