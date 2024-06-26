local Transformers = require("@discordluau/utils/transformers")

local Options = {
    createDefault = function()
        return {
            jsonTransformer = Transformers.ProcessJSON
        }
    end
}

return Options