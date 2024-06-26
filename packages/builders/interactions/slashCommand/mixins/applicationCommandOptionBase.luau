-- Standard Libraries
local class = require("@std/class")
local enum = require("@std/enum")

-- Slash Command Option Mixins
local SharedNameAndDescription = require("nameAndDescription")

local ApplicationCommandOptionBase = {}
ApplicationCommandOptionBase.prototype = {}
ApplicationCommandOptionBase.interface = {}
ApplicationCommandOptionBase.prototype.__type = "ApplicationCommandOptionBase"
ApplicationCommandOptionBase.interface.Type = enum('ApplicationCommandOptionType', {
	SubCommand = 1,
	SubCommandGroup = 2,
	String = 3,
	Integer = 4,
	Boolean = 5,
	User = 6,
	Channel = 7,
	Role = 8,
	Mentionable = 9,
	Number = 10,
	Attachment = 11
})

function ApplicationCommandOptionBase.prototype.toJSON(self: ApplicationCommandOptionBase)
	return {
		type = self.type,
		name = self.name,
		description = self.description,
		required = self.required
	}
end

function ApplicationCommandOptionBase.prototype.setRequired(self: ApplicationCommandOptionBase, required: boolean)
    self.required = required

    return self
end

function ApplicationCommandOptionBase.interface.new(type: number?): ApplicationCommandOptionBase
    return class({ type = type, required = false }, ApplicationCommandOptionBase.prototype):extend(SharedNameAndDescription.new())
end

export type ApplicationCommandOptionBase = typeof(ApplicationCommandOptionBase.prototype) & {
   type: number?,
   required: boolean 
} & SharedNameAndDescription.SharedNameAndDescription

return ApplicationCommandOptionBase.interface