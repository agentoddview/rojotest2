print("Hello world, from client!")

local UIController = require(script.Parent.UIController)
local InputController = require(script.Parent.InputController)
local CameraController = require(script.Parent.CameraController)
local MenuController = require(script.Parent.MenuController)

local ui = UIController.new()
ui:Init()

local input = InputController.new()
input:Init()

local camera = CameraController.new()
camera:Start()

local menu = MenuController.new()
menu:Init()
