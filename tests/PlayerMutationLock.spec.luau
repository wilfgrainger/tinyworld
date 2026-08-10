local TestUtil = require("./TestUtil")
local PlayerMutationLock = require("../src/shared/PlayerMutationLock")
local Inventory = require("../src/shared/Inventory")

return function()
	local profile = {
		inventory = { Carrot = 1, SugarCrystal = 0 },
		inventoryStacks = { Carrot = 1, SugarCrystal = 0 },
	}
	local owner = "trade:txn-1"

	TestUtil.isTrue(PlayerMutationLock.acquire(profile, owner))
	TestUtil.isTrue(PlayerMutationLock.isLocked(profile))
	TestUtil.isFalse(Inventory.add(profile, "Carrot", 1), "ordinary reward mutation must fail while trade owns lock")
	TestUtil.isTrue(Inventory.remove(profile, "Carrot", 1, owner), "trade owner must be able to mutate locked profile")
	TestUtil.isTrue(Inventory.add(profile, "SugarCrystal", 1, owner), "trade owner must be able to add while locked")
	TestUtil.isFalse(PlayerMutationLock.release(profile, "reward"), "non-owner cannot release trade lock")
	TestUtil.isTrue(PlayerMutationLock.release(profile, owner))
	TestUtil.isFalse(PlayerMutationLock.isLocked(profile))
	TestUtil.isTrue(Inventory.add(profile, "Carrot", 1), "ordinary rewards resume after trade unlock")
end
