local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local CompanionRules = require(shared:WaitForChild("CompanionRules"))

local CompanionService = {}
CompanionService.__index = CompanionService

local PALETTE = {
	colors = {
		catFur = Color3.fromRGB(99, 89, 82),
		dogFur = Color3.fromRGB(176, 126, 77),
		cream = Color3.fromRGB(244, 229, 201),
		dark = Color3.fromRGB(42, 42, 48),
		flap = Color3.fromRGB(79, 68, 61),
	},
}

local function component(name, shape, size, position, color, material, role)
	return {
		name = name,
		shape = shape,
		size = size,
		position = position,
		color = color,
		material = material or "fabric",
		role = role,
	}
end

local PETS = {
	TinyCat = {
		component("CatBody", "ellipsoid", { 2.6, 2.0, 4.0 }, { 0, 1.2, 0 }, "catFur", "fabric", "tiny-cat-body"),
		component("CatHead", "ellipsoid", { 2.2, 2.1, 2.2 }, { 0, 2.5, -1.55 }, "catFur", "fabric", "tiny-cat-head"),
		component("CatChest", "ellipsoid", { 1.25, 1.4, 0.5 }, { 0, 1.8, -2.55 }, "cream", "fabric", "tiny-cat-chest"),
	},
	TinyDog = {
		component("DogBody", "ellipsoid", { 3.0, 2.2, 4.4 }, { 0, 1.3, 0 }, "dogFur", "fabric", "tiny-dog-body"),
		component("DogHead", "ellipsoid", { 2.4, 2.3, 2.5 }, { 0, 2.6, -1.8 }, "dogFur", "fabric", "tiny-dog-head"),
		component("DogMuzzle", "ellipsoid", { 1.45, 1.0, 1.2 }, { 0, 2.2, -3.0 }, "cream", "fabric", "tiny-dog-muzzle"),
	},
}

local function buildPet(parent: Instance, petId: string, origin: CFrame)
	local model = Instance.new("Model")
	model.Name = petId
	model:SetAttribute("TinyWorldCompanion", petId)
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model.Parent = parent
	for _, spec in PETS[petId] do
		ProductionMeshFactory.createComponent(model, spec, origin, PALETTE)
	end
	return model
end

local function buildCatFlap(plot)
	if plot.houseContainer:FindFirstChild("TinyWorldCatFlap") then
		return
	end
	local model = Instance.new("Model")
	model.Name = "TinyWorldCatFlap"
	model.Parent = plot.houseContainer
	local base = if plot.homeAnchorCFrame then plot.homeAnchorCFrame else CFrame.new(plot.houseAnchor)
	ProductionMeshFactory.createComponent(
		model,
		component("CatFlap", "beveledBox", { 1.8, 2.0, 0.28 }, { -3.2, 1.0, -5.0 }, "flap", "wood", "tiny-cat-flap"),
		base,
		PALETTE
	)
end

function CompanionService.new(world, plotService, ProfileStore, PlayerStateService)
	local self = setmetatable({}, CompanionService)
	self.world = world
	self.plotService = plotService
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.folder = Instance.new("Folder")
	self.folder.Name = "TinyWorldCompanions"
	self.folder.Parent = world.root
	self.playerModels = {}
	return self
end

function CompanionService:_clear(player: Player)
	local model = self.playerModels[player]
	if model then
		model:Destroy()
		self.playerModels[player] = nil
	end
end

function CompanionService:apply(player: Player, profile)
	local changed = false
	if profile.level >= CompanionRules.requiredLevel() then
		for _, petId in { "TinyCat", "TinyDog" } do
			local unlocked = CompanionRules.unlock(profile, petId)
			if unlocked then
				changed = true
			end
		end
	end

	player:SetAttribute("TinyWorldTinyCatUnlocked", CompanionRules.isUnlocked(profile, "TinyCat"))
	player:SetAttribute("TinyWorldTinyDogUnlocked", CompanionRules.isUnlocked(profile, "TinyDog"))
	self:_clear(player)

	local plot = self.plotService:getPlotForPlayer(player)
	if plot then
		local holder = Instance.new("Folder")
		holder.Name = "Companions_" .. tostring(player.UserId)
		holder.Parent = self.folder
		self.playerModels[player] = holder
		local base = if plot.homeAnchorCFrame then plot.homeAnchorCFrame else CFrame.new(plot.houseAnchor)
		if CompanionRules.isUnlocked(profile, "TinyCat") then
			buildPet(holder, "TinyCat", base * CFrame.new(-5, 0, 4))
			buildCatFlap(plot)
		end
		if CompanionRules.isUnlocked(profile, "TinyDog") then
			buildPet(holder, "TinyDog", base * CFrame.new(5, 0, 4))
		end
	end

	if changed then
		self.PlayerStateService.sync(player, profile)
		self.PlayerStateService.message(
			player,
			"Level 10 companions unlocked: Tiny Cat and Tiny Dog are waiting at home."
		)
		self.ProfileStore.save(player)
	end
end

function CompanionService:trackPlayer(_player: Player) end

function CompanionService:removePlayer(player: Player)
	self:_clear(player)
end

function CompanionService:stop()
	self.folder:Destroy()
end

return CompanionService
