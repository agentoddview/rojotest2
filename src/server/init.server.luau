print("Hello world, from server!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArenaService = require(script.Parent.ArenaService)
local CharacterService = require(script.Parent.CharacterService)
local BallService = require(script.Parent.BallService)
local ScoringService = require(script.Parent.ScoringService)

local arenaService = ArenaService.new()
local characterService = CharacterService.new()
local ballService = BallService.new()
local scoringService = ScoringService.new()

local arena = arenaService:CreateArena()

local Players = game:GetService("Players")
for _, player in ipairs(Players:GetPlayers()) do
	characterService:RespawnPlayer(player, arena.Spawns.TeamA)
end

Players.PlayerAdded:Connect(function(player)
	characterService:RespawnPlayer(player, arena.Spawns.TeamA)
end)

local match = {
	Score = { A = 0, B = 0 },
}

local goalDebounce = false

local function resetRound()
	for _, player in ipairs(Players:GetPlayers()) do
		characterService:RespawnPlayer(player, arena.Spawns.TeamA)
	end
	ballService:ResetBall(arena.Spawns.Ball)
end

local function onGoalScored(teamKey)
	if goalDebounce then
		return
	end
	goalDebounce = true

	local matchOver = scoringService:HandleGoal(match, teamKey)
	task.delay(2, function()
		if matchOver then
			match.Score = { A = 0, B = 0 }
		end
		resetRound()
		goalDebounce = false
	end)
end

local function connectGoal(trigger)
	trigger.Touched:Connect(function(hit)
		if not hit or hit.Name ~= "Ball" then
			return
		end
		local teamKey = trigger:GetAttribute("Team")
		if not teamKey then
			return
		end
		onGoalScored(teamKey)
	end)
end

connectGoal(arena.GoalA)
connectGoal(arena.GoalB)

ballService:SpawnBall(workspace, arena.Spawns.Ball)
