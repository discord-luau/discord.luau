--!strict
local Class = require('@std/class')
local FormData = require("@std/formData")
local Task = require("@std/task")
local Serde = require("@std/serde")
local Net = require("@std/net")

-- Dependencies
local Table = require("@deps/table")
local Future = require("@deps/future")
local Console = require("@deps/console")
local URLSearchParams = require("@deps/urlSearchParams")

-- Utilities
local Is = require("@discordluau/utils/is")
local Transformers = require("@discordluau/utils/transformers")
local MessagePayload = require("@discordluau/utils/messagePayload")

-- REST Handlers
local HTTPRatelimit = require('handlers/httpRatelimit')
local HTTPScheduler = require('handlers/httpScheduler')

-- REST Utils
local types = require('utils/types')
local Constants = require("utils/constants")

local CDN = require("cdn")


type InternalRequest = types.InternalRequest
type RESTOptions = types.RESTOptions
type FixedRESTOptions = types.FixedRESTOptions
type RequestMethod = types.RequestMethod

local RequestMethod = types.RequestMethod

local FILE_FORMATS = {
	jpg = "image/jpg",
	jpeg = "image/jpeg",
	png = "image/png",
	webp = "image/webp",
	gif = "image/gif",

	csv = "text/csv",
	txt = "text/plain",
	css = "text/css",
	js = "text/javascript",
	html = "text/html",

	mp4 = "video/mp4",
}

--[=[
	@class REST 
]=]
local REST = {}

REST.interface = {}
REST.prototype = {}

REST.prototype.__type = 'REST'

function REST.prototype.parseErrors(self: REST, errorTable: { [any]: any }, source: string?, depth: number?)
	local _source = source or ""
	local _depth = depth or 0

	for index, value in errorTable do
		if index == "_errors" then
			for _, errorObject in value do
				_source ..= `{string.rep(" ", _depth)}{errorObject.code}: {errorObject.message}\n`
			end
		else
			_source ..= `{string.rep(" ", _depth)}{index}:\n{self:parseErrors(value, _source, _depth + 1)}\n`
		end
	end

	return _source
end

function REST.prototype.parseDiscordAPIErrors(self: REST, api: string, networkResponse: Net.FetchResponse)
	local success, messageDecoded = pcall(function()
		return Serde.decode("json", networkResponse.body)
	end)

	if success then
		local discordErrorString = ""

		if messageDecoded.errors then
			discordErrorString = self:parseErrors(messageDecoded.errors)
		end

		return `Discord API Error - {messageDecoded.code} ({messageDecoded.message}): \n\nAPI: {api}\n\nTRACE:\n{discordErrorString}`
	end

	return `Discord HTTP Error - {networkResponse.statusCode} ({networkResponse.statusMessage}): \n{networkResponse.body}`
end

function REST.prototype.parseResponse(self: REST, options: InternalRequest, response: Net.FetchResponse): any
    if not response.ok then
        error(self:parseDiscordAPIErrors(options.fullRoute, response))
    end

    if response.body == '' then
        return
    else
        return Transformers.ProcessJSON(Serde.decode('json', response.body))
    end
end

function REST.prototype.queueRequest(self: REST, options: InternalRequest): Future.Future<...any>
    return Future.try(function()
        return self.scheduler:addTask(function()
            local optionHeaders = options.headers or {}
            local headers = Table.Reconcile(optionHeaders, {
                ['authorization'] = `{self.options.authPrefix} {self.token}`,
                ['content-type'] = 'application/json',
            })
            local ratelimitApi = string.gsub(options.fullRoute, '%d+', '-')

            if
                self.endpointRateLimits[ratelimitApi]
                and self.endpointRateLimits[ratelimitApi]:isConsumed()
            then
                while self.endpointRateLimits[ratelimitApi]:isConsumed() do
                    Task.wait()
                end
            end

            local bodyObject: string | FormData.FormData
            local query = ''
            if options.query then
                local resolvedQuery = options.query:toString()
                if resolvedQuery ~= "" then
                    query = `?{resolvedQuery}`
                end
            end

            local url = `{self.options.api}/v{self.version}{options.fullRoute}{query}`

            if options.body then
                if not Is(options.body, 'MessagePayload') then
                    bodyObject = Serde.encode("json", options.body)
                else
                    local body = options.body :: MessagePayload.MessagePayload

                    local content = Serde.encode("json", body.body)
                    if not body.files then
                        bodyObject = content
                    else
                        local form = FormData.new()

                        for index, file in body.files :: any do
                            form:set(`files[{index - 1}]`, file.content, file.name)
                        end

                        if content then
                            form:set("payload_json", content)
                        end
                        bodyObject = form
                    end

                end
            end

            
            local networkResponse = Net.fetch({
                url = url,
                method = options.method,
                headers = headers,
                body = bodyObject
            })

            self.reporter:debug(
                `{options.method} Async to '{options.fullRoute}': {networkResponse.statusCode} - {networkResponse.statusMessage}`
            )

            local ratelimitLimit = tonumber(networkResponse.headers['x-ratelimit-limit'])
            local ratelimitRemaining = tonumber(networkResponse.headers['x-ratelimit-remaining'])
            local ratelimitResetAfter = tonumber(networkResponse.headers['x-ratelimit-reset-after'])

            if ratelimitLimit and ratelimitRemaining and ratelimitResetAfter then
                if not self.endpointRateLimits[ratelimitApi] then
					self.endpointRateLimits[ratelimitApi] = (HTTPRatelimit.new(
						ratelimitLimit,
						ratelimitRemaining
					) :: unknown) :: HTTPRatelimit.HTTPRatelimit
				end

				self.endpointRateLimits[ratelimitApi]:setRemaining(ratelimitRemaining)
				self.endpointRateLimits[ratelimitApi]:resetAfter(ratelimitResetAfter + 1) 

                self.reporter:debug(
                    `{options.method} Rate Limit '{ratelimitLimit - ratelimitRemaining}/{ratelimitLimit}, resetting in {ratelimitResetAfter}'`
                )
            end

            if not networkResponse.ok then
                -- print(bodyObject)
                error(self:parseDiscordAPIErrors(options.fullRoute, networkResponse))
            end

            if networkResponse.body == '' then
                return
            else
                return Transformers.ProcessJSON(Serde.decode('json', networkResponse.body))
            end
        end)
    end)
