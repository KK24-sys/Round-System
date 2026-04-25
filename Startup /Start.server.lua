--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local services = ServerScriptService.Services

local playerService = require(services.PlayerService)
local roundService = require(services.RoundService)

playerService:init()
roundService:init()
