local ActivityDefinitions = {}

local ACTIVITIES = {
	{
		id = "Courier",
		displayName = "Village Courier",
		destination = "CourierDepot",
		verb = "deliver",
		rewardCoins = 55,
		rewardXp = 30,
		analyticsCategory = "career_courier",
	},
	{
		id = "Gardener",
		displayName = "Village Gardener",
		destination = "CommunityGarden",
		verb = "grow",
		rewardCoins = 45,
		rewardXp = 30,
		analyticsCategory = "career_gardener",
	},
	{
		id = "Designer",
		displayName = "Home Designer",
		destination = "HomeStore",
		verb = "decorate",
		rewardCoins = 50,
		rewardXp = 30,
		analyticsCategory = "career_designer",
	},
	{
		id = "HarborHelper",
		displayName = "Harbour Helper",
		destination = "Harbor",
		verb = "help",
		rewardCoins = 60,
		rewardXp = 35,
		analyticsCategory = "career_harbor",
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
