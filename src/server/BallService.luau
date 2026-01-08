-- Ball spawning and reset logic
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local BallService = {}
BallService.__index = BallService

function BallService.new()
	local self = setmetatable({}, BallService)
	self.Ball = nil
	self.LastTouchedTime = 0
	return self
end

function BallService:SpawnBall(parent, cframe)
	-- TODO: replace with actual ball asset
	local ball = Instance.new("Part")
	ball.Name = "Ball"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(2, 2, 2)
	ball.Position = cframe.Position
	ball.Parent = parent
	self.Ball = ball
	if Config.Physics2D.Mode == "ZLock" then
		local attachment = Instance.new("Attachment")
		attachment.Name = "PlaneAttachment"
		attachment.Parent = ball

		local plane = Instance.new("PlaneConstraint")
		plane.Name = "PlaneConstraint"
		plane.Attachment0 = attachment
		plane.Normal = Vector3.new(0, 0, 1)
		plane.Position = Vector3.new(0, 0, Config.Physics2D.PlaneZ)
		plane.Parent = ball
	end
	return ball
end

function BallService:ResetBall(cframe)
	if self.Ball then
		self.Ball:Destroy()
		self.Ball = nil
	end
	return self:SpawnBall(workspace, cframe)
end

return BallService
