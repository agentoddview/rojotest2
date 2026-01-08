-- Input controller for one-button chaos
local ContextActionService = game:GetService("ContextActionService")

local InputController = {}
InputController.__index = InputController

function InputController.new()
	local self = setmetatable({}, InputController)
	self.Pressing = false
	return self
end

function InputController:Init()
	ContextActionService:BindAction("JumpFlip", function(_, state)
		if state == Enum.UserInputState.Begin then
			self.Pressing = true
		elseif state == Enum.UserInputState.End then
			self.Pressing = false
			-- TODO: send server request to apply flip impulse
		end
	end, true, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
end

return InputController
