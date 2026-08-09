local PortalMechanicBuilder = {}

local COLORS = {
	cream = Color3.fromRGB(244, 232, 203),
	ink = Color3.fromRGB(45, 51, 62),
	metal = Color3.fromRGB(133, 142, 151),
	gold = Color3.fromRGB(228, 181, 73),
	berry = Color3.fromRGB(186, 88, 115),
	moon = Color3.fromRGB(158, 146, 224),
	leaf = Color3.fromRGB(91, 151, 91),
	sky = Color3.fromRGB(100, 174, 211),
	brass = Color3.fromRGB(169, 125, 59),
	wood = Color3.fromRGB(128, 87, 57),
}

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = cframe
	value.Color = color
	value.Material = material or Enum.Material.SmoothPlastic
	value.Anchored = true
	value.CanCollide = true
	value.CanTouch = false
	value.CanQuery = true
	value.TopSurface = Enum.SurfaceType.Smooth
	value.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		value.Shape = shape
	end
	value:SetAttribute("TinyWorldArtRole", "portal-mechanic-prop")
	value:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	value.Parent = parent
	return value
end

local function prompt(parent: BasePart, actionText: string, objectText: string): ProximityPrompt
	parent:SetAttribute("TinyWorldInteractionAnchor", true)
	local value = Instance.new("ProximityPrompt")
	value.ActionText = actionText
	value.ObjectText = objectText
	value.HoldDuration = 0.25
	value.MaxActivationDistance = 11
	value.RequiresLineOfSight = false
	value.Parent = parent
	return value
end

local function modelFor(world, worldId: string): Model
	local model = Instance.new("Model")
	model.Name = worldId .. "Mechanics"
	model:SetAttribute("TinyWorldArtRole", "portal-world-mechanics")
	model.Parent = world.root
	return model
end

local function kitchen(world, area)
	local model = modelFor(world, "GiantKitchen")
	local origin = area.arrivalCFrame.Position
	part(model, "GiantCookerPanel", Vector3.new(26, 8, 4), CFrame.new(origin + Vector3.new(20, 4, 15)), COLORS.cream, Enum.Material.Metal)
	local prompts = {}
	local parts = {}
	for index, x in { -7, 0, 7 } do
		local knob = part(
			model,
			"GiantCookerKnob" .. index,
			Vector3.new(2.2, 5.2, 5.2),
			CFrame.new(origin + Vector3.new(20 + x, 4, 12.7)) * CFrame.Angles(0, 0, math.rad(90)),
			if index == 2 then COLORS.berry else COLORS.ink,
			Enum.Material.Metal,
			Enum.PartType.Cylinder
		)
		table.insert(parts, knob)
		table.insert(prompts, prompt(knob, "Turn", "Giant Cooker Knob"))
	end
	local secret = part(model, "TinyRecipeCard", Vector3.new(3.2, 0.25, 4.5), CFrame.new(origin + Vector3.new(-18, 1.1, -15)), COLORS.cream, Enum.Material.SmoothPlastic)
	secret:SetAttribute("TinyWorldArtRole", "portal-secret-recipe-card")
	area.mechanicPrompts = prompts
	area.mechanicParts = parts
	area.mechanicName = "cooker knob"
	area.secretPrompt = prompt(secret, "Read", "Tiny Recipe Card")
	area.secretPart = secret
	area.secretName = "a tiny recipe card hidden in the giant kitchen"
end

local function meadow(world, area)
	local model = modelFor(world, "MoonlitMeadow")
	local origin = area.arrivalCFrame.Position
	local prompts = {}
	local parts = {}
	for index, offset in {
		Vector3.new(-16, 1.5, 10),
		Vector3.new(0, 1.5, 20),
		Vector3.new(16, 1.5, 10),
	} do
		local stem = part(model, "MoonStem" .. index, Vector3.new(0.5, 3, 0.5), CFrame.new(origin + offset), COLORS.leaf, Enum.Material.Grass)
		stem.CanCollide = false
		local bloom = part(model, "MoonFlower" .. index, Vector3.new(3.2, 3.2, 3.2), CFrame.new(origin + offset + Vector3.new(0, 2.3, 0)), COLORS.moon, Enum.Material.Glass, Enum.PartType.Ball)
		bloom.CanCollide = false
		table.insert(parts, bloom)
		table.insert(prompts, prompt(bloom, "Wake", "Moon Flower"))
	end
	local jar = part(model, "FireflyNest", Vector3.new(3.2, 4.2, 3.2), CFrame.new(origin + Vector3.new(22, 2.1, -18)), COLORS.sky, Enum.Material.Glass)
	jar.CanCollide = false
	jar:SetAttribute("TinyWorldArtRole", "portal-secret-fireflies")
	area.mechanicPrompts = prompts
	area.mechanicParts = parts
	area.mechanicName = "moon flower"
	area.secretPrompt = prompt(jar, "Peek", "Hidden Firefly Nest")
	area.secretPart = jar
	area.secretName = "a sleeping firefly nest tucked away from the path"
