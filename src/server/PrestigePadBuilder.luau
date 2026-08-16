local ProductionMeshFactory = require(script.Parent:WaitForChild("ProductionMeshFactory"))

local PrestigePadBuilder = {}

local PALETTE = {
	colors = {
		stone = Color3.fromRGB(89, 96, 112),
		metal = Color3.fromRGB(143, 153, 171),
		glow = Color3.fromRGB(109, 222, 235),
		gold = Color3.fromRGB(237, 190, 82),
		dark = Color3.fromRGB(40, 45, 55),
	},
}

local function component(name, shape, size, position, color, material, role, extra)
	local spec = {
		name = name,
		shape = shape,
		size = size,
		position = position,
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

function PrestigePadBuilder.build(world)
	local model = Instance.new("Model")
	model.Name = "FutureSpaceshipPad"
	model:SetAttribute("TinyWorldPrestige", "FutureSpaceshipPad")
	model:SetAttribute("TinyWorldVisualState", "authored-custom-mesh")
	model:SetAttribute("TinyWorldFutureFeature", true)
	model.Parent = world.root

	local z = math.max(96, world.layout.perimeterHalfExtent - 24)
	local origin = CFrame.new(0, 1.2, z)

	ProductionMeshFactory.createComponent(
		model,
		component("LandingDisc", "cylinder", { 24, 1.2, 24 }, { 0, 0, 0 }, "stone", "stone", "future-spaceship-pad", {
			segments = 24,
		}),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		component(
			"InnerBeacon",
			"cylinder",
			{ 14, 0.35, 14 },
			{ 0, 0.8, 0 },
			"glow",
			"neon",
			"future-spaceship-beacon",
			{
				segments = 24,
				transparency = 0.18,
			}
		),
		origin,
		PALETTE
	)
	ProductionMeshFactory.createComponent(
		model,
		component(
			"PrestigeArch",
			"archSegment",
			{ 14, 12, 2.2 },
			{ 0, 5.4, 6.5 },
			"metal",
			"metal",
			"future-spaceship-arch",
			{
				segments = 18,
				thickness = 1.4,
			}
		),
		origin,
		PALETTE
	)
	for _, x in { -8, 8 } do
		ProductionMeshFactory.createComponent(
			model,
			component(
				"BeaconPillar",
				"frustum",
				{ 2.1, 6, 2.1 },
				{ x, 3, 2 },
				"dark",
				"metal",
				"future-spaceship-pillar",
				{
					topScale = 0.6,
				}
			),
			origin,
			PALETTE
		)
		ProductionMeshFactory.createComponent(
			model,
			component(
				"BeaconCap",
				"ellipsoid",
				{ 2.4, 2.4, 2.4 },
				{ x, 6.5, 2 },
				"gold",
				"neon",
				"future-spaceship-cap"
			),
			origin,
			PALETTE
		)
	end

	return model
end

return PrestigePadBuilder
