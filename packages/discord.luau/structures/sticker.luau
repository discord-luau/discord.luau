--!strict

-- Standard Libraries
local class = require("@std/class")

-- Structures
local User = require("user")

local Sticker = {}

Sticker.prototype = {}
Sticker.interface = {}

Sticker.prototype.__type = 'Sticker'

function Sticker.prototype.constructor(self: Sticker, stickerData: StickerData)
    if stickerData.user then
        stickerData.user = User.new(self.client, stickerData.user)
    end

    for index, value in stickerData do
        (self :: {})[index] = value
    end
end

function Sticker.interface.new(client: any, stickerData: StickerData): Sticker
    local self = (class({ client = client }, Sticker.prototype) :: any) :: Sticker
    self:constructor(stickerData)

    return self
end

type StickerData = {
    id: string,
    [string]: any,
}

export type Sticker = typeof(Sticker.prototype) & {
    id: string,
    packId: string,
    name: string,
    description: string,
    tags: string,
    type: number,
    formatType: number,
    avaliable: boolean?,
    guildId: string?,
    user: User.User?,
    sortValue: number?,
    client: any,
}

return Sticker.interface
