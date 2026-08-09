local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local FurnitureDefinitions = require(shared:WaitForChild("FurnitureDefinitions"))
local FurniturePlacementRules = require(shared:WaitForChild("FurniturePlacementRules"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local RemoteGuard = require(script.Parent:WaitForChild("security"):WaitForChild("RemoteGuard"))
local FurniturePrefabBuilder = require(script.Parent:WaitForChild("FurniturePrefabBuilder"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local FurniturePlacementService = {}
FurniturePlacementService.__index = FurniturePlacementService

local function getRemote(): RemoteEvent
	local root = ReplicatedStorage:WaitForChild("TinyWorld")
	local existing = root:FindFirstChild("FurniturePlacementRemote")
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = "FurniturePlacementRemote"
	remote.Parent = root
	return remote
end

local function placementFolder(plot): Folder
	local existing = plot.houseContainer:FindFirstChild("TinyWorldPlacedFurniture")
	if existing and existing:IsA("Folder") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "TinyWorldPlacedFurniture"
	folder.Parent = plot.houseContainer
	return folder
end

local function placementCFrame(plot, placement): CFrame
	return plot.houseContainer:GetPivot()
		* CFrame.new(placement.x, placement.y, placement.z)
		* CFrame.Angles(0, math.rad(placement.rotation), 0)
end

local function countPlacements(profile): number
	local count = 0
	if type(profile.furniturePlacements) == "table" then
		for _ in profile.furniturePlacements do
			count += 1
		end
	end
	return count
end

local function finite(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function FurniturePlacementService.new(ProfileStore, PlayerStateService)
	local self = setmetatable({}, FurniturePlacementService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.plotService = nil
	self.remote = getRemote()
	self.promptConnections = {}
	self.remoteConnection = self.remote.OnServerEvent:Connect(function(player, payload)
		self:_handle(player, payload)
	end)
	return self
end

function FurniturePlacementService:setPlotService(plotService)
	self.plotService = plotService
end

function FurniturePlacementService:_reply(player: Player, ok: boolean, reason: string, placementId: string?)
	self.remote:FireClient(player, { ok = ok, reason = reason, placementId = placementId })
end

function FurniturePlacementService:_disconnectModel(model: Model)
	local connections = self.promptConnections[model]
	if connections then
		for _, connection in connections do
			if connection.Connected then
				connection:Disconnect()
			end
		end
		self.promptConnections[model] = nil
	end
end

function FurniturePlacementService:_removePlacement(owner: Player, model: Model, placementId: string)
	local profile = self.ProfileStore.get(owner)
	if profile == nil or type(profile.furniturePlacements) ~= "table" or profile.furniturePlacements[placementId] == nil then
		return false
	end
	profile.furniturePlacements[placementId] = nil
	self:_disconnectModel(model)
	model:Destroy()
	owner:SetAttribute("TinyWorldFurniturePlacementCount", countPlacements(profile))
	self.ProfileStore.save(owner)
	self.PlayerStateService.message(owner, "Furniture stored safely back in your Home collection.")
	return true
end

function FurniturePlacementService:_bindInteraction(owner: Player, model: Model, definition)
	local anchor = model:FindFirstChild("InteractionAnchor")
	if anchor == nil or not anchor:IsA("BasePart") then
		return
	end
	self:_disconnectModel(model)
	local connections = {}
	local usePrompt = anchor:FindFirstChild("FurnitureInteractionPrompt")
	if usePrompt and usePrompt:IsA("ProximityPrompt") then
		table.insert(connections, usePrompt.Triggered:Connect(function(player)
			if player ~= owner then
				self.PlayerStateService.message(player, "You can look around, but only the homeowner can change or use this item.")
				return
			end
			local profile = self.ProfileStore.get(player)
			if profile == nil then
				return
			end
			local active = model:GetAttribute("TinyWorldFurnitureActive") == true
			model:SetAttribute("TinyWorldFurnitureActive", not active)
			profile.homeUseCount += 1
			player:SetAttribute("TinyWorldHomeLastAction", definition.displayName)
			self.PlayerStateService.sync(player, profile)
			self.ProfileStore.save(player)
			if player:GetAttribute("TinyWorldFirstHomeInteractionLogged") ~= true then
				player:SetAttribute("TinyWorldFirstHomeInteractionLogged", true)
				TinyAnalyticsService.log(player, AnalyticsEvents.FirstHomeInteraction)
			end
			local messages = {
				rest = "You settled in for a cosy rest.",
				sit = "You took a seat and made yourself at home.",
				open = if active then "Closed." else "Opened.",
				store = "Storage is ready for your collected things.",
				read = "You spent a quiet moment reading.",
				cook = "The kitchen is ready. Something good is cooking.",
				wash = "All clean and sparkling.",
				craft = "Creative space ready for your next project.",
				bathe = "Warm bubbles, TinyWorld style.",
				shower = "The shower runs warm and bright.",
				water = "The plants got a good drink.",
				switch = if active then "Switched off." else "Switched on.",
				play = "Game time at home.",
				plant = "Ready for something new to grow.",
				harvest = "The garden is ready to gather.",
				dress = "Your wardrobe is ready for a new look.",
				use = "Used.",
			}
			self.PlayerStateService.message(player, messages[definition.interaction] or (definition.displayName .. " used."))
		end))
	end

	local storePrompt = anchor:FindFirstChild("StoreFurniturePrompt")
	if storePrompt == nil then
		storePrompt = Instance.new("ProximityPrompt")
		storePrompt.Name = "StoreFurniturePrompt"
		storePrompt.ActionText = "Store"
		storePrompt.ObjectText = definition.displayName
		storePrompt.HoldDuration = 0.6
		storePrompt.MaxActivationDistance = 9
		storePrompt.RequiresLineOfSight = false
		storePrompt.Parent = anchor
	end
	if storePrompt:IsA("ProximityPrompt") then
		table.insert(connections, storePrompt.Triggered:Connect(function(player)
			if player ~= owner then
				self.PlayerStateService.message(player, "Only the homeowner can store this furniture.")
				return
			end
			local placementId = model:GetAttribute("TinyWorldPlacementId")
			if type(placementId) == "string" then
				self:_removePlacement(owner, model, placementId)
			end
		end))
	end
	self.promptConnections[model] = connections
	model.Destroying:Connect(function()
		self:_disconnectModel(model)
	end)
end

function FurniturePlacementService:_renderPlacement(owner: Player, plot, placementId: string, placement)
	local definition = FurnitureDefinitions.get(placement.furnitureId)
	if definition == nil then
		return nil
	end
	local folder = placementFolder(plot)
	local old = folder:FindFirstChild("PlacedFurniture_" .. placement.furnitureId .. "_" .. placementId)
	if old and old:IsA("Model") then
		self:_disconnectModel(old)
	end
	if old then
		old:Destroy()
	end
	local model = FurniturePrefabBuilder.build(folder, definition, placementCFrame(plot, placement), placementId)
	self:_bindInteraction(owner, model, definition)
	return model
end

function FurniturePlacementService:renderAll(owner: Player, plot, profile)
	local folder = placementFolder(plot)
	for _, child in folder:GetChildren() do
		if child:IsA("Model") then
			self:_disconnectModel(child)
		end
		child:Destroy()
	end
	if type(profile.furniturePlacements) ~= "table" then
		profile.furniturePlacements = {}
	end
	for placementId, placement in profile.furniturePlacements do
		self:_renderPlacement(owner, plot, placementId, placement)
	end
	owner:SetAttribute("TinyWorldFurniturePlacementCount", countPlacements(profile))
end

function FurniturePlacementService:_ownerContext(player: Player)
	if self.plotService == nil then
		return nil, nil
	end
	local plot = self.plotService:getPlotForPlayer(player)
	if plot == nil then
		return nil, nil
	end
	return plot, self.ProfileStore.get(player)
end

function FurniturePlacementService:_localRequest(plot, payload)
	if finite(payload.worldX) and finite(payload.worldY) and finite(payload.worldZ) then
		local localPoint = plot.houseContainer:GetPivot():PointToObjectSpace(Vector3.new(payload.worldX, payload.worldY, payload.worldZ))
		return { x = localPoint.X, y = localPoint.Y, z = localPoint.Z, rotation = payload.rotation }
	end
	return { x = payload.x, y = payload.y, z = payload.z, rotation = payload.rotation }
end

function FurniturePlacementService:_handle(player: Player, payload: any)
	if not RemoteGuard.checkRate(player, "furniture_placement", 12, 5) then
		RemoteGuard.warn(player, "furniture_placement", "rate_limit")
		self:_reply(player, false, "rate_limit")
		return
	end
	if type(payload) ~= "table" or type(payload.action) ~= "string" or #payload.action > 16 then
		RemoteGuard.warn(player, "furniture_placement", "invalid_payload")
		self:_reply(player, false, "invalid_request")
		return
	end
	local plot, profile = self:_ownerContext(player)
	if plot == nil or profile == nil then
		self:_reply(player, false, "home_unavailable")
		return
	end

	if payload.action == "place" then
		if type(payload.furnitureId) ~= "string" or #payload.furnitureId > 48 then
			self:_reply(player, false, "invalid_furniture")
			return
		end
		local request = self:_localRequest(plot, payload)
		local valid, reason, canonical = FurniturePlacementRules.validate(profile, payload.furnitureId, request)
		if not valid or canonical == nil then
			self:_reply(player, false, reason)
			return
		end
		local placementId = HttpService:GenerateGUID(false)
		profile.furniturePlacements[placementId] = canonical
		self:_renderPlacement(player, plot, placementId, canonical)
		player:SetAttribute("TinyWorldFurniturePlacementCount", countPlacements(profile))
		self.ProfileStore.save(player)
		local definition = FurnitureDefinitions.get(payload.furnitureId)
		self.PlayerStateService.message(player, (definition and definition.displayName or "Furniture") .. " placed in your home.")
		TinyAnalyticsService.log(player, AnalyticsEvents.FurniturePlaced)
		self:_reply(player, true, "placed", placementId)
		return
	end

	if payload.action == "move" then
		if type(payload.placementId) ~= "string" or #payload.placementId > 64 then
			self:_reply(player, false, "invalid_placement")
			return
		end
		local request = self:_localRequest(plot, payload)
		local valid, reason, canonical = FurniturePlacementRules.validateExisting(profile, payload.placementId, request)
		if not valid or canonical == nil then
			self:_reply(player, false, reason)
			return
		end
		profile.furniturePlacements[payload.placementId] = canonical
		self:_renderPlacement(player, plot, payload.placementId, canonical)
		self.ProfileStore.save(player)
		self:_reply(player, true, "moved", payload.placementId)
		return
	end

	if payload.action == "store" then
		if type(payload.placementId) ~= "string" or #payload.placementId > 64 then
			self:_reply(player, false, "invalid_placement")
			return
		end
		local placement = profile.furniturePlacements[payload.placementId]
		if type(placement) ~= "table" then
			self:_reply(player, false, "unknown_placement")
			return
		end
		local folder = placementFolder(plot)
		local model = folder:FindFirstChild("PlacedFurniture_" .. tostring(placement.furnitureId) .. "_" .. payload.placementId)
		if model and model:IsA("Model") then
			self:_removePlacement(player, model, payload.placementId)
		else
			profile.furniturePlacements[payload.placementId] = nil
			player:SetAttribute("TinyWorldFurniturePlacementCount", countPlacements(profile))
			self.ProfileStore.save(player)
		end
		self:_reply(player, true, "stored", payload.placementId)
		return
	end

	RemoteGuard.warn(player, "furniture_placement", "unknown_action")
	self:_reply(player, false, "unknown_action")
end

function FurniturePlacementService:removePlayer(player: Player)
	RemoteGuard.clearPlayer(player)
end

return FurniturePlacementService
