local ImpossibleWorldBuilder = {}

local COLORS = {
	paper = Color3.fromRGB(245, 239, 218),
	sky = Color3.fromRGB(120, 187, 220),
	cloud = Color3.fromRGB(238, 244, 245),
	blue = Color3.fromRGB(68, 121, 172),
	gold = Color3.fromRGB(227, 180, 76),
	brass = Color3.fromRGB(161, 119, 58),
	wood = Color3.fromRGB(132, 91, 60),
	woodDark = Color3.fromRGB(84, 57, 42),
	leaf = Color3.fromRGB(95, 143, 78),
	fruit = Color3.fromRGB(206, 105, 72),
	ink = Color3.fromRGB(43, 50, 62),
	portal = Color3.fromRGB(125, 93, 185),
}

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?, collide: boolean?): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = cframe
	value.Color = color
	value.Material = material or Enum.Material.SmoothPlastic
	value.Anchored = true
	value.CanCollide = collide ~= false
	value.CanTouch = false
	value.CanQuery = collide ~= false
	value.TopSurface = Enum.SurfaceType.Smooth
	value.BottomSurface = Enum.SurfaceType.Smooth
	value:SetAttribute("TinyWorldArtRole", "impossible-world-authored-prop")
	value:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	value.Parent = parent
	return value
end

local function ball(parent: Instance, name: string, diameter: number, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local value = part(parent, name, Vector3.new(diameter, diameter, diameter), cframe, color, material, false)
	value.Shape = Enum.PartType.Ball
	return value
end

local function cylinder(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local value = part(parent, name, size, cframe, color, material, false)
	value.Shape = Enum.PartType.Cylinder
	return value
end

local function prompt(parent: BasePart, actionText: string, objectText: string): ProximityPrompt
	parent.CanQuery = true
	parent:SetAttribute("TinyWorldInteractionAnchor", true)
	local value = Instance.new("ProximityPrompt")
	value.ActionText = actionText
	value.ObjectText = objectText
	value.HoldDuration = 0.2
	value.MaxActivationDistance = 12
	value.RequiresLineOfSight = false
	value.Parent = parent
	return value
end

local function portal(parent: Instance, name: string, position: Vector3, title: string): ProximityPrompt
	local frame = Instance.new("Model")
	frame.Name = name
	frame:SetAttribute("TinyWorldArtRole", "world-portal")
	frame.Parent = parent
	part(frame, "LeftPillar", Vector3.new(2, 11, 2), CFrame.new(position + Vector3.new(-5, 5.5, 0)), COLORS.portal, Enum.Material.Slate)
	part(frame, "RightPillar", Vector3.new(2, 11, 2), CFrame.new(position + Vector3.new(5, 5.5, 0)), COLORS.portal, Enum.Material.Slate)
	part(frame, "Top", Vector3.new(12, 2, 2), CFrame.new(position + Vector3.new(0, 11, 0)), COLORS.portal, Enum.Material.Slate)
	local core = part(frame, "PortalSurface", Vector3.new(8, 9, 0.5), CFrame.new(position + Vector3.new(0, 5.5, 0)), COLORS.sky, Enum.Material.Glass, false)
	core.Transparency = 0.25
	core:SetAttribute("TinyWorldWorldPortal", title)
	return prompt(core, "Enter " .. title, "Impossible World")
end

local function cloud(parent: Instance, position: Vector3, scale: number)
	for index, offset in { Vector3.new(-3, 0, 0), Vector3.new(0, 1, 0), Vector3.new(3, 0, 0), Vector3.new(1, -0.3, 2) } do
		ball(parent, "CloudPuff" .. index, 6 * scale, CFrame.new(position + offset * scale), COLORS.cloud, Enum.Material.SmoothPlastic)
	end
end

local function makeCollectible(parent: Instance, name: string, position: Vector3, color: Color3, label: string): ProximityPrompt
	local base = cylinder(parent, name .. "Stand", Vector3.new(0.7, 2.2, 2.2), CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)), COLORS.gold, Enum.Material.Metal)
	local item = ball(parent, name, 2.6, CFrame.new(position + Vector3.new(0, 2, 0)), color, Enum.Material.Neon)
	item:SetAttribute("TinyWorldArtRole", "portal-collectible")
	return prompt(item, "Collect", label)
end

