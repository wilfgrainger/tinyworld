local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local FurnitureDefinitions = require(shared:WaitForChild("FurnitureDefinitions"))
local ShopDefinitions = require(shared:WaitForChild("ShopDefinitions"))
local RemoteGuard = require(script.Parent:WaitForChild("security"):WaitForChild("RemoteGuard"))

local HomeStoreService = {}
HomeStoreService.__index = HomeStoreService

local LEGACY_HOME_IDS = {
	Bed = true,
	KitchenCounter = true,
	Wardrobe = true,
	CreativeDesk = true,
}

local function getRemote(): RemoteEvent
	local root = ReplicatedStorage:WaitForChild("TinyWorld")
	local existing = root:FindFirstChild("HomeStoreRemote")
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = "HomeStoreRemote"
	remote.Parent = root
	return remote
end

function HomeStoreService.new(ProfileStore, PlayerStateService)
	local self = setmetatable({}, HomeStoreService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.remote = getRemote()
	self.connection = self.remote.OnServerEvent:Connect(function(player, payload)
		self:_handle(player, payload)
	end)
	return self
end

function HomeStoreService:_reply(player: Player, ok: boolean, reason: string, furnitureId: string?)
	self.remote:FireClient(player, {
		ok = ok,
		reason = reason,
		furnitureId = furnitureId,
	})
end

function HomeStoreService:_handle(player: Player, payload: any)
	if not RemoteGuard.checkRate(player, "home_store", 8, 5) then
		RemoteGuard.warn(player, "home_store", "rate_limit")
		self:_reply(player, false, "rate_limit")
		return
	end
	if type(payload) ~= "table" or payload.action ~= "purchase" or type(payload.furnitureId) ~= "string" or #payload.furnitureId > 48 then
		RemoteGuard.warn(player, "home_store", "invalid_payload")
		self:_reply(player, false, "invalid_request")
		return
	end

	local furnitureId = payload.furnitureId
	local definition = FurnitureDefinitions.get(furnitureId)
	local price = ShopDefinitions.priceFor("HomeStore", furnitureId)
	if definition == nil or price == nil then
		RemoteGuard.warn(player, "home_store", "unknown_furniture")
		self:_reply(player, false, "unknown_furniture")
		return
	end

	local profile = self.ProfileStore.get(player)
	if profile == nil then
		self:_reply(player, false, "profile_unavailable")
		return
	end
	if price < 0 or profile.coins < price then
		self.PlayerStateService.message(player, string.format("%s costs %d coins.", definition.displayName, price))
		self:_reply(player, false, "not_enough_coins", furnitureId)
		return
	end

	if type(profile.ownedFurniture) ~= "table" then
		profile.ownedFurniture = {}
	end
	local current = profile.ownedFurniture[furnitureId] or 0
	if current >= 99 then
		self:_reply(player, false, "ownership_limit", furnitureId)
		return
	end

	profile.coins -= price
	profile.ownedFurniture[furnitureId] = current + 1
	if LEGACY_HOME_IDS[furnitureId] then
		profile.homeItems[furnitureId] = 1
	end

	self.PlayerStateService.sync(player, profile)
	player:SetAttribute("TinyWorldLastFurniturePurchase", furnitureId)
	self.ProfileStore.save(player)
	self.PlayerStateService.message(player, string.format("%s is now in your Home collection. Place it when you are home.", definition.displayName))
	self:_reply(player, true, "purchased", furnitureId)
end

function HomeStoreService:removePlayer(player: Player)
	RemoteGuard.clearPlayer(player)
end

return HomeStoreService
