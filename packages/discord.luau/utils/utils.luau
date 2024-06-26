-- Standard Libraries
local net = require("@std/net")

-- Dependencies
local Future = require("@deps/future")

-- REST
local REST = require("@discordluau/api/rest")

local RouteBases = REST.RouteBases
local Routes = REST.Routes

local function fetchRecommendedShardCount(token: string): Future.Future<number?>
    local guildsPerShard = 1_000
    local multipleOf = 1
    
    return Future.try(function(): number?
        local response = net.request({
            url = `{RouteBases.api}{Routes.gatewayBot}`,
            method = 'GET',
            headers = {
                ['Authorization'] = `Bot {token}`
            }
        })

        if not response.ok then
            return nil
        end

        local decoded = net.jsonDecode(response.body)
        local shards = decoded.shards

        return math.ceil((shards * (1_000 / guildsPerShard)) / multipleOf) * multipleOf
    end)
end


return {
    fetchRecommendedShardCount = fetchRecommendedShardCount
}