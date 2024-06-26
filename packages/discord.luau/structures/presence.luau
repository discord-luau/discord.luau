-- External Utilities
local class = require('@std/class')
local enum = require('@std/enum')

-- Structures
local DiscordActivity = require('activity')

local Presence = {}

Presence.Type = 'Presence'

Presence.interface = {}
Presence.prototype = {}

Presence.prototype.__type = 'Presence'

Presence.interface.Status = enum('PresenceStatus',{
    Online = 'online',
    DoNotDisturb = 'dnd',
    Idle = 'idle',
    Invisible = 'invisible',
    Offline = 'offline',
})


function Presence.prototype.addActivity(self: Presence, activity: DiscordActivity.Activity)
    table.insert(self.activities, activity)

    return self
end


function Presence.prototype.setStatus(self: Presence, status: string)
    self.status = status

    return self
end


function Presence.prototype.setAfk(self: Presence, isAfk: boolean)
    self.idle = isAfk

    return self
end


function Presence.prototype.setSince(self: Presence, delta: number)
    self.since = delta

    return self
end


function Presence.prototype.toJSON(self: Presence)
    local activities = {}

    for index, activity in self.activities :: { DiscordActivity.Activity } do
        activities[index] = activity:toJSON()
    end

    return {
        since = self.since or 0,

        activities = activities,
        afk = self.idle or false,
        status = self.status or 'online',
    }
end


function Presence.interface.new(): Presence
    return class({
        activities = {},
    }, Presence.prototype) :: any
end

export type Presence = typeof(Presence.prototype) & {
    activities: { DiscordActivity.Activity },
    since: number?,
    idle: boolean?,
    status: string?,
}

export type PresenceStatusData = 'online' | 'dnd' | 'idle' | 'invisible' | 'offline'

export type PresenceOptions = {
    activities: { DiscordActivity.Activity }?,
    afk: boolean?,
    status: PresenceStatusData?,
}

return Presence.interface
