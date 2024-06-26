-- Standard Libraries
local Class = require("@std/class")

-- API
local CommonApi = require("@discordluau/api/payloads/common")

-- Enumerations
local PermissionFlagBits = CommonApi.PermissionFlagsBits

type PermissionFlagBit = CommonApi.PermissionFlagBit

local PermissionsBitField = {}

PermissionsBitField.interface = {}
PermissionsBitField.prototype = {}

PermissionsBitField.prototype.__type = "PermissionsBitField"

function PermissionsBitField.prototype.add(self: PermissionsBitField, permission: number)
	if table.find(self.permissions, permission) then
		return self
	end

	table.insert(self.permissions, permission)

	return self
end

function PermissionsBitField.prototype.delete(self: PermissionsBitField, permission: number)
	local index = table.find(self.permissions, permission)

	if not index then
		return self
	end

	table.remove(self.permissions, index)

	return self
end

function PermissionsBitField.prototype.has(self: PermissionsBitField, permission: number)
	return table.find(self.permissions, permission) ~= nil
end


function PermissionsBitField.prototype.getValue(self: PermissionsBitField)
	local permissionsInt = 0

	for _, intentValue in self.permissions do
		permissionsInt += intentValue 
	end

	return tostring(permissionsInt)
end


function PermissionsBitField.interface.new(): PermissionsBitField
	return Class({
		permissions = {}
	}, PermissionsBitField.prototype)
end


function PermissionsBitField.interface.none(): PermissionsBitField
	return PermissionsBitField.interface.new()
end


function PermissionsBitField.interface.all(): PermissionsBitField
	local permissions = PermissionsBitField.interface.new()
	

	for _, value in PermissionFlagBits :: {} do
		permissions:add(value :: number)
	end

	return permissions
end


function PermissionsBitField.interface.from(bits: PermissionFlagBit | { PermissionFlagBit }): PermissionsBitField
	local permissions = PermissionsBitField.interface.new()
	assert(bits and (typeof(bits) == "number" or typeof(bits) == "table" or typeof(bits) == "string"), `Invalid FlagBit '{bits}'`)

	if typeof(bits) == "table" then
		for _, bit in bits do
			for _, value in PermissionFlagBits :: {} do
				if bit32.band(tonumber(bit) :: number, value :: number) == value then
					permissions:add(value :: number)
				end
			end
		end
	else
		for _, value in PermissionFlagBits :: {} do
			if bit32.band(tonumber(bits) :: number, value :: number) == value then
				permissions:add(value :: number)
			end
		end
	end

	return permissions
end

export type PermissionsBitField = typeof(PermissionsBitField.prototype) & {
	permissions: { number }
}

return PermissionsBitField.interface