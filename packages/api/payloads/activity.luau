local enum = require("@std/enum")
local ActivityType = enum('ActivityType', {
    Game = 0,
	Streaming = 1,
	Listening = 2,
	Watching = 3,
	Competing = 5,
})

return {
    ActivityType = ActivityType
}