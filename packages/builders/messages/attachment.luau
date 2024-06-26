-- Standard Libraries
local Class = require("@std/class")

local AttachmentBuilder = {}

AttachmentBuilder.interface = {}
AttachmentBuilder.prototype = {}

AttachmentBuilder.prototype.__type = "AttachmentBuilder"

function AttachmentBuilder.prototype.setName(self: AttachmentBuilder, name: string): AttachmentBuilder
	self.name = name

	return self
end

function AttachmentBuilder.prototype.setData(self: AttachmentBuilder, data: string): AttachmentBuilder
	self.content = data

	return self
end

function AttachmentBuilder.prototype.setDescription(self: AttachmentBuilder, description: string): AttachmentBuilder
	self.description = description

	return self
end

function AttachmentBuilder.prototype.toForm(self: AttachmentBuilder)
	return { 
		name = self.name,
		description = self.description,
		content = self.description,
	}
end

function AttachmentBuilder.interface.new(): AttachmentBuilder
    return Class({}, AttachmentBuilder.prototype)
end

export type AttachmentBuilder = typeof(AttachmentBuilder.prototype) & {
    name: string?,
    description: string?,
    content: string?
}

return AttachmentBuilder.interface