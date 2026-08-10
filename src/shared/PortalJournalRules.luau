local PortalJournalRules = {}

local WORLDS = {
	{ id = "GiantKitchen", name = "Giant Kitchen" },
	{ id = "MoonlitMeadow", name = "Moonlit Meadow" },
	{ id = "CloudpostObservatory", name = "Cloudpost Observatory" },
	{ id = "ClockworkOrchard", name = "Clockwork Orchard" },
}

function PortalJournalRules.copy(discovered: any): string
	local state = if type(discovered) == "table" then discovered else {}
	local lines = {}
	for _, world in WORLDS do
		table.insert(lines, world.name .. "  " .. if state[world.id] == true then "●" else "○")
	end
	return table.concat(lines, "\n")
end

return PortalJournalRules
