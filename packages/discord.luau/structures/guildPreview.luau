--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local Emoji = require('emoji')
local Sticker = require('sticker')

local GuildPreview = {}

GuildPreview.prototype = {}
GuildPreview.interface = {}

GuildPreview.prototype.__type = 'GuildPreview'

function GuildPreview.prototype.constructor(self: GuildPreview, guildPreview: GuildPreviewData)
    for index, value in guildPreview do
        (self :: {})[index] = value
    end
end

function GuildPreview.interface.new(client: any, guildPreview: GuildPreviewData): GuildPreview
    local self = (class({ id = guildPreview.id, client = client }, GuildPreview.prototype) :: any) :: GuildPreview

    self:constructor(guildPreview)

    return self
end

type GuildPreviewData = {
    id: string,
    [string]: any,
}

export type GuildPreview = typeof(GuildPreview.prototype) & {
    id: string,
    name: string,
    icon: string?,
    splash: string?,
    discoverySplash: string?,
    emojis: { Emoji.Emoji },
    features: { string },
    approximateMemberCount: number,
    approximatePresenceCount: number,
    description: string?,
    stickers: { Sticker.Sticker },
}

return GuildPreview.interface
