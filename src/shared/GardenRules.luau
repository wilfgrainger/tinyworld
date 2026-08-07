local Inventory
local Progression

if script ~= nil then
	Inventory = require(script.Parent.Inventory)
	Progression = require(script.Parent.Progression)
else
	Inventory = require("./Inventory")
	Progression = require("./Progression")
end

local GardenRules = {}
GardenRules.GROW_SECONDS = 5

function GardenRules.plant(bed: any, _now: number): (boolean, string)
	if bed.stage ~= "empty" then
		return false, "bed_not_empty"
	end
	bed.stage = "planted"
	bed.readyAt = 0
	return true, "planted"
end

function GardenRules.water(bed: any, now: number): (boolean, string)
	if bed.stage ~= "planted" then
		return false, "not_planted"
	end
	bed.stage = "watered"
	bed.readyAt = math.floor(now) + GardenRules.GROW_SECONDS
	return true, "watered"
end

function GardenRules.refresh(bed: any, now: number): string
	if bed.stage == "watered" and now >= bed.readyAt then
		bed.stage = "ready"
	end
	return bed.stage
end

function GardenRules.harvest(profile: any, bed: any, now: number): (boolean, string)
	GardenRules.refresh(bed, now)
	if bed.stage ~= "ready" then
		return false, "not_ready"
	end
	Inventory.add(profile, "Carrot", 1)
	Progression.addXp(profile, 10)
	bed.stage = "empty"
	bed.readyAt = 0
	return true, "harvested"
end

return GardenRules
