-- Server-side match lifecycle
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Signal)

local MatchService = {}
MatchService.__index = MatchService

function MatchService.new()
	local self = setmetatable({}, MatchService)
	self.MatchStarted = Signal.new()
	self.MatchEnded = Signal.new()
	self.ActiveMatches = {}
	return self
end

function MatchService:CreateMatch(players)
	-- TODO: allocate arena instance, assign teams
	local match = {
		Id = tostring(os.clock()),
		Players = players,
		Score = { A = 0, B = 0 },
		State = "Active",
		Mutator = nil,
	}
	self.ActiveMatches[match.Id] = match
	self.MatchStarted:Fire(match)
	return match
end

function MatchService:EndMatch(matchId, winningTeam)
	local match = self.ActiveMatches[matchId]
	if not match then
		return
	end
	match.State = "Ended"
	match.Winner = winningTeam
	self.MatchEnded:Fire(match)
	self.ActiveMatches[matchId] = nil
end

function MatchService:AssignTeams(players)
	-- TODO: deterministic shuffle and split
	local teamA = {}
	local teamB = {}
	for i, plr in ipairs(players) do
		if i % 2 == 1 then
			table.insert(teamA, plr)
		else
			table.insert(teamB, plr)
		end
	end
	return teamA, teamB
end

return MatchService