end

local function cloudpost(world, area)
	local model = modelFor(world, "CloudpostObservatory")
	local origin = area.arrivalCFrame.Position
	local prompts = {}
	local parts = {}
	for index, offset in {
		Vector3.new(-18, 6, 18),
		Vector3.new(0, 8, 28),
		Vector3.new(18, 6, 18),
	} do
		part(model, "ChimePost" .. index, Vector3.new(0.6, 8, 0.6), CFrame.new(origin + offset), COLORS.brass, Enum.Material.Metal)
		local bell = part(
			model,
			"WindBell" .. index,
			Vector3.new(3.2, 4.2, 4.2),
			CFrame.new(origin + offset + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			COLORS.gold,
			Enum.Material.Metal,
			Enum.PartType.Cylinder
		)
		bell.CanCollide = false
		table.insert(parts, bell)
		table.insert(prompts, prompt(bell, "Ring", "Sky Bell"))
	end
	local postcard = part(model, "LostPostcard", Vector3.new(4.5, 0.2, 3), CFrame.new(origin + Vector3.new(-28, 2.5, 26)) * CFrame.Angles(0, math.rad(18), math.rad(7)), COLORS.cream, Enum.Material.SmoothPlastic)
	postcard.CanCollide = false
	postcard:SetAttribute("TinyWorldArtRole", "portal-secret-postcard")
	area.mechanicPrompts = prompts
	area.mechanicParts = parts
	area.mechanicName = "sky bell"
	area.secretPrompt = prompt(postcard, "Read", "Lost Postcard")
	area.secretPart = postcard
	area.secretName = "a lost postcard addressed to somebody in TinyWorld"
end

local function clockwork(world, area)
	local model = modelFor(world, "ClockworkOrchard")
	local origin = area.arrivalCFrame.Position
	local prompts = {}
	local parts = {}
	for index, offset in {
		Vector3.new(-20, 5, -14),
		Vector3.new(0, 7, -8),
		Vector3.new(20, 5, -14),
	} do
		local gear = part(
			model,
			"OrchardGear" .. index,
			Vector3.new(1.2, 7.5, 7.5),
			CFrame.new(origin + offset) * CFrame.Angles(0, 0, math.rad(90)),
			if index == 2 then COLORS.gold else COLORS.brass,
			Enum.Material.Metal,
			Enum.PartType.Cylinder
		)
		gear.CanCollide = false
		table.insert(parts, gear)
		table.insert(prompts, prompt(gear, "Wind", "Orchard Gear"))
	end
	local key = part(model, "ClockworkKey", Vector3.new(1.1, 5.5, 1.1), CFrame.new(origin + Vector3.new(32, 3, 20)) * CFrame.Angles(0, 0, math.rad(42)), COLORS.gold, Enum.Material.Metal)
	key.CanCollide = false
	key:SetAttribute("TinyWorldArtRole", "portal-secret-clockwork-key")
	area.mechanicPrompts = prompts
	area.mechanicParts = parts
	area.mechanicName = "orchard gear"
	area.secretPrompt = prompt(key, "Inspect", "Tiny Clockwork Key")
	area.secretPart = key
	area.secretName = "a tiny key that does not seem to fit the giant clock"
end

function PortalMechanicBuilder.extend(world)
	if world.kitchen and world.kitchen.arrivalCFrame then
		kitchen(world, world.kitchen)
	end
	if world.moonlitMeadow and world.moonlitMeadow.arrivalCFrame then
		meadow(world, world.moonlitMeadow)
	end
	if world.cloudpostObservatory and world.cloudpostObservatory.arrivalCFrame then
		cloudpost(world, world.cloudpostObservatory)
	end
	if world.clockworkOrchard and world.clockworkOrchard.arrivalCFrame then
		clockwork(world, world.clockworkOrchard)
	end
	return world
end

return PortalMechanicBuilder
