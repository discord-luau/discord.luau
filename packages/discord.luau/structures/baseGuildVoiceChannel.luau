--!strict

-- Standard Libraries
local class = require('@std/class')

-- Dependencies
local Future = require('@deps/future')

-- Structures
local BaseGuildChannel = require('baseGuildChannel')

-- Voices
local VoiceConnection = require('@discordluau/voice/voiceConnection')

local BaseGuildVoiceChannel = {}

BaseGuildVoiceChannel.prototype = {}
BaseGuildVoiceChannel.interface = {}

BaseGuildVoiceChannel.prototype.__type = 'BaseGuildVoiceChannel'

function BaseGuildVoiceChannel.prototype.connect(self: BaseGuildVoiceChannel)
    return Future.try(function()
        local connection = VoiceConnection.new(self.client, `voice-{self.id}`)

        self.voiceConnection = connection

        return connection:connect(self.guildId, self.id):await()
    end)
end

function BaseGuildVoiceChannel.prototype.disconnect(
    self: BaseGuildVoiceChannel
): Future.Future<unknown>
    return Future.try(function()
        if not self.voiceConnection then
            return
        end

        return self.voiceConnection:disconnect():await()
    end)
end

function BaseGuildVoiceChannel.prototype.constructor(
    self: BaseGuildVoiceChannel,
    channelData: ChannelData
)
    for index, value in channelData do
        (self :: {})[index] = value
    end
end

function BaseGuildVoiceChannel.interface.new(
    client: any,
    channelData: ChannelData
): BaseGuildVoiceChannel
    local self: BaseGuildVoiceChannel = (class({ client = client }, BaseGuildVoiceChannel.prototype):extend(
        BaseGuildChannel.new(client, channelData)
    ) :: any) :: BaseGuildVoiceChannel

    self:constructor(channelData)

    return self
end

export type ChannelData = {
    id: string,
    guildId: string,
}

export type BaseGuildVoiceChannel =
    BaseGuildChannel.BaseGuildChannel
    & typeof(BaseGuildVoiceChannel.prototype)
    & {
        id: string,
        guildId: string,

        voiceConnection: VoiceConnection.VoiceConnection?,

        bitrate: number,
        userLimit: number,

        rtc_region: string,
        videoQualityMode: number,
    }

return BaseGuildVoiceChannel.interface