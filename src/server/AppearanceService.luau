local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local AppearanceDefinitions = require(shared:WaitForChild("AppearanceDefinitions"))
local RemoteGuard = require(script.Parent:WaitForChild("security"):WaitForChild("RemoteGuard"))

local AppearanceService = {}
AppearanceService.__index = AppearanceService

local PALETTES = {
	Starter = {
		torso = Color3.fromRGB(104, 153, 93),
		arms = Color3.fromRGB(246, 231, 183),
		legs = Color3.fromRGB(112, 76, 48),
	},
	Meadow = {
		torso = Color3.fromRGB(104, 153, 93),
		arms = Color3.fromRGB(246, 231, 183),
		legs = Color3.fromRGB(92, 118, 69),
	},
	Harbor = {
		torso = Color3.fromRGB(67, 119, 168),
		arms = Color3.fromRGB(211, 220, 226),
		legs = Color3.fromRGB(38, 56, 82),
	},
	Sunset = {
		torso = Color3.fromRGB(222, 111, 51),
		arms = Color3.fromRGB(255, 205, 91),
		legs = Color3.fromRGB(91, 54, 44),
	},
	Courier = {
		torso = Color3.fromRGB(206, 153, 55),
		arms = Color3.fromRGB(245, 226, 184),
		legs = Color3.fromRGB(68, 76, 92),
	},
	Workshop = {
		torso = Color3.fromRGB(74, 97, 112),
		arms = Color3.fromRGB(223, 203, 166),
		legs = Color3.fromRGB(82, 67, 56),
	},
	Moonlight = {
		torso = Color3.fromRGB(91, 91, 151),
		arms = Color3.fromRGB(222, 218, 244),
		legs = Color3.fromRGB(55, 55, 91),
	},
	Cloudpost = {
		torso = Color3.fromRGB(101, 164, 196),
		arms = Color3.fromRGB(244, 240, 214),
		legs = Color3.fromRGB(74, 103, 135),
	},
}

local function getRemote(): RemoteEvent
	local root = ReplicatedStorage:WaitForChild("TinyWorld")
	local existing = root:FindFirstChild("AppearanceRemote")
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = "AppearanceRemote"
	remote.Parent = root
	return remote
end

local function applyLook(player: Player, outfitId: string, hairId: string)
	local character = player.Character
	local palette = PALETTES[outfitId] or PALETTES.Starter
	if character then
		local bodyColors = character:FindFirstChildOfClass("BodyColors")
		if bodyColors == nil then
			bodyColors = Instance.new("BodyColors")
			bodyColors.Parent = character
		end
		bodyColors.TorsoColor = BrickColor.new(palette.torso)
		bodyColors.LeftArmColor = BrickColor.new(palette.arms)
		bodyColors.RightArmColor = BrickColor.new(palette.arms)
		bodyColors.LeftLegColor = BrickColor.new(palette.legs)
		bodyColors.RightLegColor = BrickColor.new(palette.legs)
	end
	player:SetAttribute("TinyWorldHairStyle", hairId)
	player:SetAttribute("TinyWorldActiveOutfit", outfitId)
end

function AppearanceService.new(ProfileStore, PlayerStateService)
	local self = setmetatable({}, AppearanceService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.remote = getRemote()
	self.connections = {}
	self.remoteConnection = self.remote.OnServerEvent:Connect(function(player, payload)
		self:_handle(player, payload)
	end)
	return self
end

function AppearanceService:_sendState(player: Player, profile)
	local active = profile.savedOutfits[profile.activeOutfitId] or profile.savedOutfits.Starter
	self.remote:FireClient(player, {
		kind = "state",
		outfitId = profile.activeOutfitId,
		hairId = active and active.hair or "Tousled",
	})
end

function AppearanceService:setupPlayer(player: Player, profile)
	local previous = self.connections[player]
	if previous then
		previous:Disconnect()
	end
	local active = profile.savedOutfits[profile.activeOutfitId] or profile.savedOutfits.Starter
	applyLook(player, profile.activeOutfitId, active and active.hair or "Tousled")
	self.connections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.2)
		local latest = self.ProfileStore.get(player)
		if latest then
			local latestOutfit = latest.savedOutfits[latest.activeOutfitId] or latest.savedOutfits.Starter
			applyLook(player, latest.activeOutfitId, latestOutfit and latestOutfit.hair or "Tousled")
		end
	end)
end

function AppearanceService:_handle(player: Player, payload: any)
	if not RemoteGuard.checkRate(player, "appearance", 8, 5) then
		RemoteGuard.warn(player, "appearance", "rate_limit")
		return
	end
	if type(payload) ~= "table" or type(payload.action) ~= "string" then
		RemoteGuard.warn(player, "appearance", "invalid_payload")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	if payload.action == "state" then
		self:_sendState(player, profile)
		return
	end
	if
		payload.action ~= "save"
		or type(payload.outfitId) ~= "string"
		or type(payload.hairId) ~= "string"
		or #payload.outfitId > 32
		or #payload.hairId > 32
	then
		RemoteGuard.warn(player, "appearance", "invalid_save")
		return
	end
	local outfit = AppearanceDefinitions.getOutfit(payload.outfitId)
	local hair = AppearanceDefinitions.getHair(payload.hairId)
	if outfit == nil or hair == nil then
		RemoteGuard.warn(player, "appearance", "unknown_definition")
		return
	end
	profile.savedOutfits[payload.outfitId] = {
		hair = payload.hairId,
		top = outfit.top,
		bottom = outfit.bottom,
		shoes = outfit.shoes,
		accessory = outfit.accessory,
	}
	profile.activeOutfitId = payload.outfitId
	applyLook(player, payload.outfitId, payload.hairId)
	self.ProfileStore.save(player)
	self.PlayerStateService.message(player, outfit.displayName .. " saved as your active look.")
	self:_sendState(player, profile)
end

function AppearanceService:removePlayer(player: Player)
	local connection = self.connections[player]
	if connection then
		connection:Disconnect()
	end
	self.connections[player] = nil
	RemoteGuard.clearPlayer(player)
end

return AppearanceService
