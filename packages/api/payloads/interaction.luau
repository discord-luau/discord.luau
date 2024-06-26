local enum = require("@std/enum")

local InteractionType = enum('InteractionType', {
    Ping = 1,
    ApplicationCommand = 2,
    MessageComponent = 3,
    ApplicationCommandAutocomplete = 4,
    ModalSubmit = 5
})

local ApplicationCommandType = enum('ApplicationCommandType', {
    ChatInput = 1,
    User = 2,
    Message = 3
})

return {
    InteractionType = InteractionType,
    ApplicationCommandType = ApplicationCommandType
}