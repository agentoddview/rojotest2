-- Basic UI controller placeholder
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = {}
UIController.__index = UIController

function UIController.new()
	local self = setmetatable({}, UIController)
	self.Player = Players.LocalPlayer
	self.ScoreEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ScoreEvent")
	return self
end

function UIController:Init()
	local playerGui = self.Player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local scoreLabel = Instance.new("TextLabel")
	scoreLabel.Name = "ScoreLabel"
	scoreLabel.Size = UDim2.new(0, 240, 0, 50)
	scoreLabel.Position = UDim2.new(0.5, -120, 0, 20)
	scoreLabel.BackgroundTransparency = 0.25
	scoreLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	scoreLabel.Font = Enum.Font.GothamBold
	scoreLabel.TextScaled = true
	scoreLabel.Text = "0 - 0"
	scoreLabel.Parent = screenGui

	local mutatorLabel = Instance.new("TextLabel")
	mutatorLabel.Name = "MutatorLabel"
	mutatorLabel.Size = UDim2.new(0, 300, 0, 36)
	mutatorLabel.Position = UDim2.new(0.5, -150, 0, 80)
	mutatorLabel.BackgroundTransparency = 0.35
	mutatorLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mutatorLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
	mutatorLabel.Font = Enum.Font.Gotham
	mutatorLabel.TextScaled = true
	mutatorLabel.Text = "Mutator: None"
	mutatorLabel.Parent = screenGui

	self.ScoreEvent.OnClientEvent:Connect(function(score, mutator, matchOver)
		if score then
			scoreLabel.Text = tostring(score.A) .. " - " .. tostring(score.B)
		end
		if mutator and mutator.Id then
			mutatorLabel.Text = "Mutator: " .. mutator.Id
		else
			mutatorLabel.Text = "Mutator: None"
		end
		if matchOver then
			mutatorLabel.Text = "Match Over!"
		end
	end)
end

return UIController
