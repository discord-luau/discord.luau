local enum = require("@std/enum")

export type ApplicationCommandType = number
export type InteractionContextType = number

local ApplicationCommandType = enum('ApplicationCommandType', {
    ChatInput = 1,
    User = 2,
    Message = 3
})

local InteractionContextType = enum('InteractionContextType', {
    Guild = 0,
    BotDM = 1,
    PrivateChannel = 2
})

return {
    ApplicationCommandType = ApplicationCommandType,
    InteractionContextType = InteractionContextType
}