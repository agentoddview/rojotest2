-- Persistence layer with MMR updates
local DataStoreService = game:GetService("DataStoreService")

local DataService = {}
DataService.__index = DataService

function DataService.new()
	local self = setmetatable({}, DataService)
	self.Profiles = {}
	self.Store = DataStoreService:GetDataStore("RoboHoopsProfiles")
	return self
end

local function defaultProfile()
	return {
		Wins = 0,
		Losses = 0,
		MMR = 1000,
		Cosmetics = {},
		PlacementMatches = 0,
	}
end

function DataService:LoadProfile(userId)
	if self.Profiles[userId] then
		return self.Profiles[userId]
	end

	local profile = defaultProfile()
	local success, data = pcall(function()
		return self.Store:GetAsync(tostring(userId))
	end)
	if success and typeof(data) == "table" then
		for k, v in pairs(data) do
			profile[k] = v
		end
	end
	self.Profiles[userId] = profile
	return profile
end

function DataService:GetProfile(userId)
	return self.Profiles[userId] or self:LoadProfile(userId)
end

function DataService:SaveProfile(userId)
	local profile = self.Profiles[userId]
	if not profile then
		return
	end
	pcall(function()
		self.Store:SetAsync(tostring(userId), profile)
	end)
end

function DataService:RecordWinLoss(winnerIds, loserIds)
	for _, userId in ipairs(winnerIds) do
		local profile = self:GetProfile(userId)
		profile.Wins += 1
	end
	for _, userId in ipairs(loserIds) do
		local profile = self:GetProfile(userId)
		profile.Losses += 1
	end
end

function DataService:UpdateMMR(winnerIds, loserIds, kFactor)
	local function averageMMR(ids)
		local total = 0
		for _, userId in ipairs(ids) do
			total += self:GetProfile(userId).MMR
		end
		return total / math.max(1, #ids)
	end

	local winnerAvg = averageMMR(winnerIds)
	local loserAvg = averageMMR(loserIds)
	local expectedWin = 1 / (1 + 10 ^ ((loserAvg - winnerAvg) / 400))

	for _, userId in ipairs(winnerIds) do
		local profile = self:GetProfile(userId)
		local delta = math.floor(kFactor * (1 - expectedWin))
		profile.MMR += delta
		profile.PlacementMatches += 1
	end
	for _, userId in ipairs(loserIds) do
		local profile = self:GetProfile(userId)
		local delta = math.floor(kFactor * (0 - (1 - expectedWin)))
		profile.MMR += delta
		profile.PlacementMatches += 1
	end
end

return DataService
