-- Mutator selection and application (server-authoritative)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Mutators = require(ReplicatedStorage.Shared.Mutators)

local MutatorService = {}
MutatorService.__index = MutatorService

function MutatorService.new()
	local self = setmetatable({}, MutatorService)
	self.LastMutatorId = nil
	self.Defaults = {
		Gravity = workspace.Gravity,
		FloorProps = nil,
		BallSize = nil,
		BallProps = nil,
	}
	return self
end

function MutatorService:PickRandom()
	local totalWeight = 0
	for _, entry in ipairs(Mutators.List) do
		totalWeight += entry.Weight
	end
	if totalWeight <= 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, entry in ipairs(Mutators.List) do
		cumulative += entry.Weight
		if roll <= cumulative then
			self.LastMutatorId = entry.Id
			return entry
		end
	end
	return nil
end

function MutatorService:Apply(mutator, arena, ball, players)
	-- Reset to defaults before applying a new mutator
	if self.Defaults.FloorProps and arena and arena.Floor then
		arena.Floor.CustomPhysicalProperties = self.Defaults.FloorProps
	end
	if self.Defaults.BallSize and ball then
		ball.Size = self.Defaults.BallSize
	end
	if self.Defaults.BallProps and ball then
		ball.CustomPhysicalProperties = self.Defaults.BallProps
	end
	workspace.Gravity = self.Defaults.Gravity

	if not mutator or not arena or not ball then
		return
	end

	if not self.Defaults.FloorProps and arena.Floor then
		self.Defaults.FloorProps = arena.Floor.CustomPhysicalProperties
	end
	if not self.Defaults.BallSize then
		self.Defaults.BallSize = ball.Size
	end
	if not self.Defaults.BallProps then
		self.Defaults.BallProps = ball.CustomPhysicalProperties
	end

	if mutator.Id == "LowGravity" then
		workspace.Gravity = 120
	elseif mutator.Id == "HighGravity" then
		workspace.Gravity = 260
	elseif mutator.Id == "BouncyFloor" then
		if arena.Floor then
			arena.Floor.CustomPhysicalProperties = PhysicalProperties.new(1, 0.2, 1.0)
		end
	elseif mutator.Id == "SlipperyFloor" then
		if arena.Floor then
			arena.Floor.CustomPhysicalProperties = PhysicalProperties.new(1, 0.05, 0.0)
		end
	elseif mutator.Id == "TinyBall" then
		ball.Size = Vector3.new(1, 1, 1)
	elseif mutator.Id == "HeavyBall" then
		ball.CustomPhysicalProperties = PhysicalProperties.new(3, 0.6, 0.4)
	elseif mutator.Id == "LightBall" then
		ball.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.3, 0.4)
	end
end

return MutatorService
