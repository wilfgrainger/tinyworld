local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HouseCatalog = require(shared:WaitForChild("HouseCatalog"))
local HouseUpgrade = require(shared:WaitForChild("HouseUpgrade"))
local Progression = require(shared:WaitForChild("Progression"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local function syncPlayerState(player: Player, profile)
	player:SetAttribute("TinyWorldXP", profile.xp)
	player:SetAttribute("TinyWorldHouseTier", profile.houseTier)

	local house = HouseCatalog.get(profile.houseTier)
	player:SetAttribute("TinyWorldHouseName", if house then house.name else "Unknown")

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		local level = leaderstats:FindFirstChild("Level")
		if coins then
			coins.Value = profile.coins
		end
		if level then
			level.Value = profile.level
		end
	end
end

local function createLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Parent = leaderstats
end

local function onPlayerAdded(player: Player)
	local profile = ProfileStore.load(player)
	if profile == nil then
		player:Kick("TinyWorld could not safely load your saved data. Please rejoin in a moment.")
		return
	end

	createLeaderstats(player)
	syncPlayerState(player, profile)
end

local function onPlayerRemoving(player: Player)
	ProfileStore.release(player)
end

local function createDemoPart(name: string, position: Vector3, actionText: string): ProximityPrompt
	local existing = Workspace:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = Vector3.new(6, 1, 6)
	part.Position = position
	part.Parent = Workspace

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = "TinyWorld v0.1 Demo"
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 12
	prompt.Parent = part

	return prompt
end

local function setupStudioDemo()
	if not RunService:IsStudio() then
		return
	end

	local missionPrompt = createDemoPart("TinyWorldMissionDemo", Vector3.new(-4, 3, 0), "Complete Demo Mission")
	missionPrompt.Triggered:Connect(function(player)
		local profile = ProfileStore.get(player)
		if profile == nil then
			return
		end

		profile.coins += 250
		local levelsGained = Progression.addXp(profile, 100)
		player:SetAttribute("TinyWorldLastMessage", string.format("Mission complete: +250 coins, +100 XP, +%d level(s)", levelsGained))
		syncPlayerState(player, profile)
	end)

	local upgradePrompt = createDemoPart("TinyWorldUpgradeDemo", Vector3.new(4, 3, 0), "Upgrade House")
	upgradePrompt.Triggered:Connect(function(player)
		local profile = ProfileStore.get(player)
		if profile == nil then
			return
		end

		local upgraded, reason = HouseUpgrade.tryUpgrade(profile)
		if upgraded then
			local house = HouseCatalog.get(profile.houseTier)
			player:SetAttribute("TinyWorldLastMessage", string.format("House upgraded to %s", if house then house.name else "next tier"))
		else
			player:SetAttribute("TinyWorldLastMessage", string.format("House upgrade blocked: %s", reason))
		end
		syncPlayerState(player, profile)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

setupStudioDemo()

game:BindToClose(function()
	ProfileStore.saveAll()
end)
