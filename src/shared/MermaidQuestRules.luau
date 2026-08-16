local MermaidQuestRules = {}

local QUESTS = {
	PearlTrail = { coins = 75, xp = 50 },
	CoralGarden = { coins = 100, xp = 60 },
	LostParcel = { coins = 125, xp = 75 },
	MoonShells = { coins = 150, xp = 90 },
	WhirlpoolPromise = { coins = 250, xp = 150 },
}

local ORDER = { "PearlTrail", "CoralGarden", "LostParcel", "MoonShells", "WhirlpoolPromise" }

function MermaidQuestRules.all(): { string }
	return table.clone(ORDER)
end

function MermaidQuestRules.get(questId: string)
	return QUESTS[questId]
end

function MermaidQuestRules.canEnter(profile: any, inOuterSea: boolean): (boolean, string?)
	if not profile.ownsTinyBoat then
		return false, "boat_required"
	end
	if not profile.boatActive then
		return false, "boat_not_active"
	end
	if not inOuterSea then
		return false, "outer_sea_required"
	end
	return true, nil
end

function MermaidQuestRules.complete(profile: any, questId: string): (boolean, string?)
	local quest = QUESTS[questId]
	if quest == nil then
		return false, "unknown_quest"
	end
	local key = "MermaidQuest:" .. questId
	if profile.keepsakes[key] == 1 then
		return false, "already_complete"
	end
	profile.keepsakes[key] = 1
	profile.discoveredWorlds.MermaidLand = true
	profile.coins += quest.coins
	profile.xp += quest.xp
	return true, nil
end

function MermaidQuestRules.completedCount(profile: any): number
	local count = 0
	for _, questId in ORDER do
		if profile.keepsakes["MermaidQuest:" .. questId] == 1 then
			count += 1
		end
	end
	return count
end

return MermaidQuestRules
