local function is<T>(tbl: T, type: string): boolean
    assert(typeof(type) == "string", "Received a non-string as the second argument for is")

	if typeof(tbl) ~= "table" then
		return false
	end

    if typeof(tbl) == "table" and getmetatable(tbl) ~= nil then
        tbl = getmetatable(tbl)
        if tbl ~= nil and tbl['__type'] == type then
            return true
        end
    end

	return false
end

return is