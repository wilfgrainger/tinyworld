local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Inventory = require(shared:WaitForChild("Inventory"))
local TradeRules = require(shared:WaitForChild("TradeRules"))

local TradeService = {}
TradeService.__index = TradeService

local function offerName(itemName: string?): string
	if itemName == "SugarCrystal" then
		return "Sugar Crystal"
	elseif itemName == "Carrot" then
		return "Carrot"
	end
	return "nothing"
end

function TradeService.new(world, ProfileStore, PlayerStateService, SocialService)
	local self = setmetatable({}, TradeService)
	self.world = world
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.SocialService = SocialService
	self.players = {}
	self.offers = {}
	self.confirmedVersion = {}
	self.lastActivity = {}
	self.version = 1
	self.TRADE_TIMEOUT_SECONDS = 120

	for side, refs in world.trade.sides do
		refs.joinPrompt.Triggered:Connect(function(player)
			self:_join(player, side)
		end)
		refs.offerPrompt.Triggered:Connect(function(player)
			self:_chooseOffer(player, side)
		end)
		refs.confirmPrompt.Triggered:Connect(function(player)
			self:_confirm(player, side)
		end)
	end
	self:_updateSign()
	return self
end

function TradeService:_touch(player: Player)
	self.lastActivity[player] = os.clock()
end

function TradeService:_pruneExpired()
	local now = os.clock()
	local changed = false
	for player, last in self.lastActivity do
		if now - last >= self.TRADE_TIMEOUT_SECONDS then
			local side = self:_sideForPlayer(player)
			if side then
				self.players[side] = nil
				self.offers[player] = nil
				self.confirmedVersion[player] = nil
				changed = true
			end
			self.lastActivity[player] = nil
		end
	end
	if changed then
		self:_invalidateConfirmations()
		self:_updateSign()
	end
end

function TradeService:_sideForPlayer(player: Player): number?
	for side, occupant in self.players do
		if occupant == player then
			return side
		end
	end
	return nil
end

function TradeService:_invalidateConfirmations()
	self.version += 1
	self.confirmedVersion = {}
end

function TradeService:_join(player: Player, side: number)
	self:_pruneExpired()
	if self.ProfileStore.get(player) == nil then
		return
	end
	local currentSide = self:_sideForPlayer(player)
	if currentSide == side then
		self.players[side] = nil
		self.offers[player] = nil
		self.lastActivity[player] = nil
		self:_invalidateConfirmations()
		self.PlayerStateService.message(player, "You left the Trading Post.")
		self:_updateSign()
		return
	elseif currentSide ~= nil then
		self.PlayerStateService.message(player, "You are already on the other trade side.")
		return
	end
	if self.players[side] ~= nil then
		self.PlayerStateService.message(player, "That trade side is already occupied.")
		return
	end
	self.players[side] = player
	self.offers[player] = nil
	self:_touch(player)
	self:_invalidateConfirmations()
	self.PlayerStateService.message(player, string.format("Joined Trading Post side %s. Choose an item to offer.", if side == 1 then "A" else "B"))
	self:_updateSign()
end

function TradeService:_nextOffer(profile, current: string?): string?
	local candidates = { "Carrot", "SugarCrystal", false }
	local start = 1
	if current == "Carrot" then
		start = 2
	elseif current == "SugarCrystal" then
		start = 3
	end
	for offset = 0, 2 do
		local index = ((start - 1 + offset) % 3) + 1
		local candidate = candidates[index]
		if candidate == false then
			return nil
		end
		if Inventory.get(profile, candidate) > 0 then
			return candidate
		end
	end
	return nil
end

function TradeService:_chooseOffer(player: Player, side: number)
	self:_pruneExpired()
	if self.players[side] ~= player then
		self.PlayerStateService.message(player, "Join this side of the Trading Post first.")
		return
	end
	local profile = self.ProfileStore.get(player)
	if profile == nil then
		return
	end
	local nextItem = self:_nextOffer(profile, self.offers[player])
	self.offers[player] = nextItem
	self:_touch(player)
	self:_invalidateConfirmations()
	self.PlayerStateService.message(player, "Trade offer set to " .. offerName(nextItem) .. ".")
	self:_updateSign()
end

function TradeService:_confirm(player: Player, side: number)
	self:_pruneExpired()
	if self.players[side] ~= player then
		self.PlayerStateService.message(player, "Join this trade side first.")
		return
	end
	if self.offers[player] == nil then
		self.PlayerStateService.message(player, "Choose an item to offer before confirming.")
		return
	end
	self.confirmedVersion[player] = self.version
	self:_touch(player)
	self.PlayerStateService.message(player, "Trade confirmed. Waiting for the other player.")
	self:_updateSign()

	local a = self.players[1]
	local b = self.players[2]
	if a and b and self.confirmedVersion[a] == self.version and self.confirmedVersion[b] == self.version then
		self:_complete(a, b)
	end
end

function TradeService:_complete(a: Player, b: Player)
	local profileA = self.ProfileStore.get(a)
	local profileB = self.ProfileStore.get(b)
	if profileA == nil or profileB == nil then
		self:_invalidateConfirmations()
		self:_updateSign()
		return
	end
	local itemA = self.offers[a]
	local itemB = self.offers[b]
	if itemA == nil or itemB == nil then
		self:_invalidateConfirmations()
		self:_updateSign()
		return
	end

	local traded, reason = TradeRules.exchange(profileA, itemA, profileB, itemB)
	if not traded then
		self:_invalidateConfirmations()
		self.PlayerStateService.message(a, "Trade stopped because inventory changed: " .. reason)
		self.PlayerStateService.message(b, "Trade stopped because inventory changed: " .. reason)
		self:_updateSign()
		return
	end

	self.PlayerStateService.sync(a, profileA)
	self.PlayerStateService.sync(b, profileB)
	self.ProfileStore.save(a)
	self.ProfileStore.save(b)
	if self.SocialService then
		self.SocialService:recordTrade(a, b)
	end
	self.PlayerStateService.message(a, string.format("Trade complete: your %s for %s's %s.", offerName(itemA), b.Name, offerName(itemB)))
	self.PlayerStateService.message(b, string.format("Trade complete: your %s for %s's %s.", offerName(itemB), a.Name, offerName(itemA)))
	self.players = {}
	self.offers = {}
	self:_invalidateConfirmations()
	self:_updateSign()
end

function TradeService:_updateSign()
	local lines = { "TRADING POST" }
	for side = 1, 2 do
		local player = self.players[side]
		if player then
			local confirmed = self.confirmedVersion[player] == self.version
			table.insert(lines, string.format("%s: %s offers %s%s", if side == 1 then "A" else "B", player.Name, offerName(self.offers[player]), if confirmed then " ✓" else ""))
		else
			table.insert(lines, string.format("%s: available", if side == 1 then "A" else "B"))
		end
	end
	self.world.trade.statusLabel.Text = table.concat(lines, "\n")
end

function TradeService:removePlayer(player: Player)
	local side = self:_sideForPlayer(player)
	if side then
		self.players[side] = nil
		self.offers[player] = nil
		self.lastActivity[player] = nil
		self:_invalidateConfirmations()
		self:_updateSign()
	end
end

return TradeService

