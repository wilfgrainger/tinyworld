local CollectionService = game:GetService("CollectionService")
local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))

local BikeBuilder = {}

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

local function component(name, shape, size, position, color, material, role, rotation)
	return {
		name = name,
		shape = shape,
		size = size,
		position = position,
		rotation = rotation or { 0, 0, 0 },
		color = color,
		material = material,
		role = role,
	}
end

function BikeBuilder.build(parent: Instance, name: string, origin: CFrame, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("BikeModel", true)
	model:SetAttribute("TinyWorldArtRole", "rideable-bike")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model:SetAttribute("TinyWorldMotionState", "parked")
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model.Parent = parent

	local palette = {
		colors = {
			accent = accent,
			ink = Color3.fromRGB(43, 48, 58),
			metal = Color3.fromRGB(123, 132, 143),
			leather = Color3.fromRGB(97, 63, 46),
			basket = Color3.fromRGB(219, 171, 93),
			flower = Color3.fromRGB(232, 100, 146),
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

	local rearWheel = add(component("BikeWheelBack", "cylinder", { 4.4, 0.72, 4.4 }, { 0, 2.2, -3 }, "ink", "metal", "bike-wheel", { 0, 0, 90 }))
	local frontWheel = add(component("BikeWheelFront", "cylinder", { 4.4, 0.72, 4.4 }, { 0, 2.2, 3 }, "ink", "metal", "bike-wheel", { 0, 0, 90 }))
	if rearWheel then
		rearWheel:SetAttribute("TinyWorldMotionRole", "wheel-spin")
	end
	if frontWheel then
		frontWheel:SetAttribute("TinyWorldMotionRole", "wheel-spin")
	end

	add(component("BikeFrameTop", "beveledBox", { 0.72, 0.72, 5.4 }, { 0, 3.1, 0 }, "accent", "metal", "bike-frame"))
	add(component("BikeFrameDown", "beveledBox", { 0.62, 0.62, 3.5 }, { 0, 2.7, -0.05 }, "accent", "metal", "bike-frame", { 16, 0, 0 }))
	add(component("BikeSeatPost", "beveledBox", { 0.42, 2.0, 0.42 }, { 0, 4.05, -1 }, "metal", "metal", "bike-seat-post"))
	add(component("BikeSeatVisual", "ellipsoid", { 2.4, 0.6, 1.35 }, { 0, 5.05, -1 }, "leather", "fabric", "bike-seat"))
	add(component("BikeHandlePost", "beveledBox", { 0.42, 2.4, 0.42 }, { 0, 4.15, 1.65 }, "metal", "metal", "bike-handle-post", { -12, 0, 0 }))
	add(component("BikeHandlebar", "cylinder", { 0.42, 3.4, 0.42 }, { 0, 5.15, 2.1 }, "accent", "metal", "bike-handlebar", { 0, 0, 90 }))
	add(component("BikeBasket", "beveledBox", { 2.5, 1.4, 1.9 }, { 0, 4.25, 2.9 }, "basket", "wood", "bike-basket"))
	local flag = add(component("BikeFlag", "beveledBox", { 1.8, 1.05, 0.24 }, { 0.8, 6.4, 2.75 }, "flower", "fabric", "bike-flag"))
	if flag then
		flag:SetAttribute("TinyWorldMotionRole", "flag-flutter")
	end

	local interactionAnchor = Instance.new("Seat")
	interactionAnchor.Name = "BikeInteractionAnchor"
	interactionAnchor.Size = Vector3.new(2.2, 0.45, 1.1)
	interactionAnchor.CFrame = origin * CFrame.new(0, 5.05, -1)
	interactionAnchor.Anchored = true
	interactionAnchor.CanCollide = false
	interactionAnchor.CanTouch = false
	interactionAnchor.CanQuery = true
	interactionAnchor.Transparency = 1
	interactionAnchor:SetAttribute("TinyWorldInteractionAnchor", true)
	interactionAnchor.Parent = model

	local mountPrompt = makePrompt(interactionAnchor, "MountPrompt", "Mount Bike", "Tiny Bike")
	local dismountPrompt = makePrompt(interactionAnchor, "DismountPrompt", "Dismount Bike", "Tiny Bike")
	dismountPrompt.Enabled = false

	model.PrimaryPart = interactionAnchor
	CollectionService:AddTag(model, "TinyWorldMotionModel")

	return {
		model = model,
		mountPart = interactionAnchor,
		mountPrompt = mountPrompt,
		dismountPrompt = dismountPrompt,
		parts = parts,
	}
end

return BikeBuilder
