--!strict
local RoundService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

const INTERMISSION = 3
const ROUND_DURATION = 8

local playerService = require(ServerScriptService.Services.PlayerService)
local dataManager = require(ServerScriptService.Data.DataManager)

type RoundService = typeof(RoundService) & {
	currentMap: Folder?
}

function RoundService.init(self: RoundService)
	self.currentMap = nil
	
	while true do
		self:countDown(INTERMISSION)
		
		local map = self:getMap()
		self:startRound(map)
		
		--Check win condition
		local elapsed = 0
		while elapsed <= ROUND_DURATION do
			task.wait(1)
			elapsed += 1
			
			if self:metWinCondition() then 
				break
			end
		end
		
		self:onRoundFinished()
	end
end

function RoundService.countDown(self: RoundService, duration: number)
	for i = duration, 1, -1 do
		task.wait(1)

		print(`{i} seconds left`)
	end
end

function RoundService.getMap(self: RoundService): Folder
	local maps = ReplicatedStorage.Maps:GetChildren() :: {Folder}
	local index = math.random(1, #maps)
	
	local map = maps[index]
	
	return map
end

function RoundService.getRandomSpawn(self: RoundService, spawns: Folder): BasePart
	local allSpawns = spawns:GetChildren()
	local index = math.random(1, #allSpawns)
	
	return allSpawns[index]
end

function RoundService.startRound(self: RoundService, map: Folder)	
	self.currentMap = map
	map.Parent = workspace.Live
	
	local eligible = playerService:getEligiblePlayers()
	playerService:addPlayers(eligible)
	
	local spawns = map:FindFirstChild("Spawns") :: Folder
	local inRound = playerService:getInRound()
	
	for _, player in inRound do
		local character = player.Character
		if not character then
			playerService:eliminate(player)
			continue
		end
		
		local spawnArea = self:getRandomSpawn(spawns)
		character:PivotTo(spawnArea.CFrame)
	end
end

function RoundService.metWinCondition(self: RoundService): boolean
	local inRound = playerService:getInRound()
	return #inRound <= 1
end

function RoundService.rewardWinners(self: RoundService)
	local winners = playerService:getInRound()
	
	for _, player in winners do
		dataManager.addWins(player, 1)
		print(`{player.Name} has survived the round!`)
	end
end

function RoundService.onRoundFinished(self: RoundService)
	self:rewardWinners()
	playerService:releasePlayers()
	
	self.currentMap.Parent = ReplicatedStorage.Maps
end

return RoundService
