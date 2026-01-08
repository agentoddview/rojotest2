-- Main menu UI (queue + status)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuController = {}
MenuController.__index = MenuController

function MenuController.new()
	local self = setmetatable({}, MenuController)
	self.Player = Players.LocalPlayer
	self.Remotes = ReplicatedStorage:WaitForChild("Remotes")
	self.QueueEvent = self.Remotes:WaitForChild("QueueEvent")
	self.Ui = nil
	return self
end

function MenuController:Init()
	local playerGui = self.Player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MenuUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "MenuFrame"
	frame.Size = UDim2.new(0, 360, 0, 220)
	frame.Position = UDim2.new(0.5, -180, 0.5, -110)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.BackgroundTransparency = 1
	title.Text = "Robo Hoops"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = frame

	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 220, 0, 56)
	playButton.Position = UDim2.new(0.5, -110, 0, 90)
	playButton.BackgroundColor3 = Color3.fromRGB(30, 170, 90)
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.Font = Enum.Font.GothamBold
	playButton.TextScaled = true
	playButton.Text = "Play"
	playButton.Parent = frame

	local status = Instance.new("TextLabel")
	status.Name = "QueueStatus"
	status.Size = UDim2.new(1, -40, 0, 36)
	status.Position = UDim2.new(0, 20, 0, 155)
	status.BackgroundTransparency = 1
	status.TextColor3 = Color3.fromRGB(180, 180, 180)
	status.Font = Enum.Font.Gotham
	status.TextScaled = true
	status.Text = "Not queued"
	status.Parent = frame

	playButton.Activated:Connect(function()
		if status.Text == "Not queued" then
			self.QueueEvent:FireServer("Enqueue")
			status.Text = "Queued..."
			playButton.Text = "Cancel"
			playButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
		else
			self.QueueEvent:FireServer("Dequeue")
			status.Text = "Not queued"
			playButton.Text = "Play"
			playButton.BackgroundColor3 = Color3.fromRGB(30, 170, 90)
		end
	end)

	self.Ui = screenGui
end

return MenuController
