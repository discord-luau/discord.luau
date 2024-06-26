local Enum = require("@std/enum") 
local lshift = bit32.lshift

export type PermissionFlagBit = number | string

local PermissionFlagsBits = Enum.new('PermissionFlagsBits', {
    --[[
        Allows creation of instant invites

        Applies to channel types: Text, Voice, Stage
    ]] 
    CreateInstantInvite = lshift(1, 0),
    --[[
        Allows kicking members
    ]]
    KickMembers = lshift(1, 1),
    --[[
        Allows banning members
    ]]
    BanMembers = lshift(1, 2),
    --[[
        Allows all permissions and bypasses channel permission overwrites
    ]]
    Administrator = lshift(1, 3),
    --[[
        Allows management and editing of channels

        Applies to channel types: Text, Voice, Stage
    ]]
    ManageChannels = lshift(1, 4),
    --[[
        Allows management and editing of the guild
    ]]
    ManageGuild = lshift(1, 5),
    --[[
        Allows for the addition of reactions to messages

        Applies to channel types: Text, Voice, Stage
    ]]
    AddReactions = lshift(1, 6),
    --[[
        Allows for viewing of audit logs
    ]]
    ViewAuditLog = lshift(1, 7),
    --[[
        Allows for using priority speaker in a voice channel

        Applies to channel types: Voice
    ]]
    PrioritySpeaker = lshift(1, 8),
    --[[
        Allows the user to go live

        Applies to channel types: Voice, Stage
    ]]
    Stream = lshift(1, 9),
    --[[
        Allows guild members to view a channel, which includes reading messages in text channels and joining voice channels

        Applies to channel types: Text, Voice, Stage
    ]]
    ViewChannel = lshift(1, 10),
    --[[
        Allows for sending messages in a channel and creating threads in a forum
        (does not allow sending messages in threads)

        Applies to channel types: Text, Voice, Stage
    ]]
    SendMessages = lshift(1, 11),
    --[[
        Allows for sending of /tts messages

        Applies to channel types: Text, Voice, Stage
    ]]
    SendTTSMessages = lshift(1, 12),
    --[[
        Allows for deletion of other users messages

        Applies to channel types: Text, Voice, Stage
    ]]
    ManageMessages = lshift(1, 13),
    --[[
        Links sent by users with this permission will be auto-embedded

        Applies to channel types: Text, Voice, Stage
    ]]
    EmbedLinks = lshift(1, 14),
    --[[
        Allows for uploading images and files

        Applies to channel types: Text, Voice, Stage
    ]]
    AttachFiles = lshift(1, 15),
    --[[
        Allows for reading of message history

        Applies to channel types: Text, Voice, Stage
    ]]
    ReadMessageHistory = lshift(1, 16),
    --[[
        Allows for using the @everyone tag to notify all users in a channel,
        and the @here tag to notify all online users in a channel

        Applies to channel types: Text, Voice, Stage
    ]]
    MentionEveryone = lshift(1, 17),
    --[[
        Allows the usage of custom emojis from other servers

        Applies to channel types: Text, Voice, Stage
    ]]
    UseExternalEmojis = lshift(1, 18),
    --[[
        Allows for viewing guild insights
    ]]
    ViewGuildInsights = lshift(1, 19),
    --[[
        Allows for joining of a voice channel

        Applies to channel types: Voice, Stage
    ]]
    Connect = lshift(1, 20),
    --[[
        Allows for speaking in a voice channel

        Applies to channel types: Voice
    ]]
    Speak = lshift(1, 21),
    --[[
        Allows for muting members in a voice channel

        Applies to channel types: Voice, Stage
    ]]
    MuteMembers = lshift(1, 22),
    --[[
        Allows for deafening of members in a voice channel

        Applies to channel types: Voice
    ]]
    DeafenMembers = lshift(1, 23),
    --[[
        Allows for moving of members between voice channels

        Applies to channel types: Voice, Stage
    ]]
    MoveMembers = lshift(1, 24),
    --[[
        Allows for using voice-activity-detection in a voice channel

        Applies to channel types: Voice
    ]]
    UseVAD = lshift(1, 25),
    --[[
        Allows for modification of own nickname
    ]]
    ChangeNickname = lshift(1, 26),
    --[[
        Allows for modification of other users nicknames
    ]]
    ManageNicknames = lshift(1, 27),
    --[[
        Allows management and editing of roles

        Applies to channel types: Text, Voice, Stage
    ]]
    ManageRoles = lshift(1, 28),
    --[[
        Allows management and editing of webhooks

        Applies to channel types: Text, Voice, Stage
    ]]
    ManageWebhooks = lshift(1, 29),
    --[[
        Allows management and editing of emojis, stickers, and soundboard sounds

        @deprecated This is the old name for PermissionFlagsBits#ManageGuildExpressions
    ]]
    ManageEmojisAndStickers = lshift(1, 30),
    --[[
        Allows for editing and deleting emojis, stickers, and soundboard sounds created by all users
    ]]
    ManageGuildExpressions = lshift(1, 30),
    --[[
        Allows members to use application commands, including slash commands and context menu commands

        Applies to channel types: Text, Voice, Stage
    ]]
    UseApplicationCommands = lshift(1, 31),
    --[[
        Allows for requesting to speak in stage channels

        Applies to channel types: Stage
    ]]
    RequestToSpeak = lshift(1, 32),
    --[[
        Allows for editing and deleting scheduled events created by all users

        Applies to channel types: Voice, Stage
    ]]
    ManageEvents = lshift(1, 33),
    --[[
        Allows for deleting and archiving threads, and viewing all private threads

        Applies to channel types: Text
    ]]
    ManageThreads = lshift(1, 34),
    --[[
        Allows for creating public and announcement threads

        Applies to channel types: Text
    ]]
    CreatePublicThreads = lshift(1, 35),
    --[[
        Allows for creating private threads

        Applies to channel types: Text
    ]]
    CreatePrivateThreads = lshift(1, 36),
    --[[
        Allows the usage of custom stickers from other servers

        Applies to channel types: Text, Voice, Stage
    ]]
    UseExternalStickers = lshift(1, 37),
    --[[
        Allows for sending messages in threads

        Applies to channel types: Text
    ]]
    SendMessagesInThreads = lshift(1, 38),
    --[[
        Allows for using Activities (applications with the Embedded flag) in a voice channel

        Applies to channel types: Voice
    ]]
    UseEmbeddedActivities = lshift(1, 39),
    --[[
        Allows for timing out users to prevent them from sending or reacting to messages in chat and threads,
        and from speaking in voice and stage channels
    ]]
    ModerateMembers = lshift(1, 40),
    --[[
        Allows for viewing role subscription insights
    ]]
    ViewCreatorMonetizationAnalytics = lshift(1, 41),
    --[[
        Allows for using soundboard in a voice channel

        Applies to channel types: Voice
    ]]
    UseSoundboard = lshift(1, 42),
    --[[
        Allows for creating emojis, stickers, and soundboard sounds, and editing and deleting those created by the current user
    ]]
    CreateGuildExpressions = lshift(1, 43),
    --[[
        Allows for creating scheduled events, and editing and deleting those created by the current user

        Applies to channel types: Voice, Stage
    ]]
    CreateEvents = lshift(1, 44),
    --[[
        Allows the usage of custom soundboard sounds from other servers

        Applies to channel types: Voice
    ]]
    UseExternalSounds = lshift(1, 45),
    --[[
        Allows sending voice messages

        Applies to channel types: Text, Voice, Stage
    ]]
    SendVoiceMessages = lshift(1, 46),
    --[[
        Allows sending polls

        Applies to channel types: Text, Voice, Stage
    ]]
    SendPolls = lshift(1, 49),
})

return {
    PermissionFlagsBits = PermissionFlagsBits
}