local function buildCloudpost(parent: Instance, origin: Vector3)
	local model = Instance.new("Model")
	model.Name = "CloudpostObservatory"
	model:SetAttribute("TinyWorldArtRole", "portal-world-cloudpost")
	model.Parent = parent
	part(model, "CloudpostIsland", Vector3.new(150, 2, 130), CFrame.new(origin), COLORS.cloud, Enum.Material.SmoothPlastic)
	for i = 1, 8 do
		cloud(model, origin + Vector3.new(-55 + i * 14, -2 + (i % 2), -48 + (i % 3) * 42), 1 + (i % 2) * 0.25)
	end

	-- A physical post office with parcels, pigeon holes and a recognisable roof.
	part(model, "PostOffice", Vector3.new(34, 18, 28), CFrame.new(origin + Vector3.new(-28, 9, 5)), COLORS.paper, Enum.Material.WoodPlanks)
	part(model, "PostRoof", Vector3.new(40, 2, 32), CFrame.new(origin + Vector3.new(-28, 19, 5)) * CFrame.Angles(0, 0, math.rad(8)), COLORS.blue, Enum.Material.Slate)
	part(model, "PostDoor", Vector3.new(6, 10, 1), CFrame.new(origin + Vector3.new(-28, 5, -9.5)), COLORS.woodDark, Enum.Material.Wood)
	for row = 0, 2 do
		for column = 0, 3 do
			part(model, "PigeonHole", Vector3.new(5, 3, 1.5), CFrame.new(origin + Vector3.new(-36 + column * 5.5, 4 + row * 3.5, 18)), COLORS.wood, Enum.Material.Wood)
		end
	end
	for i = 1, 6 do
		part(model, "Parcel" .. i, Vector3.new(3 + (i % 2), 2.5, 3), CFrame.new(origin + Vector3.new(-44 + i * 5, 1.5, -18)), if i % 2 == 0 then COLORS.gold else COLORS.paper, Enum.Material.Cardboard)
	end

	-- Observatory dome and telescope make the destination readable without labels.
	cylinder(model, "ObservatoryBase", Vector3.new(12, 30, 30), CFrame.new(origin + Vector3.new(35, 6, 18)) * CFrame.Angles(0, 0, math.rad(90)), COLORS.blue, Enum.Material.Metal)
	ball(model, "ObservatoryDome", 23, CFrame.new(origin + Vector3.new(35, 17, 18)), COLORS.sky, Enum.Material.Glass)
	local telescope = cylinder(model, "TelescopeTube", Vector3.new(5, 18, 5), CFrame.new(origin + Vector3.new(35, 14, 6)) * CFrame.Angles(math.rad(18), 0, math.rad(90)), COLORS.ink, Enum.Material.Metal)
	telescope:SetAttribute("TinyWorldArtRole", "cloudpost-telescope")
	part(model, "TelescopeTripod", Vector3.new(2, 11, 2), CFrame.new(origin + Vector3.new(35, 6, 8)), COLORS.brass, Enum.Material.Metal)

	-- Wind route: broad cloud bridge and three sky bells provide physical traversal beats.
	for i = 0, 5 do
		part(model, "CloudBridge" .. i, Vector3.new(15, 1.2, 10), CFrame.new(origin + Vector3.new(-15 + i * 13, 3 + i * 0.8, -35)), COLORS.cloud, Enum.Material.SmoothPlastic)
	end
	for i = 1, 3 do
		part(model, "BellPost" .. i, Vector3.new(1, 8, 1), CFrame.new(origin + Vector3.new(2 + i * 17, 7, -31)), COLORS.brass, Enum.Material.Metal)
		local bell = cylinder(model, "SkyBell" .. i, Vector3.new(3, 4, 4), CFrame.new(origin + Vector3.new(2 + i * 17, 10, -31)) * CFrame.Angles(0, 0, math.rad(90)), COLORS.gold, Enum.Material.Metal)
		bell:SetAttribute("TinyWorldSecretMechanic", "sky-bell")
	end

	local collectPrompts = {
		makeCollectible(model, "BreezeBottle1", origin + Vector3.new(-48, 2, 30), COLORS.sky, "Bottled Breeze"),
		makeCollectible(model, "BreezeBottle2", origin + Vector3.new(18, 4, -34), COLORS.sky, "Bottled Breeze"),
		makeCollectible(model, "BreezeBottle3", origin + Vector3.new(48, 2, 34), COLORS.sky, "Bottled Breeze"),
	}
	local returnPrompt = portal(model, "CloudpostReturnPortal", origin + Vector3.new(0, 1, 52), "TinyWorld Village")
	return {
		model = model,
		arrivalCFrame = CFrame.new(origin + Vector3.new(0, 6, -48)),
		collectPrompts = collectPrompts,
		returnPrompt = returnPrompt,
	}
end

local function orchardTree(parent: Instance, position: Vector3, index: number)
	part(parent, "OrchardTrunk" .. index, Vector3.new(3, 12, 3), CFrame.new(position + Vector3.new(0, 6, 0)), COLORS.woodDark, Enum.Material.Wood)
	for j, offset in { Vector3.new(-4, 0, 0), Vector3.new(3, 2, 1), Vector3.new(0, 4, -2) } do
		ball(parent, "OrchardCanopy" .. index .. "_" .. j, 10, CFrame.new(position + Vector3.new(0, 12, 0) + offset), COLORS.leaf, Enum.Material.LeafyGrass)
	end
	for j = 1, 4 do
		ball(parent, "ClockFruit" .. index .. "_" .. j, 1.8, CFrame.new(position + Vector3.new(-4 + j * 2, 13 + (j % 2) * 2, 3)), COLORS.fruit, Enum.Material.SmoothPlastic)
	end
