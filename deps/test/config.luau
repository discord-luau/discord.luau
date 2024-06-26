local types = require("types")

type DefaultOptions = types.DefaultOptions

local defaultOptions: DefaultOptions = {
    testMatch = { "**/__tests__/**/*", "**/?(*.)+(spec|test).luau" },
    root = "<rootDir>" 
}

return {
    default = defaultOptions
}