--!strict

-- Standard Libraries
local class = require("@std/class")

-- API
local InteractionSharedApi = require("@discordluau/api/payloads/interactions/shared")

-- Enumerations
local ApplicationCommandOptionType = InteractionSharedApi.ApplicationCommandOptionType

local InteractionOptionResolver = {}
InteractionOptionResolver.interface = {}
InteractionOptionResolver.prototype = {}
InteractionOptionResolver.prototype.__type = 'InteractionOptionResolver'

local function Find<K, V>(tbl: { [K]: V }, callback: (V, K, { [K]: V }) -> boolean): (V?, K?)
    for k, v in tbl do
        if callback(v, k, tbl) then
            return v, k
        end
    end
    return nil, nil
end

local function Every<K, V>(tbl: { [K]: V }, callback: (V, K, { [K]: V }) -> boolean): boolean
    for k, v in tbl do
        if not callback(v, k, tbl) then
            return false
        end
    end
    return true
end

function InteractionOptionResolver.prototype.get(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): any?
    local option = Find(self._hoistedOptions, function(value)
        return value.name == name
    end)

    if not option then
        if required then
            error('Option is not found')
        end

        return nil
    end

    return option
end

function InteractionOptionResolver.prototype._getTypedOption(
    self: InteractionOptionResolver,
    name: string,
    allowedTypes: { number },
    properties: { string },
    required: boolean?
): any?
    local option = self:get(name, required)
    if not option then
        return nil
    elseif not table.find(allowedTypes, option.type) then
        error('')
    elseif
        required and Every(properties, function(prop)
            return option[prop] == nil
        end)
    then
        error('')
    end

    return option
end

function InteractionOptionResolver.prototype.getBoolean(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): boolean?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Boolean },
        { 'value' },
        required
    )

    return option
end

-- ChannelType [TextChannel | VoiceChannel etc]
function InteractionOptionResolver.prototype.getChannel(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?,
    channelTypes: { any }?
)
    local fixedChannelTypes = channelTypes or {}
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Channel },
        { 'channel' },
        required
    )

    local channel = option and option.channel or nil

    if channel and #fixedChannelTypes > 0 and not table.find(fixedChannelTypes, channel.type) then
        error('')
    end

    return channel
end

function InteractionOptionResolver.prototype.getString(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): string?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.String },
        { 'value' },
        required
    )

    return option and option.value or nil
end

function InteractionOptionResolver.prototype.getInteger(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): number?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Integer },
        { 'value' },
        required
    )

    return option and option.value or nil
end

function InteractionOptionResolver.prototype.getNumber(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): number?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Number },
        { 'value' },
        required
    )

    return option and option.value or nil
end

function InteractionOptionResolver.prototype.getUser(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): any?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.User, ApplicationCommandOptionType.Mentionable },
        { 'user' },
        required
    )

    return option and option.user or nil
end

function InteractionOptionResolver.prototype.getMember(
    self: InteractionOptionResolver,
    name: string
): any?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.User, ApplicationCommandOptionType.Mentionable },
        { 'member' },
        false
    )

    return option and option.member or nil
end

function InteractionOptionResolver.prototype.getRole(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): any?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Role, ApplicationCommandOptionType.Mentionable },
        { 'role' },
        required
    )

    return option and option.member or nil
end

function InteractionOptionResolver.prototype.getAttachment(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): any?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Attachment },
        { 'attachment' },
        required
    )

    return option and option.attachment or nil
end

function InteractionOptionResolver.prototype.getMentionable(
    self: InteractionOptionResolver,
    name: string,
    required: boolean?
): any?
    local option = self:_getTypedOption(
        name,
        { ApplicationCommandOptionType.Mentionable },
        { 'user', 'member', 'role' },
        required
    )

    if option then
        if option.member then
            return option.member
        elseif option.user then
            return option.user
        elseif option.role then
            return option.role
        end
    end

    return nil
end

function InteractionOptionResolver.interface.new(
    options: any,
    resolved: boolean?
): InteractionOptionResolver
    return class({
        _hoistedOptions = options and table.freeze(options) or {},
    }, InteractionOptionResolver.prototype) :: InteractionOptionResolver
end

export type InteractionOptionResolver = typeof(InteractionOptionResolver.prototype) & {
    _hoistedOptions: { [string]: any },
}

return InteractionOptionResolver.interface
