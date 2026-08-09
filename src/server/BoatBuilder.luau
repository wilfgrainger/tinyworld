local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local BoatBuilder = {}

local function makePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

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

function BoatBuilder.build(parent: Instance, name: string, origin: CFrame, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	makePart(model, "BoatHull", Vector3.new(8, 1.2, 14), origin * CFrame.new(0, 0.9, 0), accent, Enum.Material.WoodPlanks)
	makePart(model, "BoatBow", Vector3.new(6, 1.2, 4), origin * CFrame.new(0, 1.3, -8), accent, Enum.Material.Wood)
	makePart(model, "BoatDeck", Vector3.new(6.6, 0.35, 9), origin * CFrame.new(0, 1.65, 0), VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
	local seat = Instance.new("Seat")
	seat.Name = "BoatSeat"
	seat.Size = Vector3.new(2.8, 0.45, 2.2)
	seat.CFrame = origin * CFrame.new(0, 2.25, 1.2)
	seat.Color = VisualTheme.Colors.timberDark
	seat.Material = Enum.Material.Wood
	seat.Anchored = true
	seat.CanCollide = false
	seat.CanTouch = false
	seat.CanQuery = true
	seat.TopSurface = Enum.SurfaceType.Smooth
	seat.BottomSurface = Enum.SurfaceType.Smooth
	seat.Parent = model

	makePart(model, "BoatOarLeft", Vector3.new(0.3, 0.3, 8), origin * CFrame.new(-4.5, 2.15, 0) * CFrame.Angles(0, math.rad(-18), 0), VisualTheme.Colors.timber, Enum.Material.Wood)
	makePart(model, "BoatOarRight", Vector3.new(0.3, 0.3, 8), origin * CFrame.new(4.5, 2.15, 0) * CFrame.Angles(0, math.rad(18), 0), VisualTheme.Colors.timber, Enum.Material.Wood)
	makePart(model, "BoatMast", Vector3.new(0.35, 6, 0.35), origin * CFrame.new(0, 4.5, -2.2), VisualTheme.Colors.timberDark, Enum.Material.Wood)
	makePart(model, "BoatSail", Vector3.new(0.25, 4.2, 4.2), origin * CFrame.new(0, 5, -1.4), VisualTheme.Colors.paper, Enum.Material.Fabric)
	makePart(model, "BoatFlag", Vector3.new(0.25, 1.4, 2.4), origin * CFrame.new(0.2, 7.5, -2.2), VisualTheme.Colors.gold, Enum.Material.Fabric)

	local mountPrompt = makePrompt(seat, "MountPrompt", "Board Tiny Boat", "Tiny Boat")
	local returnPrompt = makePrompt(seat, "ReturnPrompt", "Return to Sea Dock", "Tiny Boat")
	returnPrompt.Enabled = false

	model.PrimaryPart = seat
	model:SetAttribute("TinyBoat", true)
	model:SetAttribute("TinyWorldPhysicalBoat", true)
	model:SetAttribute("TinyWorldBoatOwner", name)

	return {
		model = model,
		mountPart = seat,
		mountPrompt = mountPrompt,
		returnPrompt = returnPrompt,
	}
end

return BoatBuilder
