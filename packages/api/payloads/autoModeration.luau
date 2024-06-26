local enum = require("@std/enum")

local GlobalApi = require("../global")

type Snowflake = GlobalApi.Snowflake

export type AutoModerationRuleEventType = number

export type APIAutoModerationAction = {
    type: number,
    metadata: APIAutoModerationActionMetadata?
}

export type APIAutoModerationActionMetadata = {
    channel_id: Snowflake?,
    duration_seconds: number?,
    custom_message: string?
}

local AutoModerationRuleEventType = enum('AutoModerationRuleEventType', {
    MessageSend = 1,
    MemberUpdate = 2
})

local AutoModerationRuleTriggerType = enum('AutoModerationRuleTriggerType', {
    Keyword = 1,
	Spam = 3,
	KeywordPreset = 4,
	MentionSpam = 5,
})

local AutoModerationRuleKeywordPresetType = enum('AutoModerationRuleKeywordPresetType', {
    Profanity = 1,
    SexualContent = 2,
    Slurs = 3
})

local AutoModerationActionType = enum('AutoModerationActionType', {
    BlockMessage = 1,
	SendAlertMessage = 2,
	Timeout = 3,
    BlockMemberInteraction = 4
})

return {
    AutoModerationActionType = AutoModerationActionType,
    AutoModerationRuleEventType = AutoModerationRuleEventType,
    AutoModerationRuleTriggerType = AutoModerationRuleTriggerType,
    AutoModerationRuleKeywordPresetType = AutoModerationRuleKeywordPresetType
}