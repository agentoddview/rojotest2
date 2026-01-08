-- Mutator definitions and weights
local Mutators = {}

Mutators.Tiers = {
	Common = 60,
	Uncommon = 25,
	Rare = 10,
	Mythic = 5,
}

Mutators.List = {
	{ Id = "LowGravity", Tier = "Common", Weight = 10 },
	{ Id = "HighGravity", Tier = "Common", Weight = 10 },
	{ Id = "BouncyFloor", Tier = "Common", Weight = 8 },
	{ Id = "SlipperyFloor", Tier = "Common", Weight = 8 },
	{ Id = "WindLeft", Tier = "Common", Weight = 6 },
	{ Id = "WindRight", Tier = "Common", Weight = 6 },
	{ Id = "TinyBall", Tier = "Uncommon", Weight = 6 },
	{ Id = "HeavyBall", Tier = "Uncommon", Weight = 6 },
	{ Id = "LightBall", Tier = "Uncommon", Weight = 6 },
	{ Id = "BigHead", Tier = "Uncommon", Weight = 5 },
	{ Id = "LongArms", Tier = "Uncommon", Weight = 5 },
	{ Id = "ShortArms", Tier = "Uncommon", Weight = 5 },
	{ Id = "GiantPlayers", Tier = "Uncommon", Weight = 4 },
	{ Id = "TinyPlayers", Tier = "Uncommon", Weight = 4 },
	{ Id = "DoubleHoops", Tier = "Rare", Weight = 3 },
	{ Id = "MovingHoops", Tier = "Rare", Weight = 3 },
	{ Id = "TrampolineRims", Tier = "Rare", Weight = 3 },
	{ Id = "SuperJump", Tier = "Rare", Weight = 3 },
	{ Id = "NoJump", Tier = "Rare", Weight = 2 },
	{ Id = "HyperSpin", Tier = "Rare", Weight = 2 },
	{ Id = "MagnetBall", Tier = "Rare", Weight = 2 },
	{ Id = "StickyHands", Tier = "Rare", Weight = 2 },
	{ Id = "ReverseControls", Tier = "Rare", Weight = 2 },
	{ Id = "ExplosiveBall", Tier = "Mythic", Weight = 1 },
	{ Id = "ChaosGravitySwap", Tier = "Mythic", Weight = 1 },
	{ Id = "OneLeg", Tier = "Mythic", Weight = 1 },
	{ Id = "GhostBall", Tier = "Mythic", Weight = 1 },
	{ Id = "SlowMo", Tier = "Mythic", Weight = 1 },
}

return Mutators
