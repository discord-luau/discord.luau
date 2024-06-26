-- Standard Libraries

local class = require("@std/class")
local net = require("@std/net")
local serde = require("@std/serde")
local task = require("@std/task")

-- Dependencies
local Future = require("@deps/future")
local Console = require("@deps/console")
local Event = require("@deps/event")

-- Utilities
local Transformers = require("@discordluau/utils/transformers")

-- Websocket Buffer
local WebSocketBuffer = require("websocketBuffer")

local RESTApi = require("@discordluau/api/rest")
local WebsocketAPI = RESTApi.Websocket

local WebSocketOperationKeys = WebsocketAPI.WebsocketOperationKeys
local WebSocketOperationCodes = WebsocketAPI.WebsocketOperationCodes 


local ZLIB_SUFFIX_START = "\120"
local ZLIB_SUFFIX_END = "\84"

--[=[
	@class WebSocket

	(sorry I will add docs for this lol, just haven't got around to it yet!)
]=]
local WebSocket = {}

WebSocket.interface = {}
WebSocket.prototype = {}

WebSocket.prototype.__type = "WebSocket"

function WebSocket.prototype.send(self: WebSocket, dataPacket: { [any]: any })
	local traceback = debug.traceback()

	return Future.try(function()
		if not self.socketInstance then
			error(`No WebSocket avaliable!`)
		end

		local messageSendOperationSuccessful, result = pcall(function()
			return (self.socketInstance.send(
                serde.encode("json", Transformers.ProcessJSON(dataPacket, true))
			) :: unknown) :: buffer
		end)

		if messageSendOperationSuccessful then
			self.reporter:debug(`Discord WebSocket Message Sent: {dataPacket[WebSocketOperationKeys.OperationCode]}`)
		else
			local resultType: string = typeof(result)
			local messageResult

			if resultType == "userdata" then
				local success = pcall(function()
					messageResult = buffer.tostring(result)
				end)

				if not success then
					messageResult = tostring(result)
				end
			end

			self.reporter:warn(`Socket error: {string.split(messageResult, "\n")[1]}, traceback:\n{traceback}`)

			self.socketActive = false
			self.onSocketDead.emit(self.socketInstance.closeCode)
		end
	end)
end

function WebSocket.prototype.connect(self: WebSocket, websocketUrl: string)
	return Future.try(function()
		self.socketUrl = websocketUrl
		self.socketRequestSuccess, self.socketInstance = pcall(net.socket, websocketUrl)

		if not self.socketRequestSuccess then
			error(self.socketInstance)
		end

		self.socketActive = true
		self.socketThread = task.spawn(function()
			while self.socketActive do
				if not self.socketInstance then
					return
				end

				if self.socketInstance.closeCode then
					self.socketActive = false
					self.onSocketDead.emit(self.socketInstance.closeCode)
				else
					local success, socketMessage = pcall(self.socketInstance.next)

					if not success or not socketMessage then
						self.socketActive = false
						self.onSocketDead.emit(self.socketInstance.closeCode)
						continue
					end

					self.onMessageRecv.emit(socketMessage)
				end
			end
		end)
	end)
end

function WebSocket.prototype.disconnect(self: WebSocket, closingCode: string)
	return Future.try(function()
		if not self.socketInstance then
			return
		end

		if self.socketActive then
			xpcall(function()
				self.socketInstance.close(tonumber(closingCode))
			end, function(source: string)
				self.reporter:warn(`Failed to close websocket: '{source}'`)
			end)
		end

		self.socketActive = false
		self.onSocketDead.emit(tonumber(closingCode))
	end)
end

function WebSocket.prototype.constructor(self: WebSocket)
    self.socketActiveChanged.on(function(state)
		local connectedLabel = state and "Connected" or "Disconnected"

		local socketUrl = self.socketUrl and `[{self.socketUrl}]` or ""
		local closeCode = self.socketInstance and self.socketInstance.closeCode and `[{self.socketInstance.closeCode}]` or ""

		self.reporter:debug(`Discord WebSocket {connectedLabel} {socketUrl} {closeCode}`)
	end)

	self.onMessageRecv.on(function(discordPacket)
		local isJSON, dataPacket = pcall(function()
			return serde.decode("json", discordPacket)
		end)

		if not isJSON then
			self.websocketWebSocketBuffer:add(discordPacket :: any)

			if string.sub(discordPacket :: any, 1, 1) ~= ZLIB_SUFFIX_START then
				return
			end

			if string.sub(discordPacket :: any, 4, 4) ~= ZLIB_SUFFIX_END then
				return
			end

			local encodedDiscordPacket = self.websocketWebSocketBuffer:flush()
			local decodedDiscordPacket = serde.decompress("zlib", encodedDiscordPacket)

			dataPacket = serde.decode("json", decodedDiscordPacket)
		end

		if dataPacket[WebSocketOperationKeys.OperationCode] == WebSocketOperationCodes.Dispatch then
			self.reporter:debug(`Discord WebSocket Message Received: {dataPacket[WebSocketOperationKeys.OperationCode]} - {dataPacket[WebSocketOperationKeys.EventName]}`)
		else
			self.reporter:debug(`Discord WebSocket Message Received: {dataPacket[WebSocketOperationKeys.OperationCode]}`)
		end

		self.onOperationRecv.emit(
			dataPacket[WebSocketOperationKeys.OperationCode],
            Transformers.ProcessJSON(dataPacket[WebSocketOperationKeys.Data]),
			dataPacket[WebSocketOperationKeys.EventName],
			dataPacket[WebSocketOperationKeys.Sequence]
		)
	end)
end

function WebSocket.interface.new(): WebSocket
	local self = (class({
		websocketWebSocketBuffer = WebSocketBuffer.new(),
		
		onMessageRecv = Event.new(),
		onSocketDead = Event.new(),
		onOperationRecv = Event.new(),
		
		reporter = Console.new("WebSocket"),

		socketActiveChanged = Event.new(),
		socketActive = false,

		socketUrl = nil,
		socketInstance = nil,

		socketRequestSuccess = nil,
		socketThread = nil,
	}, WebSocket.prototype) :: any) :: WebSocket
	self:constructor()

	return self
end

export type WebSocket = typeof(WebSocket.prototype) & {
	websocketWebSocketBuffer: WebSocketBuffer.WebSocketBuffer,

	socketActiveChanged: Event.Event<boolean>,
	socketActive: boolean,

	onMessageRecv: Event.Event<string>,
	onSocketDead: Event.Event<number?>,
	onOperationRecv: Event.Event<number, any, string?, number?>,

	reporter: Console.Console,

	socketUrl: string?,
	socketInstance: net.WebSocket?,

	socketRequestSuccess: boolean?,
	socketThread: thread?
}


return WebSocket.interface