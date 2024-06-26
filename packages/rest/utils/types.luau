-- Dependencies
local URLSearchParams = require("@deps/urlSearchParams")

-- Utilities
local MessagePayload = require("@discordluau/utils/messagePayload")

type URLSearchParams = URLSearchParams.URLSearchParams

export type RESTOptions = {
    cdn: string?,
    api: string?,
    version: string?,
    headers: { [string]: string }?,
    authPrefix: string?,
}

export type FixedRESTOptions = {
    cdn: string,
    api: string,
    version: string,
    authPrefix: string,
}

local RequestMethod = {
	Delete = 'DELETE',
	Get = 'GET',
	Patch = 'PATCH',
	Post = 'POST',
	Put = 'PUT',
    Head = 'HEAD',
    Options = 'OPTIONS',
}

export type RequestData = ({ [string]: any } | MessagePayload.MessagePayload)?

export type RequestMethod = "DELETE" | "GET" | "HEAD" | "OPTIONS" | "PATCH" | "POST" | "PUT"

export type Headers = { [string] : string }

export type InternalRequest = {
    fullRoute: string,
    method: RequestMethod,
    body: RequestData,
    headers: Headers?,
    query: URLSearchParams?
}

return {
    RequestMethod = RequestMethod
}