end

local function buildClockwork(parent: Instance, origin: Vector3)
	local model = Instance.new("Model")
	model.Name = "ClockworkOrchard"
	model:SetAttribute("TinyWorldArtRole", "portal-world-clockwork-orchard")
	model.Parent = parent
	part(model, "OrchardGround", Vector3.new(165, 2, 145), CFrame.new(origin), COLORS.leaf, Enum.Material.Grass)
	part(model, "OrchardPath", Vector3.new(18, 0.5, 130), CFrame.new(origin + Vector3.new(0, 1.2, 0)), COLORS.paper, Enum.Material.Cobblestone)
	for i, position in {
		Vector3.new(-45, 0, -38), Vector3.new(-45, 0, 0), Vector3.new(-45, 0, 38),
		Vector3.new(45, 0, -38), Vector3.new(45, 0, 0), Vector3.new(45, 0, 38),
	} do
		orchardTree(model, origin + position, i)
	end

	-- Clock tower, visible gears and moving-world language without anonymous geometry.
	part(model, "ClockTower", Vector3.new(22, 42, 22), CFrame.new(origin + Vector3.new(0, 21, 47)), COLORS.paper, Enum.Material.Brick)
	part(model, "ClockRoof", Vector3.new(26, 4, 26), CFrame.new(origin + Vector3.new(0, 44, 47)), COLORS.blue, Enum.Material.Slate)
	local clockFace = cylinder(model, "ClockFace", Vector3.new(1, 14, 14), CFrame.new(origin + Vector3.new(0, 31, 35.5)) * CFrame.Angles(0, 0, math.rad(90)), COLORS.paper, Enum.Material.SmoothPlastic)
	clockFace:SetAttribute("TinyWorldArtRole", "clock-face")
	part(model, "ClockHandLong", Vector3.new(0.4, 7, 0.4), CFrame.new(origin + Vector3.new(0, 33, 34.8)), COLORS.ink, Enum.Material.Metal, false)
	part(model, "ClockHandShort", Vector3.new(4, 0.4, 0.4), CFrame.new(origin + Vector3.new(2, 31, 34.7)), COLORS.ink, Enum.Material.Metal, false)

	for i = 1, 5 do
		local gear = cylinder(model, "GardenGear" .. i, Vector3.new(1.2, 8 + i * 2, 8 + i * 2), CFrame.new(origin + Vector3.new(-30 + i * 15, 6 + (i % 2) * 3, -18)) * CFrame.Angles(0, 0, math.rad(90)), if i % 2 == 0 then COLORS.gold else COLORS.brass, Enum.Material.Metal)
		gear:SetAttribute("TinyWorldSecretMechanic", "timing-gear")
	end
	part(model, "GearBridge", Vector3.new(75, 2, 9), CFrame.new(origin + Vector3.new(0, 8, -18)), COLORS.wood, Enum.Material.WoodPlanks)

	local collectPrompts = {
		makeCollectible(model, "ClockLeaf1", origin + Vector3.new(-52, 2, -42), COLORS.gold, "Clockwork Leaf"),
		makeCollectible(model, "ClockLeaf2", origin + Vector3.new(0, 10, -18), COLORS.gold, "Clockwork Leaf"),
		makeCollectible(model, "ClockLeaf3", origin + Vector3.new(52, 2, 42), COLORS.gold, "Clockwork Leaf"),
	}
	local returnPrompt = portal(model, "ClockworkReturnPortal", origin + Vector3.new(0, 1, -60), "TinyWorld Village")
	return {
		model = model,
		arrivalCFrame = CFrame.new(origin + Vector3.new(0, 6, 58)),
		collectPrompts = collectPrompts,
		returnPrompt = returnPrompt,
	}
end

function ImpossibleWorldBuilder.extend(world)
	local parent = world.root
	world.cloudpostObservatory = buildCloudpost(parent, Vector3.new(520, 0, 1000))
	world.clockworkOrchard = buildClockwork(parent, Vector3.new(790, 0, 1000))
	world.cloudpostPortalPrompt = portal(parent, "VillageCloudpostPortal", Vector3.new(44, 1, 44), "Cloudpost Observatory")
	world.clockworkPortalPrompt = portal(parent, "VillageClockworkPortal", Vector3.new(58, 1, 22), "Clockwork Orchard")
	return world
end

return ImpossibleWorldBuilder