end

function REST.prototype.get(self: REST, fullRoute: string, query: URLSearchParams.URLSearchParams?): ...any
    return Future.try(function()
        local cache = self:getEndpointCache(fullRoute)
		local cacheValue = cache and cache:get()

		if cacheValue then
			return cacheValue
		end
        local requestOptions = { fullRoute = fullRoute, method = RequestMethod.Get :: RequestMethod, query = query } :: InternalRequest

        local response = self:request(requestOptions)

        if cache then
            cache:set(response)
        end
        return response
    end):await()
end

function REST.prototype.post(self: REST, fullRoute: string, data: types.RequestData, headers: types.Headers?, query: URLSearchParams.URLSearchParams?): ...any
    local requestOptions = { body = data, fullRoute = fullRoute, method = RequestMethod.Post :: RequestMethod, headers = headers, query = query } :: InternalRequest
    local response = self:request(requestOptions)
    return response
end

function REST.prototype.delete(self: REST, fullRoute: string, data: types.RequestData, headers: types.Headers?, query: URLSearchParams.URLSearchParams?): ...any
    local requestOptions = { body = data, fullRoute = fullRoute, method = RequestMethod.Delete :: RequestMethod, headers = headers, query = query } :: InternalRequest
    local response = self:request(requestOptions)
    return response
end

function REST.prototype.patch(self: REST, fullRoute: string, data: types.RequestData, headers: types.Headers?, query: URLSearchParams.URLSearchParams?): ...any
    local requestOptions = { body = data, fullRoute = fullRoute, method = RequestMethod.Patch :: RequestMethod, headers = headers, query = query } :: InternalRequest
    local response = self:request(requestOptions)
    return response
end

function REST.prototype.put(self: REST, fullRoute: string, data: types.RequestData, headers: types.Headers?, query: URLSearchParams.URLSearchParams?): ...any
    local requestOptions = { body = data, fullRoute = fullRoute, method = RequestMethod.Put :: RequestMethod, headers = headers, query = query } :: InternalRequest
    local response = self:request(requestOptions)
    return response
end

function REST.prototype.request(self: REST, options: InternalRequest): ...any
   local response = self:queueRequest(options):await()
   return response
end

function REST.prototype.setEndpointCache(self: REST, endpoint: string, cache: { [any]: any })
	self.endpointCaches[endpoint] = cache
end

function REST.prototype.getEndpointCache(self: REST, endpoint: string)
	return self.endpointCaches[endpoint]
end

function REST.prototype.setToken(self: REST, token: string)
    self.token = token
end

function REST.interface.new(options: RESTOptions?, threadCount: number?): REST
    local opt = options or {}
    local fixedOptions = Table.Reconcile(opt, Constants.DefaultRestOptions) :: types.FixedRESTOptions

    return (Class({
        cdn = CDN.new(fixedOptions.cdn) :: CDN.CDN,
        scheduler = HTTPScheduler.new(threadCount or 1) :: HTTPScheduler.HTTPScheduler,
        version = fixedOptions.version,

        options = fixedOptions :: types.FixedRESTOptions,

        reporter = Console.new('REST'),

        endpointRateLimits = {} :: { [string]: HTTPRatelimit.HTTPRatelimit },
        endpointCaches = {} :: { [string]: { [any]: any } },
    }, REST.prototype) :: any) :: REST
end

export type REST = typeof(REST.prototype) & {
    scheduler: HTTPScheduler.HTTPScheduler,
    reporter: Console.Console,
    endpointRateLimits: { [string]: HTTPRatelimit.HTTPRatelimit },
    endpointCaches: { [string]: { [any]: any } },
    options: types.FixedRESTOptions,
    cdn: CDN.CDN,
    version: string,
    token: string,
}

return REST.interface