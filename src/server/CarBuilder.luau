local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))

local CarBuilder = {}

local PALETTE = {
	colors = {
		body = Color3.fromRGB(237, 94, 90),
		trim = Color3.fromRGB(42, 48, 58),
		glass = Color3.fromRGB(132, 196, 214),
		wheel = Color3.fromRGB(35, 35, 40),
		light = Color3.fromRGB(255, 230, 154),
	},
}

local function spec(name, shape, size, position, color, material, role, rotation)
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

function CarBuilder.build(parent: Instance, name: string, origin: CFrame)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldVehicle", "TinyCar")
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model.Parent = parent

	local chassis = ProductionMeshFactory.createComponent(
		model,
		spec("Chassis", "beveledBox", { 6.8, 2.0, 10.5 }, { 0, 2.0, 0 }, "body", "paint", "tiny-car-chassis"),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		spec("Cabin", "beveledBox", { 5.4, 2.6, 5.0 }, { 0, 3.8, -0.6 }, "glass", "glass", "tiny-car-cabin"),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		spec("FrontTrim", "beveledBox", { 5.6, 0.65, 0.6 }, { 0, 2.0, -5.0 }, "trim", "metal", "tiny-car-trim"),
		origin,
		PALETTE
	)
	for _, x in { -3.0, 3.0 } do
		for _, z in { -3.4, 3.4 } do
			ProductionMeshFactory.createComponent(
				model,
				spec("Wheel", "cylinder", { 1.6, 0.9, 1.6 }, { x, 1.0, z }, "wheel", "metal", "tiny-car-wheel", { 0, 0, 90 }),
				origin,
				PALETTE
			)
		end
	end

	if chassis then
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "DrivePrompt"
		prompt.ActionText = "Drive"
		prompt.ObjectText = "Tiny Car"
		prompt.MaxActivationDistance = 11
		prompt.RequiresLineOfSight = false
		prompt.Parent = chassis
		return { model = model, prompt = prompt, anchor = chassis }
	end
	return { model = model, prompt = nil, anchor = nil }
end

return CarBuilder
