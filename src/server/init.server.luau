print("Hello world, from server!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)

local ArenaService = require(script:WaitForChild("ArenaService"))
local CharacterService = require(script:WaitForChild("CharacterService"))
local BallService = require(script:WaitForChild("BallService"))
local ScoringService = require(script:WaitForChild("ScoringService"))
local MutatorService = require(script:WaitForChild("MutatorService"))
local InputService = require(script:WaitForChild("InputService"))
local MatchmakingService = require(script:WaitForChild("MatchmakingService"))
local MatchService = require(script:WaitForChild("MatchService"))
local DataService = require(script:WaitForChild("DataService"))

local arenaService = ArenaService.new()
local characterService = CharacterService.new()
local scoringService = ScoringService.new()
local mutatorService = MutatorService.new()
local inputService = InputService.new()
local matchmakingService = MatchmakingService.new()
local matchService = MatchService.new()
local dataService = DataService.new()

inputService:Start()

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end

local scoreEvent = remotes:FindFirstChild("ScoreEvent")
if not scoreEvent then
	scoreEvent = Instance.new("RemoteEvent")
	scoreEvent.Name = "ScoreEvent"
	scoreEvent.Parent = remotes
end

local queueEvent = remotes:FindFirstChild("QueueEvent")
if not queueEvent then
	queueEvent = Instance.new("RemoteEvent")
	queueEvent.Name = "QueueEvent"
	queueEvent.Parent = remotes
end

local matchEvent = remotes:FindFirstChild("MatchEvent")
if not matchEvent then
	matchEvent = Instance.new("RemoteEvent")
	matchEvent.Name = "MatchEvent"
	matchEvent.Parent = remotes
end

local ActiveMatches = {}
local PlayerMatch = {}

local function isBallInsideTrigger(trigger, ballPosition)
	local localPos = trigger.CFrame:PointToObjectSpace(ballPosition)
	local half = trigger.Size * 0.5
	return math.abs(localPos.X) <= half.X
		and math.abs(localPos.Y) <= half.Y
		and math.abs(localPos.Z) <= half.Z
end

local function isBallStuck(match, now)
	local ball = match.BallService.Ball
	if not ball then
		return false
	end
	local velocity = ball.AssemblyLinearVelocity.Magnitude
	local lastPos = match.LastBallPosition
	local moved = lastPos and (ball.Position - lastPos).Magnitude > 0.2
	if velocity > 0.5 or moved then
		match.LastBallMoveTime = now
		return false
	end
	return (now - (match.LastBallMoveTime or now)) >= Config.Game.BallStuckSeconds
end

local function sendScore(match, matchOver)
	for _, player in ipairs(match.Players) do
		if player and player.Parent then
			scoreEvent:FireClient(player, match.Score, match.Mutator, matchOver)
		end
	end
end

local function setFrozen(playersList, frozen)
	for _, player in ipairs(playersList) do
		characterService:SetFrozen(player, frozen)
	end
end

local function spawnTeam(playersList, spawnList)
	if #spawnList == 0 then
		return
	end
	for i, player in ipairs(playersList) do
		local spawnCFrame = spawnList[((i - 1) % #spawnList) + 1]
		characterService:RespawnPlayer(player, spawnCFrame)
	end
end

local function resetRound(match)
	spawnTeam(match.Teams.A, match.Arena.Spawns.TeamA)
	spawnTeam(match.Teams.B, match.Arena.Spawns.TeamB)
	match.BallService:ResetBall(match.Arena.Spawns.Ball)
end

local function onGoalScored(match, teamKey)
	if match.GoalDebounce then
		return
	end
	match.GoalDebounce = true
	setFrozen(match.Players, true)

	local matchOver = scoringService:HandleGoal(match, teamKey)
	sendScore(match, matchOver)
	task.delay(Config.Game.RoundFreezeSeconds, function()
		if matchOver then
			local winners = {}
			local losers = {}
			if teamKey == "A" then
				for _, player in ipairs(match.Teams.A) do
					table.insert(winners, player.UserId)
				end
				for _, player in ipairs(match.Teams.B) do
					table.insert(losers, player.UserId)
				end
			else
				for _, player in ipairs(match.Teams.B) do
					table.insert(winners, player.UserId)
				end
				for _, player in ipairs(match.Teams.A) do
					table.insert(losers, player.UserId)
				end
			end
			dataService:RecordWinLoss(winners, losers)
			dataService:UpdateMMR(winners, losers, Config.Ranked.KFactor)
			for _, player in ipairs(match.Players) do
				dataService:SaveProfile(player.UserId)
			end
			match.Score = { A = 0, B = 0 }
		end
		match.Mutator = mutatorService:PickRandom()
		resetRound(match)
		mutatorService:Apply(match.Mutator, match.Arena, match.BallService.Ball, match.Players)
		sendScore(match, false)
		setFrozen(match.Players, false)
		match.GoalDebounce = false
	end)
end

local function connectGoal(match, trigger)
	trigger.Touched:Connect(function(hit)
		if not hit or hit.Name ~= "Ball" then
			return
		end
		local teamKey = trigger:GetAttribute("Team")
		if not teamKey then
			return
		end

		local now = os.clock()
		local lastGoalTime = match.LastGoalTimeByHoop[trigger] or 0
		if now - lastGoalTime < match.GoalCooldownSeconds then
			return
		end

		local ball = match.BallService.Ball
		if not ball then
			return
		end

		local triggerTopY = trigger.Position.Y + (trigger.Size.Y * 0.5)
		local enteredFromAbove = match.LastBallPosition and match.LastBallPosition.Y > triggerTopY and ball.Position.Y <= triggerTopY
		local falling = ball.AssemblyLinearVelocity.Y <= 0
		if not (enteredFromAbove and falling) then
			return
		end

		if not isBallInsideTrigger(trigger, ball.Position) then
			return
		end

		match.LastGoalTimeByHoop[trigger] = now
		onGoalScored(match, teamKey)
	end)
end

local function setupMatch(playersList)
	local match = matchService:CreateMatch(playersList)
	match.Score = { A = 0, B = 0 }
	match.Mutator = nil
	match.Players = playersList
	match.Teams = {}
	match.GoalDebounce = false
	match.GoalCooldownSeconds = 1.0
	match.LastGoalTimeByHoop = {}
	match.LastBallPosition = nil
	match.LastBallMoveTime = os.clock()
	match.BallService = BallService.new()
	match.Arena = arenaService:CreateArena(workspace, match.Id)

	match.Teams.A, match.Teams.B = matchService:AssignTeams(playersList)
	spawnTeam(match.Teams.A, match.Arena.Spawns.TeamA)
	spawnTeam(match.Teams.B, match.Arena.Spawns.TeamB)
	match.BallService:SpawnBall(match.Arena.Folder, match.Arena.Spawns.Ball)

	connectGoal(match, match.Arena.GoalA)
	connectGoal(match, match.Arena.GoalB)

	ActiveMatches[match.Id] = match
	for _, player in ipairs(playersList) do
		PlayerMatch[player.UserId] = match
		matchEvent:FireClient(player, "MatchFound")
	end
	sendScore(match, false)
end

local function cleanupMatch(match)
	ActiveMatches[match.Id] = nil
	if match.Arena and match.Arena.Folder then
		match.Arena.Folder:Destroy()
	end
	if match.BallService and match.BallService.Ball then
		match.BallService.Ball:Destroy()
	end
	for _, player in ipairs(match.Players) do
		PlayerMatch[player.UserId] = nil
	end
end

matchmakingService.MatchReady:Connect(function(playersList)
	setupMatch(playersList)
end)

Players.PlayerAdded:Connect(function(player)
	dataService:LoadProfile(player.UserId)
end)

Players.PlayerRemoving:Connect(function(player)
	matchmakingService:Dequeue(player)
	dataService:SaveProfile(player.UserId)
	local match = PlayerMatch[player.UserId]
	if match then
		for i, plr in ipairs(match.Players) do
			if plr == player then
				table.remove(match.Players, i)
				break
			end
		end
		PlayerMatch[player.UserId] = nil
		if #match.Players == 0 then
			cleanupMatch(match)
		end
	end
end)

queueEvent.OnServerEvent:Connect(function(player, action)
	if action == "Enqueue" then
		matchmakingService:Enqueue(player)
	elseif action == "Dequeue" then
		matchmakingService:Dequeue(player)
	end
end)

local queueAccumulator = 0
RunService.Heartbeat:Connect(function(dt)
	queueAccumulator += dt
	if queueAccumulator >= Config.Matchmaking.QueueTick then
		queueAccumulator = 0
		matchmakingService:Tick()
	end

	for _, match in pairs(ActiveMatches) do
		local ball = match.BallService.Ball
		if ball then
			match.LastBallPosition = ball.Position
		end
		local now = os.clock()
		if isBallStuck(match, now) then
			resetRound(match)
			match.LastBallMoveTime = now
		end
	end
end)
