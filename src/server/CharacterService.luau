-- Character spawning and 2D constraint setup
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local CharacterService = {}
CharacterService.__index = CharacterService

function CharacterService.new()
	local self = setmetatable({}, CharacterService)
	return self
end

function CharacterService:ApplyPlaneConstraint(part)
	if part:FindFirstChild("PlaneConstraint") then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "PlaneAttachment"
	attachment.Parent = part

	local plane = Instance.new("PlaneConstraint")
	plane.Name = "PlaneConstraint"
	plane.Attachment0 = attachment
	plane.Normal = Vector3.new(0, 0, 1)
	plane.Position = Vector3.new(0, 0, Config.Physics2D.PlaneZ)
	plane.Parent = part
end

function CharacterService:Apply2DConstraint(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	if Config.Physics2D.Mode == "ZLock" then
		self:ApplyPlaneConstraint(hrp)
	else
		-- TODO: corridor walls are part of arena
	end
end

function CharacterService:RespawnPlayer(player, spawnCFrame)
	player:LoadCharacter()
	if spawnCFrame then
		local character = player.Character or player.CharacterAdded:Wait()
		character:PivotTo(spawnCFrame)
		self:Apply2DConstraint(character)
	end
end

return CharacterService
