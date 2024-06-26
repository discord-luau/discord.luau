--!strict
local dt = require("@lune/datetime")

local Date = {} :: DateImpl
Date.__index = Date

export type UnixTimestamp = number
export type IsoDate = string
export type DateTime = dt.DateTime

export type DateTimeOptions = (UnixTimestamp | IsoDate | DateTime)?

export type Locale = "de" | "en" | "es" | "fr" | "it" | "ja" | "pl" | "pt" | "pt-br" | "tr"
export type DateProperties = {
    day: number,
    hour: number,
    minute: number,
    month: number,
    second: number,
    year: number
}

export type DatePropertiesArguments = DateProperties & {
    millisecond: number?
}

export type DatePropertiesReturns = DateProperties & {
    millisecond: number
}

function Date.new(time: DateTimeOptions?): Date
    local date: dt.DateTime
    if time then
        if typeof(time) == "string" then
            date = dt.fromIsoDate(time)
        elseif typeof(time) == "number" then
            date = dt.fromUnixTimestamp(time)
        elseif typeof(date) == "table" then
            date = time
        end
    else
        date = dt.now()
    end

    local obj = {
        timestamp = date.unixTimestamp,
        milliseconds = date.unixTimestamp,
        _date = date,
    }


    return setmetatable({
        timestamp = date.unixTimestamp,
        milliseconds = date.unixTimestamp,
        _date = date,
    }, Date) :: any
end

function Date.now(): number
    local date = Date.new()

    return date.milliseconds
end

function Date.fromUnixTimestamp(unixTimestamp: UnixTimestamp): Date
    return Date.new(unixTimestamp)
end

function Date.fromUniversalTime(props: DatePropertiesArguments): Date
    local date = dt.fromUniversalTime(props)
    return Date.new(date)
end

function Date.fromLocalTime(props: DatePropertiesArguments): Date
    local date = dt.fromLocalTime(props)
    return Date.new(date)
end

function Date.fromIsoDate(isoDate: IsoDate): Date
    return Date.new(isoDate)
end

function Date.formatLocalTime(self: Date, formatString: string?, locale: Locale?): string
    return self._date:formatLocalTime(formatString, locale)
end

function Date.formatUniversalTime(self: Date, formatString: string?, locale: Locale?): string
    return self._date:formatUniversalTime(formatString, locale)
end

function Date.toIsoDate(self: Date): string
    return self._date:toIsoDate()
end

function Date.toLocalTime(self: Date): DatePropertiesReturns
    return self._date:toLocalTime()
end

function Date.toUniversalTime(self: Date): DatePropertiesReturns
    return self._date:toUniversalTime()
end

-- Aliases
function Date.toLocale(self: Date, formatString: string?, locale: Locale?): string
    return self:formatLocalTime(formatString, locale)
end

function Date.toDateString(self: Date): string
    return self:formatLocalTime("%a %b %d %Y")
end

function Date.toUTCString(self: Date)
    return self:formatUniversalTime("%a, %d %b %Y %T GMT")
end

function Date.toISOString(self: Date): IsoDate
    return self:toIsoDate()
end

function Date.toJSON(self: Date): IsoDate
    return self:toIsoDate()
end

export type DateImpl = {
    __index: DateImpl,
    new: (time: DateTimeOptions?) -> Date,
    now: () -> number,
    fromUnixTimestamp: (unixTimestamp: UnixTimestamp) -> Date,
    fromUniversalTime: (props: DatePropertiesArguments) -> Date,
    fromLocalTime: (props: DatePropertiesArguments) -> Date,
    fromIsoDate: (isoDate: IsoDate) -> Date,

    formatLocalTime: (self: Date, formatString: string?, locale: Locale?) -> string,
    formatUniversalTime: (self: Date, formatString: string?, locale: Locale?) -> string,
    toIsoDate: (self: Date) -> string,
    toLocalTime: (self: Date) -> DatePropertiesReturns,
    toUniversalTime: (self: Date) -> DatePropertiesReturns,

    toLocale: (self: Date, formatString: string?, locale: Locale?) -> string,
    toDateString: (self: Date) -> string,
    toUTCString: (self: Date) -> string,
    toISOString: (self: Date) -> string,
    toJSON: (self: Date) -> string,
}

export type Date = typeof(setmetatable({} :: { timestamp: number, milliseconds: number, _date: dt.DateTime }, {} :: DateImpl))

return Date :: DateImpl 