--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.Data.ProfileStore)

local function getStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end

local template = require(ServerScriptService.Data.Template)
local dataManger = require(ServerScriptService.Data.DataManager)

local playerStore = ProfileStore.New(getStoreName(), template)

local function initialize(player: Player, profile: typeof(playerStore:StartSessionAsync()))
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local wins = Instance.new("NumberValue")
	wins.Name = "Wins"
	wins.Value = profile.Data.Wins
	wins.Parent = leaderstats
end

local function playerAdded(player: Player)
	local profile = playerStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players 
		end,
	})
	
	if profile ~= nil then
		
		profile:AddUserId(player.UserId)
		profile:Reconcile() 
		
		profile.OnSessionEnd:Connect(function()
			dataManger.profiles[player] = nil
			
			player:Kick("Data error occured, your data is safe. Please rejoin!")
		end)
		
		if player.Parent == Players then
			
			dataManger.profiles[player] = profile
			initialize(player, profile)
			
		else
			profile:EndSession()
		end
		
	else
		player:Kick("Data error occured, your data is safe. Please rejoin!")
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(playerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = dataManger.profiles[player]
	if not profile then return end
	
	profile:EndSession()
	dataManger.profiles[player] = nil
end)
