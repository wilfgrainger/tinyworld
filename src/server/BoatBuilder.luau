local CollectionService = game:GetService("CollectionService")
local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))
local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local BoatBuilder = {}

local function makePrompt(parent: Instance, name: string, actionText: string, objectText: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function component(name, shape, size, position, color, material, role, rotation, extra)
	local spec = {
		name = name,
		shape = shape,
		size = size,
		position = position,
		rotation = rotation or { 0, 0, 0 },
		color = color,
		material = material,
		role = role,
	}
	if extra then
		for key, value in extra do
			spec[key] = value
		end
	end
	return spec
end

function BoatBuilder.build(parent: Instance, name: string, origin: CFrame, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyBoat", true)
	model:SetAttribute("TinyWorldArtRole", "sailing-boat")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldPhysicalBoat", true)
	model:SetAttribute("TinyWorldBoatOwner", name)
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model:SetAttribute("TinyWorldMotionState", "docked")
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model.Parent = parent

	local palette = {
		colors = {
			accent = accent,
			timber = VisualTheme.Colors.timber,
			timberDark = VisualTheme.Colors.timberDark,
			deck = VisualTheme.Colors.warmLight,
			paper = VisualTheme.Colors.paper,
			gold = VisualTheme.Colors.gold,
			water = VisualTheme.Colors.sky,
			ink = Color3.fromRGB(47, 55, 67),
		},
	}

	local parts = {}
	local function add(spec)
		local part = ProductionMeshFactory.createComponent(model, spec, origin, palette)
		if part then
			table.insert(parts, part)
		end
		return part
	end

	add(
		component(
			"BoatHull",
			"frustum",
			{ 8.2, 2.6, 14.2 },
			{ 0, 1.1, 0 },
			"accent",
			"wood",
			"boat-hull",
			{ 0, 0, 0 },
			{ topScale = 0.72 }
		)
	)
	add(
		component(
			"BoatKeel",
			"beveledBox",
			{ 1.1, 1.6, 13.4 },
			{ 0, 0.15, 0.5 },
			"timberDark",
			"wood",
			"boat-keel"
		)
	)
	add(
		component(
			"BoatDeck",
			"beveledBox",
			{ 6.5, 0.42, 9.2 },
			{ 0, 2.0, 0.5 },
			"deck",
			"wood",
			"boat-deck"
		)
	)
	add(
		component(
			"BoatBow",
			"frustum",
			{ 6.2, 2.1, 5.2 },
			{ 0, 1.45, -7.2 },
			"accent",
			"wood",
			"boat-bow",
			{ 0, 0, 0 },
			{ topScale = 0.35 }
		)
	)
	add(
		component(
			"BoatCabinConsole",
			"beveledBox",
			{ 3.8, 1.8, 2.4 },
			{ 0, 3.0, 2.6 },
			"timberDark",
			"wood",
			"boat-console"
		)
	)
	add(
		component(
			"BoatConsoleFace",
			"beveledBox",
			{ 3.15, 1.0, 0.35 },
			{ 0, 3.15, 1.35 },
			"ink",
			"metal",
			"boat-console-face"
		)
	)

	for _, x in { -3.2, 3.2 } do
		add(
			component(
				"BoatRail",
				"cylinder",
				{ 0.3, 8.5, 0.3 },
				{ x, 3.0, 0.4 },
				"timber",
				"wood",
				"boat-rail",
				{ 90, 0, 0 }
			)
		)
	end

	for _, x in { -4.25, 4.25 } do
		add(
			component(
				"BoatOar",
				"beveledBox",
				{ 0.36, 0.28, 8.4 },
				{ x, 2.5, 0 },
				"timber",
				"wood",
				"boat-oar",
				{ 0, if x < 0 then -18 else 18, 0 }
			)
		)
	end

	add(
		component(
			"BoatMast",
			"cylinder",
			{ 0.42, 7.0, 0.42 },
			{ 0, 5.0, -2.2 },
			"timberDark",
			"wood",
			"boat-mast"
		)
	)
	local sail = add(
		component(
			"BoatSail",
			"beveledBox",
			{ 0.24, 4.6, 4.8 },
			{ 0, 5.25, -1.25 },
			"paper",
			"fabric",
			"boat-sail"
		)
	)
	if sail then
		sail:SetAttribute("TinyWorldMotionRole", "sail-billow")
	end
	add(
		component(
			"BoatSailStripe",
			"beveledBox",
			{ 0.28, 0.85, 4.5 },
			{ 0, 5.25, -1.25 },
			"accent",
			"fabric",
			"boat-sail-stripe"
		)
	)
	local flag = add(
		component(
			"BoatFlag",
			"beveledBox",
			{ 0.24, 1.45, 2.5 },
			{ 0.2, 8.1, -2.2 },
			"gold",
			"fabric",
			"boat-flag"
		)
	)
	if flag then
		flag:SetAttribute("TinyWorldMotionRole", "flag-flutter")
	end

	local wake = add(
		component(
			"BoatWaterWake",
			"ellipsoid",
			{ 9.5, 0.24, 12.5 },
			{ 0, 0.05, 4.0 },
			"water",
			"water",
			"boat-water-wake",
			{ 0, 0, 0 },
			{ transparency = 1 }
		)
	)
	if wake then
		wake.Transparency = 1
		wake:SetAttribute("TinyWorldMotionRole", "water-wake")
	end

	local seat = Instance.new("Seat")
	seat.Name = "BoatSeat"
	seat.Size = Vector3.new(2.8, 0.45, 2.2)
	seat.CFrame = origin * CFrame.new(0, 2.55, 1.2)
	seat.Anchored = true
	seat.CanCollide = false
	seat.CanTouch = false
	seat.CanQuery = true
	seat.Transparency = 1
	seat:SetAttribute("TinyWorldArtRole", "boat-rider-seat-anchor")
	seat:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	seat:SetAttribute("TinyWorldInteractionAnchor", true)
	seat.Parent = model

	local mountPrompt = makePrompt(seat, "MountPrompt", "Board Tiny Boat", "Tiny Boat")
	local returnPrompt = makePrompt(seat, "ReturnPrompt", "Return to Sea Dock", "Tiny Boat")
	returnPrompt.Enabled = false

	model.PrimaryPart = seat
	CollectionService:AddTag(model, "TinyWorldMotionModel")

	return {
		model = model,
		mountPart = seat,
		mountPrompt = mountPrompt,
		returnPrompt = returnPrompt,
		parts = parts,
		wake = wake,
	}
end

return BoatBuilder
