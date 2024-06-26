--!nocheck

local DjsErrorCodes = require("./errorCodes")

local Messages = {
    [DjsErrorCodes.ClientInvalidOption] = function(prop, must) return "The " .. prop .. " option must be " .. must end,
    [DjsErrorCodes.ClientInvalidProvidedShards] = 'None of the provided shards were valid.',
    [DjsErrorCodes.ClientMissingIntents] = 'Valid intents must be provided for the Client.',
    [DjsErrorCodes.ClientNotReady] = function(action) return "The client needs to be logged in to " .. action end,

    [DjsErrorCodes.TokenInvalid] = 'An invalid token was provided.',
    [DjsErrorCodes.TokenMissing] = 'Request to use token, but token was unavailable to the client.',
    [DjsErrorCodes.ApplicationCommandPermissionsTokenMissing] = 'Editing application command permissions requires an OAuth2 bearer token, but none was provided.',

    [DjsErrorCodes.WSCloseRequested] = 'WebSocket closed due to user request.',
    [DjsErrorCodes.WSConnectionExists] = 'There is already an existing WebSocket connection.',
    [DjsErrorCodes.WSNotOpen] = function(data) data = data or 'data'; return "WebSocket not open to send " .. data end,
    [DjsErrorCodes.ManagerDestroyed] = 'Manager was destroyed.',

    [DjsErrorCodes.BitFieldInvalid] = function(bit) return "Invalid bitfield flag or number: " .. bit end,

    [DjsErrorCodes.ShardingInvalid] = 'Invalid shard settings were provided.',
    [DjsErrorCodes.ShardingRequired] = 'This session would have handled too many guilds - Sharding is required.',
    [DjsErrorCodes.InvalidIntents] = 'Invalid intent provided for WebSocket intents.',
    [DjsErrorCodes.DisallowedIntents] = 'Privileged intent provided is not enabled or whitelisted.',
    [DjsErrorCodes.ShardingNoShards] = 'No shards have been spawned.',
    [DjsErrorCodes.ShardingInProcess] = 'Shards are still being spawned.',
    [DjsErrorCodes.ShardingInvalidEvalBroadcast] = 'Script to evaluate must be a function',
    [DjsErrorCodes.ShardingShardNotFound] = function(id) return "Shard " .. id .. " could not be found." end,
    [DjsErrorCodes.ShardingAlreadySpawned] = function(count) return "Already spawned " .. count .. " shards." end,
    [DjsErrorCodes.ShardingProcessExists] = function(id) return "Shard " .. id .. " already has an active process." end,
    [DjsErrorCodes.ShardingWorkerExists] = function(id) return "Shard " .. id .. " already has an active worker." end,
    [DjsErrorCodes.ShardingReadyTimeout] = function(id) return "Shard " .. id .. "'s Client took too long to become ready." end,
    [DjsErrorCodes.ShardingReadyDisconnected] = function(id) return "Shard " .. id .. "'s Client disconnected before becoming ready." end,
    [DjsErrorCodes.ShardingReadyDied] = function(id) return "Shard " .. id .. "'s process exited before its Client became ready." end,
    [DjsErrorCodes.ShardingNoChildExists] = function(id) return "Shard " .. id .. " has no active process or worker." end,
    [DjsErrorCodes.ShardingShardMiscalculation] = function(shard, guild, count) return "Calculated invalid shard " .. shard .. " for guild " .. guild .. " with " .. count .. " shards." end,

    [DjsErrorCodes.ColorRange] = 'Color must be within the range 0 - 16777215 (0xFFFFFF).',
    [DjsErrorCodes.ColorConvert] = function(color) return 'Unable to convert "' .. color .. '" to a number.' end,

    [DjsErrorCodes.InviteOptionsMissingChannel] = 'A valid guild channel must be provided when GuildScheduledEvent is EXTERNAL.',

    [DjsErrorCodes.ButtonLabel] = 'MessageButton label must be a string',
    [DjsErrorCodes.ButtonURL] = 'MessageButton URL must be a string',
    [DjsErrorCodes.ButtonCustomId] = 'MessageButton customId must be a string',

    [DjsErrorCodes.SelectMenuCustomId] = 'MessageSelectMenu customId must be a string',
    [DjsErrorCodes.SelectMenuPlaceholder] = 'MessageSelectMenu placeholder must be a string',
    [DjsErrorCodes.SelectOptionLabel] = 'MessageSelectOption label must be a string',
    [DjsErrorCodes.SelectOptionValue] = 'MessageSelectOption value must be a string',
    [DjsErrorCodes.SelectOptionDescription] = 'MessageSelectOption description must be a string',

    [DjsErrorCodes.InteractionCollectorError] = function(reason) return "Collector received no interactions before ending with reason: " .. reason end,

    [DjsErrorCodes.FileNotFound] = function(file) return "File could not be found: " .. file end,

    [DjsErrorCodes.UserBannerNotFetched] = "You must fetch this user's banner before trying to generate its URL!",
    [DjsErrorCodes.UserNoDMChannel] = 'No DM Channel exists!',

    [DjsErrorCodes.VoiceNotStageChannel] = 'You are only allowed to do this in stage channels.',

    [DjsErrorCodes.VoiceStateNotOwn] = 'You cannot self-deafen/mute/request to speak on VoiceStates that do not belong to the ClientUser.',
    [DjsErrorCodes.VoiceStateInvalidType] = function(name) return name .. " must be a boolean." end,

    [DjsErrorCodes.ReqResourceType] = 'The resource must be a string, Buffer or a valid file stream.',

    [DjsErrorCodes.ImageFormat] = function(format) return "Invalid image format: " .. format end,
    [DjsErrorCodes.ImageSize] = function(size) return "Invalid image size: " .. size end,

    [DjsErrorCodes.MessageBulkDeleteType] = 'The messages must be an Array, Collection, or number.',
    [DjsErrorCodes.MessageContentType] = 'Message content must be a string.',
    [DjsErrorCodes.MessageNonceRequired] = 'Message nonce is required when enforceNonce is true.',
    [DjsErrorCodes.MessageNonceType] = 'Message nonce must be an integer or a string.',

    [DjsErrorCodes.SplitMaxLen] = 'Chunk exceeds the max length and contains no split characters.',

    [DjsErrorCodes.BanResolveId] = function(ban) ban = ban or false; return "Couldn't resolve the user id to " .. (ban and 'ban' or 'unban') .. "." end,
    [DjsErrorCodes.FetchBanResolveId] = "Couldn't resolve the user id to fetch the ban.",

    [DjsErrorCodes.PruneDaysType] = 'Days must be a number',

    [DjsErrorCodes.GuildChannelResolve] = 'Could not resolve channel to a guild channel.',
    [DjsErrorCodes.GuildVoiceChannelResolve] = 'Could not resolve channel to a guild voice channel.',
    [DjsErrorCodes.GuildChannelOrphan] = 'Could not find a parent to this guild channel.',
    [DjsErrorCodes.GuildChannelUnowned] = "The fetched channel does not belong to this manager's guild.",
    [DjsErrorCodes.GuildOwned] = 'Guild is owned by the client.',
    [DjsErrorCodes.GuildMembersTimeout] = "Members didn't arrive in time.",
    [DjsErrorCodes.GuildUncachedMe] = 'The client user as a member of this guild is uncached.',
    [DjsErrorCodes.ChannelNotCached] = 'Could not find the channel where this message came from in the cache!',
    [DjsErrorCodes.StageChannelResolve] = 'Could not resolve channel to a stage channel.',
    [DjsErrorCodes.GuildScheduledEventResolve] = 'Could not resolve the guild scheduled event.',
    [DjsErrorCodes.FetchOwnerId] = function(type) return "Couldn't resolve the " .. type .. " ownerId to fetch the " .. type .. " member." end,

    [DjsErrorCodes.InvalidType] = function(name, expected, an) an = an or false; return "Supplied " .. name .. " is not a" .. (an and 'n' or '') .. " " .. expected .. "." end,
    [DjsErrorCodes.InvalidElement] = function(type, name, elem) return "Supplied " .. type .. " " .. name .. " includes an invalid element: " .. elem end,

    [DjsErrorCodes.MessageThreadParent] = 'The message was not sent in a guild text or news channel',
    [DjsErrorCodes.MessageExistingThread] = 'The message already has a thread',
    [DjsErrorCodes.ThreadInvitableType] = function(type) return "Invitable cannot be edited on " .. type end,

    [DjsErrorCodes.WebhookMessage] = 'The message was not sent by a webhook.',
    [DjsErrorCodes.WebhookTokenUnavailable] = 'This action requires a webhook token, but none is available.',
    [DjsErrorCodes.WebhookURLInvalid] = 'The provided webhook URL is not valid.',
    [DjsErrorCodes.WebhookApplication] = 'This message webhook belongs to an application and cannot be fetched.',
    [DjsErrorCodes.MessageReferenceMissing] = 'The message does not reference another message',

    [DjsErrorCodes.EmojiType] = 'Emoji must be a string or GuildEmoji/ReactionEmoji',
    [DjsErrorCodes.EmojiManaged] = 'Emoji is managed and has no Author.',
    [DjsErrorCodes.MissingManageGuildExpressionsPermission] = function(guild) return "Client must have Manage Guild Expressions permission in guild " .. guild .. " to see emoji authors." end,
    [DjsErrorCodes.MissingManageEmojisAndStickersPermission] = function(guild) return "Client must have Manage Emojis and Stickers permission in guild " .. guild .. " to see emoji authors." end,

    [DjsErrorCodes.NotGuildSticker] = 'Sticker is a standard (non-guild) sticker and has no author.',

    [DjsErrorCodes.ReactionResolveUser] = "Couldn't resolve the user id to remove from the reaction.",

    [DjsErrorCodes.VanityURL] = 'This guild does not have the vanity URL feature enabled.',

    [DjsErrorCodes.InviteResolveCode] = 'Could not resolve the code to fetch the invite.',

    [DjsErrorCodes.InviteNotFound] = 'Could not find the requested invite.',

    [DjsErrorCodes.DeleteGroupDMChannel] = "Bots don't have access to Group DM Channels and cannot delete them",
    [DjsErrorCodes.FetchGroupDMChannel] = "Bots don't have access to Group DM Channels and cannot fetch them",

    [DjsErrorCodes.MemberFetchNonceLength] = 'Nonce length must not exceed 32 characters.',

    [DjsErrorCodes.GlobalCommandPermissions] = 'Permissions for global commands may only be fetched or modified by providing a GuildResolvable ' ..
        "or from a guild's application command manager.",
    [DjsErrorCodes.GuildUncachedEntityResolve] = function(type) return "Cannot resolve " .. type .. " from an arbitrary guild, provide an id instead" end,

    [DjsErrorCodes.InteractionAlreadyReplied] = 'The reply to this interaction has already been sent or deferred.',
    [DjsErrorCodes.InteractionNotReplied] = 'The reply to this interaction has not been sent or deferred.',
    [DjsErrorCodes.InteractionEphemeralReplied] = 'Ephemeral responses cannot be deleted.',

    [DjsErrorCodes.CommandInteractionOptionNotFound] = function(name) return 'Required option "' .. name .. '" not found.' end,
    [DjsErrorCodes.CommandInteractionOptionType] = function(name, type, expected) return 'Option "' .. name .. '" is of type: ' .. type .. '; expected ' .. expected .. '.' end,
    [DjsErrorCodes.CommandInteractionOptionEmpty] = function(name, type) return 'Required option "' .. name .. '" is of type: ' .. type .. '; expected a non-empty value.' end,
    [DjsErrorCodes.CommandInteractionOptionNoSubcommand] = 'No subcommand specified for interaction.',
    [DjsErrorCodes.CommandInteractionOptionNoSubcommandGroup] = 'No subcommand group specified for interaction.',
    [DjsErrorCodes.CommandInteractionOptionInvalidChannelType] = function(name, type, expected) return 'The type of channel of the option "' .. name .. '" is: ' .. type .. '; expected ' .. expected .. '.' end,
    [DjsErrorCodes.AutocompleteInteractionOptionNoFocusedOption] = 'No focused option for autocomplete interaction.',

    [DjsErrorCodes.ModalSubmitInteractionFieldNotFound] = function(customId) return 'Required field with custom id "' .. customId .. '" not found.' end,
    [DjsErrorCodes.ModalSubmitInteractionFieldType] = function(customId, type, expected) return 'Field with custom id "' .. customId .. '" is of type: ' .. type .. '; expected ' .. expected .. '.' end,

    [DjsErrorCodes.InvalidMissingScopes] = 'At least one valid scope must be provided for the invite',
    [DjsErrorCodes.InvalidScopesWithPermissions] = 'Permissions cannot be set without the bot scope.',

    [DjsErrorCodes.NotImplemented] = function(what, name) return "Method " .. what .. " not implemented on " .. name .. "." end,

    [DjsErrorCodes.SweepFilterReturn] = 'The return value of the sweepFilter function was not false or a Function',

    [DjsErrorCodes.GuildForumMessageRequired] = 'You must provide a message to create a guild forum thread',

    [DjsErrorCodes.EntitlementCreateInvalidOwner] = 'You must provide either a guild or a user to create an entitlement, but not both',

    [DjsErrorCodes.BulkBanUsersOptionEmpty] = 'Option "users" array or collection is empty',

    [DjsErrorCodes.PollAlreadyExpired] = 'This poll has already expired.',
}

return Messages
