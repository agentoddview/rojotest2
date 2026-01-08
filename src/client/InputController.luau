-- Input controller for one-button chaos
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputController = {}
InputController.__index = InputController

function InputController.new()
	local self = setmetatable({}, InputController)
	self.Pressing = false
	self.Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("InputEvent")
	return self
end

function InputController:Init()
	ContextActionService:BindAction("JumpFlip", function(_, state)
		if state == Enum.UserInputState.Begin then
			self.Pressing = true
			self.Remote:FireServer("JumpStart")
		elseif state == Enum.UserInputState.End then
			self.Pressing = false
			self.Remote:FireServer("JumpRelease")
		end
	end, true, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
end

return InputController
