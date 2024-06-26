-- Standard Libraries
local Class = require("@std/class")

-- API
local GatewayAPI = require("@discordluau/api/gateway")

-- Base BitField
local BitField = require("./bitField")

-- Enumerations
local GatewayIntentBits = GatewayAPI.GatewayIntentBits

local IntentsBitField = {}

IntentsBitField.interface = {}
IntentsBitField.prototype = { }

IntentsBitField.prototype.__type = "IntentsBitField"

function IntentsBitField.interface.new(intentList: { number } | number): IntentsBitField
    return Class({}, IntentsBitField.prototype):extend(BitField.new(intentList, GatewayIntentBits))
end

function IntentsBitField.interface.parse(intents: { number }): IntentsBitField
	return IntentsBitField.interface.new(intents)
end

export type IntentsBitField = BitField.BitField & typeof(IntentsBitField.prototype) 

return IntentsBitField.interface