local Snowflake = require("snowflake")
local DiscordSnowflake = require("./discordSnowflake")

export type Snowflake = Snowflake.Snowflake


return {
    Snowflake = Snowflake,
    DiscordSnowflake = DiscordSnowflake.DiscordSnowflake
}