-- Standard Libraries
local enum = require("@std/enum")
local class = require("@std/class")

-- API
local ActivityApi = require("@discordluau/api/payloads/activity")

-- Enumerations
local ActivityType = ActivityApi.ActivityType

local Activity = {}
Activity.interface = {}
Activity.prototype = {}
Activity.prototype.__type = 'Activity'

function Activity.prototype.setActivityName(self: Activity, activityName: string)
    self.name = activityName

    return self
end

function Activity.prototype.setActivityType(self: Activity, activityType: number)
    assert(ActivityType:is(activityType), `Expected 'activityType' to of class 'activityType'`)

    self.activityType = activityType

    return self
end

function Activity.prototype.setStreamingURL(self: Activity, streamURL: string)
	if not string.find(streamURL, "youtube.com") and not string.find(streamURL, "twitch.tv") then
		return
	end

	self.streamingURL = streamURL

	return self
end

function Activity.prototype.toJSON(self: Activity)
	return {
		name = self.name or "",
		type = self.activityType or 0,
		url = self.streamingURL
	} 
end

function Activity.interface.new(): Activity
    return class({
        name = 'Discord.Luau',
        activityType = 0,
        streamingURL = nil
    }, Activity.prototype)
end

export type ActivityProperties = {
    streamingURL: string?,
    activityType: number,
    name: string
}

export type Activity = ActivityProperties & typeof(Activity.prototype)

return Activity.interface