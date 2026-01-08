-- Basic UI controller placeholder
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = {}
UIController.__index = UIController

function UIController.new()
	local self = setmetatable({}, UIController)
	self.Player = Players.LocalPlayer
	return self
end

function UIController:Init()
	-- TODO: build queue button + score UI
end

return UIController
