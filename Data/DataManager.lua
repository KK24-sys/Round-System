--!strict
local DataManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

DataManager.profiles = {}

DataManager.addWins = function(player: Player, amount: number)
	local profile = DataManager.profiles[player]
	if not profile then return end

	profile.Data.Wins += amount
	
	player.leaderstats.Wins.Value = profile.Data.Wins
end

DataManager.checkWins = function(player: Player)
	local proile = DataManager.profiles[player]
	if not proile then return end
	
	return proile.Data.Wins
end

return DataManager
