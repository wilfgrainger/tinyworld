local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local HouseCatalog = require(shared:WaitForChild("HouseCatalog"))
local GoalRules = require(shared:WaitForChild("GoalRules"))

local PlayerStateService = {}

function PlayerStateService.setup(player: Player, profile)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats == nil then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local coins = leaderstats:FindFirstChild("Coins")
	if coins == nil then
		coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Parent = leaderstats
	end

	local level = leaderstats:FindFirstChild("Level")
	if level == nil then
		level = Instance.new("IntValue")
		level.Name = "Level"
		level.Parent = leaderstats
	end

	PlayerStateService.sync(player, profile)
end

function PlayerStateService.sync(player: Player, profile)
	local house = HouseCatalog.get(profile.houseTier)
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

	player:SetAttribute("TinyWorldCoins", profile.coins)
	player:SetAttribute("TinyWorldLevel", profile.level)
	player:SetAttribute("TinyWorldXP", profile.xp)
	player:SetAttribute("TinyWorldHouseTier", profile.houseTier)
	player:SetAttribute("TinyWorldHouseName", if house then house.name else "Unknown")
	player:SetAttribute("TinyWorldCarrots", profile.inventory.Carrot)
	player:SetAttribute("TinyWorldSugarCrystals", profile.inventory.SugarCrystal)
	player:SetAttribute("TinyWorldCourierLevel", profile.courierLevel)
	player:SetAttribute("TinyWorldCourierXP", profile.courierXp)
	player:SetAttribute("TinyWorldOwnsBike", profile.ownsTinyBike)
	player:SetAttribute("TinyWorldBikeActive", profile.bikeActive)
	player:SetAttribute("TinyWorldPortalCompletions", profile.portalCompletions)
	player:SetAttribute("TinyWorldVillageContribution", profile.villageContribution)
	player:SetAttribute("TinyWorldHomePrivacy", profile.homePrivacy)
	player:SetAttribute("TinyWorldDisplayName", profile.displayName)
	player:SetAttribute("TinyWorldAvatarStyle", profile.avatarStyle)
	player:SetAttribute("TinyWorldStarterOutfit", profile.starterOutfit)
	player:SetAttribute("TinyWorldOnboardingComplete", profile.onboardingComplete)
	player:SetAttribute("TinyWorldOnboardingRequired", not profile.onboardingComplete)
	player:SetAttribute("TinyWorldSuggestedGoal", GoalRules.suggestedGoal(profile))
end

function PlayerStateService.message(player: Player, text: string)
	player:SetAttribute("TinyWorldLastMessage", text)
	player:SetAttribute("TinyWorldMessageNonce", (player:GetAttribute("TinyWorldMessageNonce") or 0) + 1)
end

return PlayerStateService
