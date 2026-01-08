-- Basic UI controller placeholder
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

	local flashLabel = Instance.new("TextLabel")
	flashLabel.Name = "ScoreFlash"
	flashLabel.Size = UDim2.new(0, 220, 0, 60)
	flashLabel.Position = UDim2.new(0.5, -110, 0, 130)
	flashLabel.BackgroundTransparency = 1
	flashLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	flashLabel.Font = Enum.Font.GothamBlack
	flashLabel.TextScaled = true
	flashLabel.Text = "+1"
	flashLabel.TextTransparency = 1
	flashLabel.Parent = screenGui

	local matchLabel = Instance.new("TextLabel")
	matchLabel.Name = "MatchBanner"
	matchLabel.Size = UDim2.new(0, 360, 0, 60)
	matchLabel.Position = UDim2.new(0.5, -180, 0, 180)
	matchLabel.BackgroundTransparency = 0.2
	matchLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	matchLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
	matchLabel.Font = Enum.Font.GothamBold
	matchLabel.TextScaled = true
	matchLabel.Text = "Match Over!"
	matchLabel.TextTransparency = 1
	matchLabel.BackgroundTransparency = 1
	matchLabel.Parent = screenGui

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
			local show = TweenService:Create(matchLabel, TweenInfo.new(0.2), {
				TextTransparency = 0,
				BackgroundTransparency = 0.2,
			})
			local hide = TweenService:Create(matchLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.2), {
				TextTransparency = 1,
				BackgroundTransparency = 1,
			})
			show:Play()
			hide:Play()
		else
			local flashIn = TweenService:Create(flashLabel, TweenInfo.new(0.15), { TextTransparency = 0 })
			local flashOut = TweenService:Create(flashLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.4), {
				TextTransparency = 1,
			})
			flashIn:Play()
			flashOut:Play()
		end
	end)
end

return UIController
