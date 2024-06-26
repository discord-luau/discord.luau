--!nocheck

local BigInt = require("@deps/bigInt")
local Table = require("@deps/table")
local SwitchCase = require("@deps/polyfill/switch")
local URLSearchParams = require("@deps/urlSearchParams")

local switch, case, default = SwitchCase.switch, SwitchCase.case, SwitchCase.default

local function calculateUserDefaultAvatarIndex(userId)
	local userIdNumber = BigInt.new(userId)

	local shifted = bit32.rshift(userIdNumber:Reverse(), 22)

	local index = shifted % 6

	-- Lua indexes are 1-based, so we increment the result by 1
	return index + 1
end

local function serializeSearchParam(value: unknown): string?
	if typeof(value) == "string" then
		return value
	elseif typeof(value) == "number" or typeof(value) == "boolean" then
		return tostring(value)
	end

	return nil
end

local function serializeSearchParam(value: unknown): string?
	return switch(typeof(value)) {
		case 'string' {
			function()
				return value
			end
		}, 
		case 'number',
		case 'boolean' {
			function()
				return tostring(value)
			end
		},
        default {
			function()
				return nil
			end
		}
    }	
end

local function makeURLSearchParams(opt: any): URLSearchParams.URLSearchParams
	local data = URLSearchParams.new()
	if not opt then
		return data
	end

	for key, value in opt do
		local serialized = serializeSearchParam(value)
		if serialized then
			data:append(key, value)
		end
	end

	return data
end

return table.freeze({
    calculateUserDefaultAvatarIndex = calculateUserDefaultAvatarIndex,
	makeURLSearchParams = makeURLSearchParams
})