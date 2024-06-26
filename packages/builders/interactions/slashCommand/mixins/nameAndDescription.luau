local class = require("@std/class")

local SharedNameAndDescription = {}
SharedNameAndDescription.prototype = {}
SharedNameAndDescription.interface = {}
SharedNameAndDescription.prototype.__type = "SharedNameAndDescription"

function SharedNameAndDescription.prototype.setName(self: SharedNameAndDescription, name: string)
    self.name = name

    return self
end

function SharedNameAndDescription.prototype.setDescription(self: SharedNameAndDescription, description: string)
    self.description = description

    return self
end

function SharedNameAndDescription.interface.new(): SharedNameAndDescription
    local self = class({
        name = "",
        name_localizations = nil,
        description = "",
        description_localizations = nil
    }, SharedNameAndDescription.prototype)

    return self
end

export type SharedNameAndDescription = typeof(SharedNameAndDescription.prototype) & {
    name: string,
    description: string,
    name_localizations: { [string]: string }?,
    description_localizations: { [string]: string }?
}

return SharedNameAndDescription.interface