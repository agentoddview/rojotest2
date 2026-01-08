-- Mutator selection and application (server-authoritative)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Mutators = require(ReplicatedStorage.Shared.Mutators)

local MutatorService = {}
MutatorService.__index = MutatorService

function MutatorService.new()
	local self = setmetatable({}, MutatorService)
	self.LastMutatorId = nil
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
	if not mutator then
		return
	end
	-- TODO: implement per-mutator effects; keep server authoritative
end

return MutatorService
