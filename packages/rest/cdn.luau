-- Standard Libraries
local Class = require("@std/class")

-- Dependencies
local Console = require("@deps/console")

local ALLOWED_SIZE = { 16, 32, 64, 128, 256, 512, 1_024, 2_048, 4_096 }
local ALLOWED_EXTENSIONS = { 'webp', 'png', 'jpg', 'jpeg', 'gif' }
local BASE_URL = 'https://cdn.discordapp.com'

--[=[
	@class CDN
]=]
local CDN = {}

CDN.interface = {}
CDN.prototype = {}

CDN.prototype.__type = "CDN"

function CDN.prototype.avatar(self: CDN, id: string, avatarHash: string, options: ImageURLOptions?)
    return self:_dynamicMakeURL(`/avatars/{id}/{avatarHash}`, avatarHash, options)
end

function CDN.prototype.defaultAvatar(self: CDN, index: number)
    return self:_makeURL(`/embed/avatars/{index}`, { extension = 'png' })
end

function CDN.prototype._dynamicMakeURL(self: CDN, route: string, avatarHash: string, options: ImageURLOptions?): string
    local opt = options or {} :: ImageURLOptions  -- Ensure options is not nil
    
    local forceStatic = opt.forceStatic or false

    if not forceStatic and string.sub(avatarHash, 1, 2) == 'a_' then
        opt.extension = 'gif'
    end

    return self:_makeURL(route, options :: any)
end

function CDN.prototype._makeURL(self: CDN, route: string, options: MakeURLOptions?): string
    local option = options or {} :: MakeURLOptions
    if option.extension == nil then
        option.extension = 'webp'
    end

    if option.size == nil then
        option.size = 128
    end

    if option.allowedExtensions == nil then
        option.allowedExtensions = ALLOWED_EXTENSIONS
    end
    local extension = string.lower(option.extension :: string)
    local allowedExtensions = option.allowedExtensions :: { string }
    local size = option.size :: number

    if not table.find(allowedExtensions, extension) then
        self.reporter:error(`Invalid extension provided: {extension}\nMust be one of: {table.concat(allowedExtensions, ", ")}`)
    end

    if size and not table.find(ALLOWED_SIZE, size) then
        self.reporter:error(`Invalid size provided: {extension}\nMust be one of: {table.concat(ALLOWED_SIZE, ", ")}`)
    end

    local url = `{self.base}{route}.{extension}`
    if size then
        url ..= `?size={size}`
    end

    return url
end

function CDN.interface.new(base: string?)
    return Class({
        base = base or BASE_URL,
        reporter = Console.new('Utility')
    }, CDN.prototype)
end

export type CDN = typeof(CDN.prototype) & {
    base: string,
    reporter: Console.Console
}

type ImageExtension = 'webp' | 'png' | 'jpg' | 'jpeg' | 'jpg' | 'gif'

export type MakeURLOptions = {
	allowedExtensions: { string }?,
    extension: string?,
	size: number?
}

type BaseImageURLOptions = {
	extension: ImageExtension?,
	size: number?
}

export type ImageURLOptions = BaseImageURLOptions & {
	forceStatic: boolean?,
}

return CDN.interface