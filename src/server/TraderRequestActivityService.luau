local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Inventory = require(shared:WaitForChild("Inventory"))

local TraderRequestActivityService = {}
TraderRequestActivityService.__index = TraderRequestActivityService

local REQUESTS = {
	{ itemId = "Carrot", displayName = "Carrot", hint = "Grow one in your home garden.", bonusCoins = 20 },
	{
		itemId = "SugarCrystal",
		displayName = "Sugar Crystal",
		hint = "Explore TinyWorld activities and impossible-world rewards.",
		bonusCoins = 30,
	},
}

function TraderRequestActivityService.new(_world, hooks)
	local self = setmetatable({}, TraderRequestActivityService)
	self.hooks = hooks
	return self
end

function TraderRequestActivityService:start(player: Player, state): (boolean, string?)
	local index = (math.abs(player.UserId) % #REQUESTS) + 1
	local request = REQUESTS[index]
	state.target = request.itemId
	state.requestDisplayName = request.displayName
	state.requestBonusCoins = request.bonusCoins
	self.hooks.message(
		player,
		"Mara needs 1 " .. request.displayName .. ". " .. request.hint .. " Bring it back to her when you have it."
	)
	return true, nil
end

function TraderRequestActivityService:interact(player: Player, state)
	local profile = self.hooks.profile(player)
	if profile == nil then
		return
	end
	local itemId = state.target
	if type(itemId) ~= "string" then
		self.hooks.message(player, "Mara has lost the request slip. Start the request again.")
		return
	end
	if Inventory.get(profile, itemId) < 1 then
		self.hooks.message(player, "Mara is still waiting for 1 " .. (state.requestDisplayName or itemId) .. ".")
		return
	end
	if not Inventory.remove(profile, itemId, 1) then
		self.hooks.message(player, "That item could not be handed in safely. Try again.")
		return
	end
	self.hooks.finish(
		player,
		"TraderRequest",
		"normal",
		"Mara's village request complete.",
		state.requestBonusCoins or 0
	)
end

function TraderRequestActivityService:removePlayer(_player: Player) end

return TraderRequestActivityService
