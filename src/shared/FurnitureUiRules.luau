local FurnitureUiRules = {}

local REJECTION_COPY = {
	structural_collision = "That spot is blocked by a wall or a fixed home object.",
	not_at_home = "Go back to your own home before changing furniture.",
	out_of_bounds = "Keep the whole item inside your home.",
	overlap = "That would overlap furniture you already placed.",
	not_owned = "You do not own an available copy of that item.",
	placement_budget = "Your home has reached its furniture placement limit. Store an item before placing another.",
	rate_limit = "Too many placement changes at once. Try again in a moment.",
	home_unavailable = "Your home is not ready for furniture changes yet.",
	invalid_request = "TinyWorld could not understand that placement. Try another spot.",
}

function FurnitureUiRules.rejectionCopy(reason: any): string
	return REJECTION_COPY[reason] or "That placement was rejected by TinyWorld. Try another spot."
end

function FurnitureUiRules.furnitureIdFromButtonName(name: any): string?
	if type(name) ~= "string" then
		return nil
	end
	return string.match(name, "^Furniture_(.+)$")
end

function FurnitureUiRules.preferredFurnitureId(previousId: any, availableIds: any): string?
	if type(availableIds) ~= "table" then
		return nil
	end
	if type(previousId) == "string" then
		for _, itemId in availableIds do
			if itemId == previousId then
				return previousId
			end
		end
	end
	for _, itemId in availableIds do
		if type(itemId) == "string" then
			return itemId
		end
	end
	return nil
end

function FurnitureUiRules.placementAction(placementId: any): string
	return if type(placementId) == "string" and placementId ~= "" then "move" else "place"
end

function FurnitureUiRules.homeCatalogueReservedHeight(touchTarget: number, padding: number): number
	local safeTouchTarget = math.max(0, touchTarget)
	local safePadding = math.max(0, padding)
	local fixedChildren = 36 + 38 + (safeTouchTarget + 8) + safeTouchTarget
	return fixedChildren + (safePadding * 4)
end

return FurnitureUiRules
