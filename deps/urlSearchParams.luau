local Class = require("@std/class")

local URLSearchParams = {}
URLSearchParams.prototype = {}
URLSearchParams.interface = {}
URLSearchParams.prototype.__type = "URLSearchParams"

local function decode(str: string)
    str = str:gsub('+', ' ')
    str = str:gsub('%%(%x%x)', function(hex) 
        return string.char(tonumber(hex, 16) :: number) 
    end)
    return str
end

local function encode(str: string)
    str = str:gsub('[^%w%-._~ ]', function(char) return string.format("%%%02X", string.byte(char)) end)
    str = str:gsub(' ', '+')
    return str
end

function URLSearchParams.prototype.toString(self: URLSearchParams)
    local parts = {}
    for key, value in self.data  do
        table.insert(parts, encode(key) .. "=" .. encode(value))
    end
    return table.concat(parts, "&")
end

function URLSearchParams.prototype.append(self: URLSearchParams, key: string, value: string)
    self.data[decode(key)] = decode(value)
end

function URLSearchParams.prototype.delete(self: URLSearchParams, key: string)
    self.data[decode(key)] = nil
end

function URLSearchParams.prototype.get(self: URLSearchParams, key: string)
    return self.data[decode(key)]
end

function URLSearchParams.prototype.has(self: URLSearchParams, key: string)
    return self.data[decode(key)] ~= nil
end

function URLSearchParams.interface.new(queryString: string?): URLSearchParams
    local data = {}
    if queryString then
        for pair in queryString:gmatch("([^&]+)") do
            local key, value = pair:match("([^=]*)=([^=]*)")
            key = decode(key :: string)
            value = decode(value :: string)
            data[key] = value
        end
    end

    return (Class({ data = data }, URLSearchParams.prototype) :: any) :: URLSearchParams
end

export type URLSearchParams = typeof(URLSearchParams.prototype) & {
    data: { [string]: string }
}


return URLSearchParams.interface
