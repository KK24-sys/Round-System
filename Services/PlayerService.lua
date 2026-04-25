--!strict
local PlayerService = {}

local Players = game:GetService("Players")

local spawnArea = workspace.Lobby.SpawnArea

export type PlayerService = typeof(PlayerService) & {
	inRound: {[Player]: boolean}
}

function PlayerService.init(self: PlayerService)
	self.inRound = {}
	
	Players.PlayerAdded:Connect(function(player)
		local character = player.Character or player.CharacterAdded:Wait()
		
		if not self:isInRound(player) then
			character:PivotTo(spawnArea.CFrame)
		end
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		if self.inRound[player] then
			self.inRound[player] = nil
		end
	end)
end

function PlayerService.getEligiblePlayers(self: PlayerService): {Player}
	local eligible = {}
	
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("AFK") then continue end
		
		table.insert(eligible, player)
	end
	
	return eligible
end

function PlayerService.addPlayers(self: PlayerService, players: {Player})
	for _, player in players do
		if not player.Parent then continue end
		
		self.inRound[player] = true
	end
end

function PlayerService.releasePlayers(self: PlayerService)
	for player in self.inRound do
		self.inRound[player] = nil
		
		if not player.Parent then continue end

		local character = player.Character
		character:PivotTo(spawnArea.CFrame)
	end
end

function PlayerService.eliminate(self: PlayerService, player: Player)
	if not self.inRound[player] then return end

	self.inRound[player] = nil
	
	if not player.Parent then return end
	if not player.Character then return end
	
	player:PivotTo(spawnArea.CFrame)
end

function PlayerService.getInRound(self: PlayerService): {Player}
	local activePlayers = {}
	
	for player in self.inRound do 
		table.insert(activePlayers, player)
	end
		
	return activePlayers	
end

function PlayerService.isInRound(self: PlayerService, player: Player): boolean
	return self.inRound[player] == true
end

return PlayerService
