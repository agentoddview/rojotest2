-- Side-view camera that follows the local player on a 2D plane
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local CameraController = {}
CameraController.__index = CameraController

function CameraController.new()
	local self = setmetatable({}, CameraController)
	self.Player = Players.LocalPlayer
	self.Camera = workspace.CurrentCamera
	self.Connection = nil
	return self
end

function CameraController:Start()
	self.Camera.CameraType = Enum.CameraType.Scriptable
	self.Connection = RunService.RenderStepped:Connect(function()
		local character = self.Player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end
		local target = hrp.Position
		local offset = Config.Physics2D.CameraOffset
		local camPos = Vector3.new(target.X + offset.X, target.Y + offset.Y, Config.Physics2D.PlaneZ + offset.Z)
		self.Camera.CFrame = CFrame.new(camPos, Vector3.new(target.X, target.Y, Config.Physics2D.PlaneZ))
	end)
end

function CameraController:Stop()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
	self.Camera.CameraType = Enum.CameraType.Custom
end

return CameraController
