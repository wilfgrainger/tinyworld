local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local BikeBuilder = {}

local function makePart(parent: Instance, className: string, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material): BasePart
	local part = Instance.new(className)
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
	part:SetAttribute("TinyWorldArtRole", "bike-part-" .. string.lower(name))
	part:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
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

local function makeWheel(parent: Instance, name: string, position: Vector3, color: Color3): BasePart
	local wheel = makePart(
		parent,
		"Part",
		name,
		Vector3.new(0.7, 4.4, 4.4),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		Enum.Material.Metal
	)
	wheel.Shape = Enum.PartType.Cylinder
	wheel:SetAttribute("TinyWorldMotionRole", "wheel-spin")
	return wheel
end

function BikeBuilder.build(parent: Instance, name: string, origin: CFrame, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local frameOrigin = origin * CFrame.new(0, 0, 0)
	local rearWheel = makeWheel(model, "BikeWheelBack", (frameOrigin * CFrame.new(0, 2.2, -3)).Position, VisualTheme.Colors.inkSoft)
	local frontWheel = makeWheel(model, "BikeWheelFront", (frameOrigin * CFrame.new(0, 2.2, 3)).Position, VisualTheme.Colors.inkSoft)
	local frame = makePart(model, "Part", "BikeFrameTopTube", Vector3.new(0.7, 0.7, 5.4), frameOrigin * CFrame.new(0, 3.1, 0), accent, Enum.Material.Metal)
	local lowerFrame = makePart(model, "Part", "BikeFrameDownTube", Vector3.new(0.55, 0.55, 3.2), frameOrigin * CFrame.new(0, 2.65, -0.1) * CFrame.Angles(math.rad(16), 0, 0), accent, Enum.Material.Metal)
	local rearStayLeft = makePart(model, "Part", "BikeRearStayLeft", Vector3.new(0.3, 0.3, 3.6), frameOrigin * CFrame.new(-0.45, 3.25, -1.7) * CFrame.Angles(math.rad(-24), 0, 0), accent, Enum.Material.Metal)
	local rearStayRight = makePart(model, "Part", "BikeRearStayRight", Vector3.new(0.3, 0.3, 3.6), frameOrigin * CFrame.new(0.45, 3.25, -1.7) * CFrame.Angles(math.rad(-24), 0, 0), accent, Enum.Material.Metal)
	local seatPost = makePart(model, "Part", "BikeSeatPost", Vector3.new(0.35, 2, 0.35), frameOrigin * CFrame.new(0, 4.1, -1), VisualTheme.Colors.metal, Enum.Material.Metal)
	local seat = Instance.new("Seat")
	seat.Name = "BikeSeat"
	seat.Size = Vector3.new(2.2, 0.45, 1.1)
	seat.CFrame = frameOrigin * CFrame.new(0, 5.05, -1)
	seat.Color = VisualTheme.Colors.timberDark
	seat.Material = Enum.Material.SmoothPlastic
	seat.Anchored = true
	seat.CanCollide = false
	seat.CanTouch = false
	seat.CanQuery = true
	seat.TopSurface = Enum.SurfaceType.Smooth
	seat.BottomSurface = Enum.SurfaceType.Smooth
	seat:SetAttribute("TinyWorldArtRole", "bike-rider-seat")
	seat:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	seat:SetAttribute("TinyWorldInteractionAnchor", true)
	seat.Parent = model
	local handlePost = makePart(model, "Part", "BikeHandlePost", Vector3.new(0.35, 2.4, 0.35), frameOrigin * CFrame.new(0, 4.15, 1.6) * CFrame.Angles(math.rad(-12), 0, 0), VisualTheme.Colors.metal, Enum.Material.Metal)
	local handlebars = makePart(model, "Part", "BikeHandlebars", Vector3.new(3.2, 0.35, 0.35), frameOrigin * CFrame.new(0, 5.15, 2.1), accent, Enum.Material.Metal)
	local pedalBar = makePart(model, "Part", "BikePedals", Vector3.new(2.2, 0.3, 0.3), frameOrigin * CFrame.new(0, 2.8, -0.1), VisualTheme.Colors.metal, Enum.Material.Metal)
	local frontBasket = makePart(model, "Part", "BikeBasket", Vector3.new(2.4, 1.3, 1.8), frameOrigin * CFrame.new(0, 4.25, 2.8), VisualTheme.Colors.warmLight, Enum.Material.WoodPlanks)
	frontBasket.Transparency = 0.08
	local flag = makePart(model, "Part", "BikeFlag", Vector3.new(0.2, 2.8, 0.2), frameOrigin * CFrame.new(0, 5.4, 2.75), VisualTheme.Colors.gold, Enum.Material.Wood)
	local flagTop = makePart(model, "Part", "BikeFlagTop", Vector3.new(1.8, 1.1, 0.2), frameOrigin * CFrame.new(0.8, 6.55, 2.75), VisualTheme.Colors.flower, Enum.Material.Fabric)
	flagTop:SetAttribute("TinyWorldMotionRole", "flag-flutter")

	local mountPrompt = makePrompt(seat, "MountPrompt", "Mount Bike", "Tiny Bike")
	local dismountPrompt = makePrompt(seat, "DismountPrompt", "Dismount Bike", "Tiny Bike")
	dismountPrompt.Enabled = false

	model.PrimaryPart = seat
	model:PivotTo(origin)
	model:SetAttribute("BikeModel", true)
	model:SetAttribute("TinyWorldArtRole", "rideable-bike")
	model:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	model:SetAttribute("TinyWorldRecognizableSilhouette", true)
	model:SetAttribute("TinyWorldMotionState", "parked")

	return {
		model = model,
		mountPart = seat,
		mountPrompt = mountPrompt,
		dismountPrompt = dismountPrompt,
		parts = { rearWheel, frontWheel, frame, lowerFrame, rearStayLeft, rearStayRight, seatPost, handlePost, handlebars, pedalBar, frontBasket, flag, flagTop },
	}
end

return BikeBuilder
