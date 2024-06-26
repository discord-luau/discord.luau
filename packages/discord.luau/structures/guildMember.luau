-- Standard Library
local Date = require('@std/datetime')
local class = require("@std/class")


-- Utilities
local is = require('@discordluau/utils/is')

-- Structures
local User = require('user')

-- Builders
local MemberBuilder = require('@discordluau/builders/guilds/member')

-- API
local GuildApi = require('@discordluau/api/payloads/guild')
local RestAPI = require('@discordluau/api/rest')

-- Enumerations
local Routes = RestAPI.Routes

local GuildMember = {}

GuildMember.prototype = {}
GuildMember.interface = {}

GuildMember.prototype.__type = 'GuildMember'

function GuildMember.prototype.kick(self: GuildMember)
    return self.client.rest:delete(Routes.guildMember(self.guildId, self.user.id))
end

function GuildMember.prototype.ban(self: GuildMember, deleteMessagesSeconds: number?)
    return self.client.rest:put(Routes.guildBan(self.guildId, self.user.id), {
        delete_message_seconds = deleteMessagesSeconds or 0,
    })
end

function GuildMember.prototype.unban(self: GuildMember)
    return self.client.rest:delete(Routes.guildBan(self.guildId, self.user.id))
end

function GuildMember.prototype.addRole(self: GuildMember, roleId: string)
    return self.client.rest:put(Routes.guildMemberRole(self.guildId, self.user.id, roleId))
end

function GuildMember.prototype.removeRole(self: GuildMember, roleId: string)
    return self.client.rest:delete(Routes.guildMemberRole(self.guildId, self.user.id, roleId))
end

function GuildMember.prototype.timeout(self: GuildMember, seconds: number)
    return self:edit({
        communicationDisabledUntil = seconds,
    })
end

function GuildMember.prototype.mute(self: GuildMember)
    return self:edit({
        mute = true,
    })
end

function GuildMember.prototype.unmute(self: GuildMember)
    return self:edit({
        mute = false,
    })
end

function GuildMember.prototype.deafen(self: GuildMember)
    return self:edit({
        deaf = true,
    })
end

function GuildMember.prototype.undeafen(self: GuildMember)
    return self:edit({
        deaf = false,
    })
end

function GuildMember.prototype.setNickname(self: GuildMember, nickname: string)
    return self:edit({
        nick = nickname,
    })
end

function GuildMember.prototype.edit(
    self: GuildMember,
    options: EditMemberOptions | MemberBuilder.MemberBuilder
)
    local data
    if is(options, 'MessageBuilder') then
        data = (options :: any):toJSON()
    else
        local communication_disabled_until = options.communicationDisabledUntil
                and Date.fromUnixTimestamp(os.time() + options.communicationDisabledUntil)
                    :toIsoDate()
            or nil
        data = {
            nick = options.nick,
            roles = options.roles,
            mute = options.mute,
            channel_id = options.channelId,
            communication_disabled_until = communication_disabled_until,
            flags = options.flags,
        }
    end

    return self.client.rest:patch(Routes.guildMember(self.guildId, self.user.id), data)
end

-- Extras
GuildMember.prototype.modify = GuildMember.prototype.edit

function GuildMember.interface.new(
    client: any,
    userId: string,
    guildId: string,
    memberData: { [any]: any }
): GuildMember
    local source = (class({
        client = client,
    }, GuildMember.prototype) :: any) :: GuildMember

    local data = memberData
    if data['user'] then
        data.user = nil
    end

    if memberData.user then
        data.user = User.new(client, memberData.user)
    end

    data.id = userId

    data.guildId = guildId

    for index, value in data do
        (source :: any)[index] = value
    end

    return source
end

type EditMemberOptions = GuildApi.EditMemberOptions

export type GuildMember = typeof(GuildMember.prototype) & {
    client: any,
    user: User.User,
    guildId: number,
}

return GuildMember.interface
