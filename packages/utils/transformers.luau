--!nocheck

type Transformers = {
    ToSnakeCase: (input: string) -> string,
    ToCamelCase: (input: string) -> string,
    ProcessJSON: <T>(input: T, static: boolean?) -> T
}

local Transformers = {} :: Transformers

local function _toCamelCaseJSON<T>(json: T): T & {}
    local source = {}

	for illegalIndex, value in (json :: any) do
        local legalIndex = Transformers.ToCamelCase(illegalIndex)
        if typeof(value) == "table" then
            value = _toCamelCaseJSON(value)
        end

		source[legalIndex] = value
	end

	return (source :: any) :: T & {} 
end

function Transformers.ToSnakeCase(input: string): string
     -- Store the first character separately
    -- local firstChar = str:match("^_") or ""
    
    local legalStr = string.gsub(input, "%u", function(illegal)
        return "_" .. string.lower(illegal)
    end)

    -- Handle cases where there might be multiple consecutive uppercase letters (PascalCase)
    legalStr = string.gsub(legalStr, "(%l)(%u)", function(preceding: string, following: string)
        return preceding .. "_" .. following:lower()
    end)

    -- If the first character is uppercase (PascalCase), remove the leading underscore
    legalStr = legalStr:gsub("^_", "")


    return legalStr:lower() 
end

function Transformers.ToCamelCase(input: string): string
    -- Check if the string starts with an uppercase letter
    if string.match(input, "^[A-Z]") then
        input = string.sub(input, 1, 1):lower() .. string.sub(input, 2)
    else
        -- Convert snake_case to camelCase
        input = string.gsub(input, "(_)(%w)", function(underscore, following)
            return string.upper(following)
        end)
    end

    return input
end

function Transformers.ProcessJSON<T>(data: T, static: boolean?): T
    if static then
        return data
    end

    if typeof(data) == "table" then
		return _toCamelCaseJSON(data)
	end

	return data
end

return Transformers