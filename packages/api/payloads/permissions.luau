local enum = require("@std/enum")
local GlobalApi = require("../global")

type Permissions = GlobalApi.Permissions

local RoleFlags = enum('RoleFlags', {
    InPrompt = bit32.lshift(1, 0)
})

export type APIRole = {
    name: string,
    color: number,
    hoist: boolean,
    icon: string?,
    unicode_emoji: string?,
    position: number,
    permissions: Permissions,
    mentionable: boolean,
    flags: number?
}

return {
    RoleFlags = RoleFlags
}