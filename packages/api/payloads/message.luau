local enum = require("@std/enum")

local lshift = bit32.lshift

local MessageFlags = enum('MessageFlags', {
    Crossposted = lshift(1, 0),
    IsCrosspost = lshift(1, 1),
    SupressEmbeds = lshift(1, 2),
    SourceMessageDeleted = lshift(1, 3),
    Urgent = lshift(1, 4),
    HasThread = lshift(1, 5),
    Ephemeral = lshift(1, 6),
    Loading = lshift(1, 7),
    FailedToMentionSomeRolesInThread = lshift(1, 8),
    ShouldShowLinkNotDiscordWarning = lshift(1, 10),
    SuppressNotifications = lshift(1, 12),
    IsVoiceMessage = lshift(1, 13),
})

return {
    MessageFlags = MessageFlags
} 