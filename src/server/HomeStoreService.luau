local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local FurnitureDefinitions = require(shared:WaitForChild("FurnitureDefinitions"))
local ShopDefinitions = require(shared:WaitForChild("ShopDefinitions"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local RemoteGuard = require(script.Parent:WaitForChild("security"):WaitForChild("RemoteGuard"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

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

local function safeOwnedSnapshot(profile)
	local result = {}
	if type(profile.ownedFurniture) ~= "table" then
		return result
	end
	for _, definition in FurnitureDefinitions.all() do
		local quantity = profile.ownedFurniture[definition.id]
		if type(quantity) == "number" and quantity > 0 then
			result[definition.id] = math.max(0, math.floor(quantity))
		end
	end
	return result
end

local function safePlacementSnapshot(profile)
	local result = {}
	if type(profile.furniturePlacements) ~= "table" then
		return result
	end
	for placementId, placement in profile.furniturePlacements do
		if
			type(placementId) == "string"
			and type(placement) == "table"
			and type(placement.furnitureId) == "string"
			and type(placement.x) == "number"
			and type(placement.y) == "number"
			and type(placement.z) == "number"
			and type(placement.rotation) == "number"
		then
			result[placementId] = {
				furnitureId = placement.furnitureId,
				x = placement.x,
				y = placement.y,
				z = placement.z,
				rotation = placement.rotation,
			}
		end
	end
	return result
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
		kind = "result",
		ok = ok,
		reason = reason,
		furnitureId = furnitureId,
	})
end

function HomeStoreService:_sendState(player: Player, profile)
	self.remote:FireClient(player, {
		kind = "state",
		coins = profile.coins,
		ownedFurniture = safeOwnedSnapshot(profile),
		furniturePlacements = safePlacementSnapshot(profile),
		placementCount = if type(profile.furniturePlacements) == "table"
			then (function()
				local count = 0
				for _ in profile.furniturePlacements do
					count += 1
				end
				return count
			end)()
			else 0,
	})
end

function HomeStoreService:_handle(player: Player, payload: any)
	if not RemoteGuard.checkRate(player, "home_store", 10, 5) then
		RemoteGuard.warn(player, "home_store", "rate_limit")
		self:_reply(player, false, "rate_limit")
		return
	end
	if type(payload) ~= "table" or type(payload.action) ~= "string" or #payload.action > 16 then
		RemoteGuard.warn(player, "home_store", "invalid_payload")
		self:_reply(player, false, "invalid_request")
		return
	end

	local profile = self.ProfileStore.get(player)
	if profile == nil then
		self:_reply(player, false, "profile_unavailable")
		return
	end

	if payload.action == "state" then
		self:_sendState(player, profile)
		return
	end

	if payload.action ~= "purchase" or type(payload.furnitureId) ~= "string" or #payload.furnitureId > 48 then
		RemoteGuard.warn(player, "home_store", "invalid_purchase_payload")
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
	TinyAnalyticsService.log(player, AnalyticsEvents.HomePurchase)
	self.PlayerStateService.message(
		player,
		string.format("%s is now in your Home collection. Place it when you are home.", definition.displayName)
	)
	self:_reply(player, true, "purchased", furnitureId)
	self:_sendState(player, profile)
end

function HomeStoreService:removePlayer(player: Player)
	RemoteGuard.clearPlayer(player)
end

return HomeStoreService
