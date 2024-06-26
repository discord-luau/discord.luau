--!strict

-- Standard Libraries
local class = require("@std/class")

-- Dependencies
local Future = require('@deps/future')
local Table = require('@deps/table')

-- Builders
local SlashCommandBuilder = require('@discordluau/builders/interactions/slashCommand')

-- API
local RESTApi = require('@discordluau/api/rest')

-- Enumerations
local Routes = RESTApi.Routes


local ApplicationCommand = {}

ApplicationCommand.prototype = {}
ApplicationCommand.interface = {}

ApplicationCommand.prototype.__type = 'ApplicationCommand'

function ApplicationCommand.prototype.create(
    self: ApplicationCommand,
    command: SlashCommandBuilder.SlashCommandBuilder,
    guildId: string?
)
    local endpoint = guildId and Routes.applicationGuildCommands(self.id, guildId)
        or Routes.applicationCommands(self.id)
    return Future.try(function()
        return self.client.rest:post(endpoint, command:toJSON())
    end)
end

function ApplicationCommand.prototype.delete(
    self: ApplicationCommand,
    commandId: string,
    guildId: string?
)
    local endpoint = guildId and Routes.applicationGuildCommand(self.id, guildId, commandId)
        or Routes.applicationCommand(self.id, commandId)
    return Future.try(function()
        return self.client.rest:delete(endpoint)
    end)
end

function ApplicationCommand.prototype.edit(
    self: ApplicationCommand,
    commandId: string,
    command: SlashCommandBuilder.SlashCommandBuilder,
    guildId: string?
)
    local endpoint = guildId and Routes.applicationGuildCommand(self.id, guildId, commandId)
        or Routes.applicationCommand(self.id, commandId)
    return Future.try(function()
        return self.client.rest:patch(endpoint, command:toJSON())
    end)
end

function ApplicationCommand.prototype.get(self: ApplicationCommand, guildId: string?)
    local endpoint = guildId and Routes.applicationGuildCommands(self.id, guildId)
        or Routes.applicationCommands(self.id)
    return Future.try(function()
        return self.client.rest:get(endpoint)
    end)
end

function ApplicationCommand.prototype.set(
    self: ApplicationCommand,
    commands: { SlashCommandBuilder.SlashCommandBuilder },
    guildId: string?
)
    return Future.try(function()
        local endpoint = guildId and Routes.applicationGuildCommands(self.id, guildId)
            or Routes.applicationCommands(self.id)
        local commandsData = {}
        for _, command in commands do
            table.insert(commandsData, command:toJSON())
        end

        return self.client.rest:put(endpoint, commandsData)
    end)
end

function ApplicationCommand.prototype.constructor(
    self: ApplicationCommand,
    applicationData: ApplicationData
)
    self.id = applicationData.id
    self.flags = applicationData.flags
end

function ApplicationCommand.interface.new(
    client: any,
    applicationData: ApplicationData
): ApplicationCommand
    local self = (class({ client = client }, ApplicationCommand.prototype) :: any) :: ApplicationCommand
    self:constructor(applicationData)

    return self
end

type ApplicationData = {
    id: string,
    flags: number,
}

export type ApplicationCommand = typeof(ApplicationCommand.prototype) & {
    id: string,
    flags: number,
    client: any,
}

return ApplicationCommand.interface
