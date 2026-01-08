-- Server-side input validation and impulse application
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputService = {}
InputService.__index = InputService

function InputService.new()
	local self = setmetatable({}, InputService)
	self.LastInputTime = {}
	self.ChargeStartTime = {}
	self.Remote = self:CreateRemote()
	return self
end

function InputService:CreateRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = ReplicatedStorage
	end

	local inputEvent = remotes:FindFirstChild("InputEvent")
	if not inputEvent then
		inputEvent = Instance.new("RemoteEvent")
		inputEvent.Name = "InputEvent"
		inputEvent.Parent = remotes
	end

	return inputEvent
end

local function applyImpulseToCharacter(character, chargeSeconds)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local mass = hrp.AssemblyMass
	local jumpForce = 45 + (70 * chargeSeconds)
	local impulse = Vector3.new(0, jumpForce * mass, 0)
	hrp:ApplyImpulse(impulse)

	local spin = 8 + (16 * chargeSeconds)
	hrp:ApplyAngularImpulse(Vector3.new(0, 0, spin * mass))
end

function InputService:HandleInput(player, action)
	local now = os.clock()
	local last = self.LastInputTime[player.UserId] or 0
	if now - last < 0.08 then
		return
	end
	self.LastInputTime[player.UserId] = now

	if action == "JumpStart" then
		self.ChargeStartTime[player.UserId] = now
		return
	end

	if action == "JumpRelease" then
		local start = self.ChargeStartTime[player.UserId] or now
		self.ChargeStartTime[player.UserId] = nil
		local charge = math.clamp(now - start, 0.05, 1.0)
		if player.Character then
			applyImpulseToCharacter(player.Character, charge)
		end
	end
end

function InputService:Start()
	self.Remote.OnServerEvent:Connect(function(player, action)
		if typeof(action) ~= "string" then
			return
		end
		self:HandleInput(player, action)
	end)
end

return InputService
