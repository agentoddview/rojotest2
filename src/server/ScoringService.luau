-- Server-authoritative scoring
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Signal)

local ScoringService = {}
ScoringService.__index = ScoringService

function ScoringService.new()
	local self = setmetatable({}, ScoringService)
	self.GoalScored = Signal.new()
	return self
end

function ScoringService:HandleGoal(match, teamKey)
	match.Score[teamKey] = match.Score[teamKey] + 1
	self.GoalScored:Fire(match, teamKey)
	if match.Score[teamKey] >= Config.Game.PointsToWin then
		return true
	end
	return false
end

return ScoringService
