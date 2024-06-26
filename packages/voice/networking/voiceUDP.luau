--!strict

-- Standard Libraries
local class = require("@std/class")
local net = require("@std/net")
local task = require("@std/task")

-- Dependencies 
local Future = require("@deps/future")
local Console = require("@deps/console")
local Event = require("@deps/event")

--[=[
	@class VoiceUDP
]=]
local VoiceUDP = {}

VoiceUDP.interface = {}
VoiceUDP.prototype = {}

VoiceUDP.prototype.__type = "VoiceUDP"

function VoiceUDP.prototype.send(self: VoiceUDP, dataPacket: string)
	return Future.try(function()
		if not self.socketInstance then
			error(`Socket Instance isn't avaliable!`)
		end

		self.socketInstance.send(dataPacket)
	end)
end

function VoiceUDP.prototype.connect(
	self: VoiceUDP,
	voiceUdp: string
)
	return Future.try(function()
		local socket = self.socketInstance :: any

		self.socketUrl = voiceUdp

		socket:connect(voiceUdp)

		self.socketActive = true
		self.socketThread = task.spawn(function()
			while self.socketActive do
				if not socket then
					return
				end

				if socket.closeCode then
					-- this isn't a thing, but in the real impl - it would be.
					self.socketActive = false

					self.onSocketDead.emit(socket.closeCode)
				else
					local socketMessage = socket.next()

					self.onMessageRecv.emit(buffer.tostring(socketMessage))
				end
			end
		end)
	end)
end

function VoiceUDP.prototype.disconnect(self: VoiceUDP, closingCode: string)
	return Future.try(function()
		if not self.socketInstance then
			return
		end

		(net :: any).udpSocketClose(self.socketInstance)
	end)
end

function VoiceUDP.prototype.constructor(self: VoiceUDP)
    self.socketActiveChanged.on(function(state)
		self.reporter:debug(`Discord UDP Socket {(state and "Connected") or "Disconnected"} [{self.socketUrl or "unknown"}]`)
	end)
end

function VoiceUDP.interface.new(publicUdp: string): VoiceUDP
	local self = (class({
		publicUdp = publicUdp,
		socketInstance = (net :: any).udpSocket(publicUdp),

		socketActive = false,
		socketActiveChanged = Event.new(),

		onMessageRecv = Event.new(),
		onSocketDead = Event.new(),

		socketUrl = nil,

		reporter = Console.new("VoiceUDP"),
	}, VoiceUDP.prototype) :: any) :: VoiceUDP

	self:constructor()

	return self
end

export type VoiceUDP = typeof(VoiceUDP.prototype) & {
	udpActive: boolean,
	publicUdp: string,

	onMessageRecv: Event.Event<string>,
	onSocketDead: Event.Event<number?>,

	socketInstance: net.WebSocket?,

	reporter: Console.Console,

	socketUrl: string?,
	socketActive: boolean,

	socketActiveChanged: Event.Event<boolean>,

	socketThread: thread?
}

return VoiceUDP.interface