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
	self.MatchEvent = self.Remotes:WaitForChild("MatchEvent")
	self.ScoreEvent = self.Remotes:WaitForChild("ScoreEvent")
	self.Ui = nil
	self.Muted = false
	return self
end

function MenuController:Init()
	local playerGui = self.Player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MenuUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local matchSound = Instance.new("Sound")
	matchSound.Name = "MatchFoundSound"
	matchSound.SoundId = "rbxassetid://9118823101"
	matchSound.Volume = 0.6
	matchSound.Parent = screenGui

	local countdownGui = Instance.new("ScreenGui")
	countdownGui.Name = "CountdownUI"
	countdownGui.ResetOnSpawn = false
	countdownGui.Enabled = false
	countdownGui.Parent = playerGui

	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.Size = UDim2.new(0, 240, 0, 80)
	countdownLabel.Position = UDim2.new(0.5, -120, 0.35, 0)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	countdownLabel.Font = Enum.Font.GothamBlack
	countdownLabel.TextScaled = true
	countdownLabel.Text = ""
	countdownLabel.Parent = countdownGui

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

	local returnButton = Instance.new("TextButton")
	returnButton.Name = "ReturnButton"
	returnButton.Size = UDim2.new(0, 220, 0, 40)
	returnButton.Position = UDim2.new(0.5, -110, 1, -50)
	returnButton.BackgroundColor3 = Color3.fromRGB(70, 90, 170)
	returnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	returnButton.Font = Enum.Font.GothamBold
	returnButton.TextScaled = true
	returnButton.Text = "Return to Menu"
	returnButton.Visible = false
	returnButton.Parent = frame

	local soundButton = Instance.new("TextButton")
	soundButton.Name = "SoundButton"
	soundButton.Size = UDim2.new(0, 120, 0, 32)
	soundButton.Position = UDim2.new(0, 20, 1, -40)
	soundButton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	soundButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	soundButton.Font = Enum.Font.GothamBold
	soundButton.TextScaled = true
	soundButton.Text = "Sound: On"
	soundButton.Parent = frame

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

	soundButton.Activated:Connect(function()
		self.Muted = not self.Muted
		if self.Muted then
			soundButton.Text = "Sound: Off"
			matchSound.Volume = 0
		else
			soundButton.Text = "Sound: On"
			matchSound.Volume = 0.6
		end
	end)

	returnButton.Activated:Connect(function()
		screenGui.Enabled = true
		status.Text = "Not queued"
		playButton.Text = "Play"
		playButton.BackgroundColor3 = Color3.fromRGB(30, 170, 90)
		returnButton.Visible = false
		local gameUi = playerGui:FindFirstChild("GameUI")
		if gameUi then
			gameUi.Enabled = false
		end
	end)

	self.MatchEvent.OnClientEvent:Connect(function(message)
		if message == "MatchFound" then
			status.Text = "Match found!"
			playButton.Text = "Play"
			playButton.BackgroundColor3 = Color3.fromRGB(30, 170, 90)
			matchSound:Play()
			countdownGui.Enabled = true
			task.spawn(function()
				local steps = { "3", "2", "1", "GO!" }
				for _, text in ipairs(steps) do
					countdownLabel.Text = text
					task.wait(0.7)
				end
				countdownLabel.Text = ""
				countdownGui.Enabled = false
			end)
			task.delay(1.5, function()
				if status then
					status.Text = "In match"
				end
			end)
			task.delay(2.0, function()
				if screenGui then
					screenGui.Enabled = false
				end
				local gameUi = playerGui:FindFirstChild("GameUI")
				if gameUi then
					gameUi.Enabled = true
				end
			end)
		end
	end)

	self.ScoreEvent.OnClientEvent:Connect(function(_, _, matchOver)
		if matchOver then
			screenGui.Enabled = true
			status.Text = "Match ended"
			returnButton.Visible = true
			local gameUi = playerGui:FindFirstChild("GameUI")
			if gameUi then
				gameUi.Enabled = false
			end
		end
	end)

	self.Ui = screenGui
end

return MenuController
