local ActivityDefinitions = {}

local ACTIVITIES = {
	{
		id = "Courier",
		displayName = "Village Courier",
		destination = "CourierDepot",
		verb = "deliver",
		professionId = "Courier",
		rewardCoins = 55,
		rewardXp = 30,
		analyticsCategory = "career_courier",
	},
	{
		id = "Gardener",
		displayName = "Village Gardener",
		destination = "CommunityGarden",
		verb = "grow",
		professionId = "Farmer",
		rewardCoins = 45,
		rewardXp = 30,
		analyticsCategory = "career_gardener",
	},
	{
		id = "Designer",
		displayName = "Home Designer",
		destination = "HomeStore",
		verb = "decorate",
		professionId = "Designer",
		rewardCoins = 50,
		rewardXp = 30,
		analyticsCategory = "career_designer",
	},
	{
		id = "VillageExplorer",
		displayName = "Village Explorer",
		destination = "VillageTrail",
		verb = "explore",
		rewardCoins = 60,
		rewardXp = 35,
		analyticsCategory = "career_explorer",
	},
}

local BY_ID = {}
for _, activity in ACTIVITIES do
	BY_ID[activity.id] = activity
end

function ActivityDefinitions.get(activityId: string)
	return BY_ID[activityId]
end

function ActivityDefinitions.all()
	local result = {}
	for _, activity in ACTIVITIES do
		table.insert(result, activity)
	end
	return result
end

return ActivityDefinitions
