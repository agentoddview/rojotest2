-- Shared configuration for gameplay tuning
local Config = {}

Config.Game = {
	PointsToWin = 5,
	RoundFreezeSeconds = 2.0,
	BallStuckSeconds = 8.0,
	OutOfBoundsRespawnSeconds = 1.5,
	MaxMatchSeconds = 180,
	MinPlayersPerTeam = 2,
	MaxPlayersPerTeam = 2,
}

Config.Physics2D = {
	-- Option A: Full Z lock (recommended). Keep characters/ball on a plane.
	Mode = "ZLock", -- "ZLock" | "Corridor"
	PlaneZ = 0,
	ZTolerance = 1.5,
	CorridorHalfWidth = 6,
	CameraOffset = Vector3.new(0, 6, 24),
}

Config.Mutators = {
	-- Global weight multiplier
	WeightScale = 1.0,
	CooldownPoints = 0,
}

Config.Matchmaking = {
	QueueTick = 1.0,
	MaxPingMs = 200,
	Region = "AUTO",
}

Config.Ranked = {
	KFactor = 24,
	PlacementMatches = 5,
	MinGamesForRank = 10,
}

return Config
