-- Simple queue-based matchmaking
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Signal)

local MatchmakingService = {}
MatchmakingService.__index = MatchmakingService

function MatchmakingService.new()
	local self = setmetatable({}, MatchmakingService)
	self.Queue = {}
	self.MatchReady = Signal.new()
	return self
end

function MatchmakingService:Enqueue(player)
	for _, plr in ipairs(self.Queue) do
		if plr == player then
			return
		end
	end
	table.insert(self.Queue, player)
end

function MatchmakingService:Dequeue(player)
	for i, plr in ipairs(self.Queue) do
		if plr == player then
			table.remove(self.Queue, i)
			break
		end
	end
end

function MatchmakingService:Tick()
	local needed = Config.Game.MinPlayersPerTeam * 2
	if #self.Queue >= needed then
		local players = {}
		for i = 1, needed do
			players[i] = table.remove(self.Queue, 1)
		end
		self.MatchReady:Fire(players)
	end
end

return MatchmakingService
