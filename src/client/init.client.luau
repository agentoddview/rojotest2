print("Hello world, from client!")

local UIController = require(script:WaitForChild("UIController"))
local InputController = require(script:WaitForChild("InputController"))
local CameraController = require(script:WaitForChild("CameraController"))
local MenuController = require(script:WaitForChild("MenuController"))

local ui = UIController.new()
ui:Init()

local input = InputController.new()
input:Init()

local camera = CameraController.new()
camera:Start()

local menu = MenuController.new()
menu:Init()
