--!strict

-- Standard Libraries
local class = require("@std/class")
local enum = require("@std/enum")

-- API
local AutoModerationApi = require("@discordluau/api/payloads/autoModeration")

-- Enumerations
local AutoModerationActionType = AutoModerationApi.AutoModerationActionType
local AutoModerationRuleEventType = AutoModerationApi.AutoModerationRuleEventType
local AutoModerationRuleTriggerType = AutoModerationApi.AutoModerationRuleTriggerType
local AutoModerationRuleKeywordPresetType = AutoModerationApi.AutoModerationRuleKeywordPresetType

type APIAutoModerationAction = AutoModerationApi.APIAutoModerationAction

local AutoModerationRuleBuilder = {}

AutoModerationRuleBuilder.prototype = {}
AutoModerationRuleBuilder.interface = {}

AutoModerationRuleBuilder.prototype.__type = "AutoModerationRuleBuilder"


--[=[
	Sets the name of the rule.
	
	@method setName
	@param name string -- The name of the rule.
	@within Builders.AutoModerationRuleBuilder
	@return Builders.AutoModerationRuleBuilder -- Returns the AutoModerationRuleBuilder instance for method chaining.
]=]
function AutoModerationRuleBuilder.prototype.setName(self: AutoModerationRuleBuilder, name: string)
	self.ruleName = name

	return self
end

--[=[
	Sets the event type for the rule.
]=]
function AutoModerationRuleBuilder.prototype.setEventType(self: AutoModerationRuleBuilder, eventType: number)
	if AutoModerationRuleEventType:is(eventType) then
		self.roleEventType = eventType
	end

	return self
end

--[=[
	Sets the trigger type for the rule.
]=]
function AutoModerationRuleBuilder.prototype.setTriggerType(self: AutoModerationRuleBuilder, triggerType: number)
	if AutoModerationRuleTriggerType:is(triggerType) then
		self.ruleTriggerType = triggerType
	end

	return self
end

--[=[
	Sets the trigger metadata for the rule.
]=]
function AutoModerationRuleBuilder.prototype.setTriggerMetadata(
	self: AutoModerationRuleBuilder,
	triggerMetadata: {
		keywordFilter: { string }?,
		regexPattern: { string }?,
		presets: { number }?,
		allowList: { string }?,
		mentionTotalLimit: number?,
		mentionRaidProtectionEnabled: boolean?,
	}
)
	self.triggerMetadata = {
		keywordFilter = triggerMetadata.keywordFilter or {},
		regexPattern = triggerMetadata.regexPattern or {},
		presets = triggerMetadata.presets or {},
		allowList = triggerMetadata.allowList or {},
		mentionTotalLimit = triggerMetadata.mentionTotalLimit or 1,
		mentionRaidProtectionEnabled = triggerMetadata.mentionRaidProtectionEnabled or false,
	}

	return self
end

--[=[
	Adds an action to the rule.
	
	@method addAction
	@param actionType number -- The type of action.
	@param actionMetadata table -- The metadata for the action.
	@within Builders.AutoModerationRuleBuilder
	@return Builders.AutoModerationRuleBuilder -- Returns the AutoModerationRuleBuilder instance for method chaining.
]=]
function AutoModerationRuleBuilder.prototype.addAction(
	self: AutoModerationRuleBuilder,
	action: APIAutoModerationAction
)
	if AutoModerationActionType:is(action.type) then
		table.insert(self.actions, action)
	end

	return self
end

--[=[
	Sets whether the rule is enabled.
]=]
function AutoModerationRuleBuilder.prototype.setEnabled(self: AutoModerationRuleBuilder, enabled: boolean)
	self.ruleEnabled = enabled

	return self
end

--[=[
	Adds an exempt role to the rule.
	
	@method addExemptRole
	@param roleId string -- The ID of the role to exempt.
	@within Builders.AutoModerationRuleBuilder
	@return Builders.AutoModerationRuleBuilder -- Returns the AutoModerationRuleBuilder instance for method chaining.
]=]
function AutoModerationRuleBuilder.prototype.addExemptRole(self: AutoModerationRuleBuilder, roleId: string)
	table.insert(self.exemptRoles, roleId)

	return self
end

--[=[
	Adds an exempt channel to the rule.
	
	@method addExemptChannel
	@param channelId string -- The ID of the channel to exempt.
	@within Builders.AutoModerationRuleBuilder
	@return Builders.AutoModerationRuleBuilder -- Returns the AutoModerationRuleBuilder instance for method chaining.
]=]
function AutoModerationRuleBuilder.prototype.addExemptChannel(self: AutoModerationRuleBuilder, channelId: string)
	table.insert(self.exemptChannels, channelId)

	return self
end

--[=[
	Converts the rule to a JSON object that can be sent to the Discord API.
	
	@method toPayloadObject
	@within Builders.AutoModerationRuleBuilder
	@return Network.Resolvable
]=]
function AutoModerationRuleBuilder.prototype.toJSON(self: AutoModerationRuleBuilder)
	local actions = {}

	for _, actionObject in self.actions do
		table.insert(actions, actionObject)
	end

	return {
		{
			name = self.ruleName,
			event_type = self.roleEventType,
			trigger_type = self.ruleTriggerType,
			trigger_metadata = self.triggerMetadata,
			actions = actions,
			enabled = self.ruleEnabled,
			exempt_roles = self.exemptRoles,
			exempt_channels = self.exemptChannels,
		},
	} 
end

--[=[
	Creates a new instance of AutoModerationRuleBuilder.
	
	@function new
	@within Builders.AutoModerationRuleBuilder
	@return Builders.AutoModerationRuleBuilder -- A new instance of AutoModerationRuleBuilder.
]=]
function AutoModerationRuleBuilder.interface.new(): AutoModerationRuleBuilder
	return (
		class({
			actions = {},
			exemptRoles = {},
			exemptChannels = {},
		}, AutoModerationRuleBuilder.prototype) :: unknown
	) :: AutoModerationRuleBuilder
end

export type AutoModerationRuleBuilder = typeof(AutoModerationRuleBuilder.prototype) & {
	exemptChannels: { string },
	exemptRoles: { string },
	actions: {
		APIAutoModerationAction	
	},

	triggerMetadata: {
		keywordFilter: { string },
		regexPattern: { string },
		presets: { number },
		allowList: { string },
		mentionTotalLimit: number,
		mentionRaidProtectionEnabled: boolean,
	},

	ruleEnabled: boolean,
	ruleTriggerType: number,
	ruleName: string,
	roleEventType: number,
}

return AutoModerationRuleBuilder.interface