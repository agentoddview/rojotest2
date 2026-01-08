-- Arena construction and spawn points
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local ArenaService = {}
ArenaService.__index = ArenaService

function ArenaService.new()
	local self = setmetatable({}, ArenaService)
	return self
end

local function createPart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in pairs(props) do
		part[key] = value
	end
	return part
end

function ArenaService:CreateArena()
	local arena = Instance.new("Folder")
	arena.Name = "Arena"
	arena.Parent = workspace

	local floor = createPart({
		Name = "Floor",
		Size = Vector3.new(120, 2, 20),
		Position = Vector3.new(0, 0, Config.Physics2D.PlaneZ),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(50, 130, 200),
		Parent = arena,
	})

	local backWallA = createPart({
		Name = "BackWallA",
		Size = Vector3.new(2, 24, 20),
		Position = Vector3.new(-60, 12, Config.Physics2D.PlaneZ),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(20, 20, 20),
		Parent = arena,
	})

	local backWallB = createPart({
		Name = "BackWallB",
		Size = Vector3.new(2, 24, 20),
		Position = Vector3.new(60, 12, Config.Physics2D.PlaneZ),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(20, 20, 20),
		Parent = arena,
	})

	if Config.Physics2D.Mode == "Corridor" then
		createPart({
			Name = "ZWallFront",
			Size = Vector3.new(120, 24, 2),
			Position = Vector3.new(0, 12, Config.Physics2D.PlaneZ + Config.Physics2D.CorridorHalfWidth),
			Transparency = 0.75,
			Color = Color3.fromRGB(10, 10, 10),
			Parent = arena,
		})

		createPart({
			Name = "ZWallBack",
			Size = Vector3.new(120, 24, 2),
			Position = Vector3.new(0, 12, Config.Physics2D.PlaneZ - Config.Physics2D.CorridorHalfWidth),
			Transparency = 0.75,
			Color = Color3.fromRGB(10, 10, 10),
			Parent = arena,
		})
	end

	local function createHoop(rootX, teamKey)
		local hoopFolder = Instance.new("Folder")
		hoopFolder.Name = "Hoop" .. teamKey
		hoopFolder.Parent = arena

		createPart({
			Name = "Backboard",
			Size = Vector3.new(2, 10, 12),
			Position = Vector3.new(rootX, 12, Config.Physics2D.PlaneZ),
			Color = Color3.fromRGB(230, 230, 230),
			Parent = hoopFolder,
		})

		createPart({
			Name = "Rim",
			Size = Vector3.new(2, 1, 6),
			Position = Vector3.new(rootX - (teamKey == "A" and -3 or 3), 10, Config.Physics2D.PlaneZ),
			Color = Color3.fromRGB(220, 120, 20),
			Parent = hoopFolder,
		})

		local trigger = createPart({
			Name = "GoalTrigger",
			Size = Vector3.new(4, 4, 6),
			Position = Vector3.new(rootX - (teamKey == "A" and -5 or 5), 8.5, Config.Physics2D.PlaneZ),
			Transparency = 1,
			CanCollide = false,
			Parent = hoopFolder,
		})
		trigger:SetAttribute("Team", teamKey)
		return trigger
	end

	local goalA = createHoop(-52, "A")
	local goalB = createHoop(52, "B")

	local spawns = {
		TeamA = CFrame.new(-25, 6, Config.Physics2D.PlaneZ),
		TeamB = CFrame.new(25, 6, Config.Physics2D.PlaneZ),
		Ball = CFrame.new(0, 12, Config.Physics2D.PlaneZ),
	}

	return {
		Folder = arena,
		Floor = floor,
		BackWallA = backWallA,
		BackWallB = backWallB,
		GoalA = goalA,
		GoalB = goalB,
		Spawns = spawns,
	}
end

return ArenaService
