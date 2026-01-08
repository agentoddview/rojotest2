-- Mock persistence layer
local DataService = {}
DataService.__index = DataService

function DataService.new()
	local self = setmetatable({}, DataService)
	self.Profiles = {}
	return self
end

function DataService:GetProfile(userId)
	if not self.Profiles[userId] then
		self.Profiles[userId] = {
			Wins = 0,
			Losses = 0,
			MMR = 1000,
			Cosmetics = {},
		}
	end
	return self.Profiles[userId]
end

function DataService:SaveProfile(userId)
	-- TODO: DataStore wrapper
end

return DataService
