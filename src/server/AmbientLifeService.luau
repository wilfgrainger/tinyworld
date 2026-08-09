local AmbientLifeService = {}
AmbientLifeService.__index = AmbientLifeService

local function part(model: Model, name: string, size: Vector3, cframe: CFrame, color: Color3, shape: Enum.PartType?): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = cframe
	value.Color = color
	value.Material = Enum.Material.SmoothPlastic
	value.Anchored = true
	value.CanCollide = false
	value.CanTouch = false
	value.CanQuery = false
	value.TopSurface = Enum.SurfaceType.Smooth
	value.BottomSurface = Enum.SurfaceType.Smooth
	if shape then value.Shape = shape end
	value:SetAttribute("TinyWorldArtRole", "ambient-life-detail")
	value.Parent = model
	return value
end

local function bird(parent: Instance, name: string, position: Vector3, color: Color3): Model
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "ambient-bird")
	model:SetAttribute("TinyWorldPhysicalAffordance", "ambient-life")
	model.Parent = parent
	local body = part(model, "Body", Vector3.new(1.8, 1.2, 1.2), CFrame.new(), color, Enum.PartType.Ball)
	part(model, "Head", Vector3.new(0.9, 0.9, 0.9), CFrame.new(0.8, 0.35, 0), color, Enum.PartType.Ball)
	part(model, "Beak", Vector3.new(0.5, 0.3, 0.3), CFrame.new(1.45, 0.3, 0), Color3.fromRGB(231, 171, 67))
	part(model, "WingLeft", Vector3.new(1.1, 0.2, 0.8), CFrame.new(0, 0.1, -0.75), Color3.fromRGB(236, 226, 203))
	part(model, "WingRight", Vector3.new(1.1, 0.2, 0.8), CFrame.new(0, 0.1, 0.75), Color3.fromRGB(236, 226, 203))
	model.PrimaryPart = body
	model:PivotTo(CFrame.new(position))
	return model
end

local function cat(parent: Instance, name: string, position: Vector3, color: Color3): Model
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("TinyWorldArtRole", "ambient-cat")
	model:SetAttribute("TinyWorldPhysicalAffordance", "ambient-life")
	model.Parent = parent
	local body = part(model, "Body", Vector3.new(2.6, 1.5, 1.3), CFrame.new(), color, Enum.PartType.Ball)
	part(model, "Head", Vector3.new(1.5, 1.5, 1.5), CFrame.new(1.5, 0.4, 0), color, Enum.PartType.Ball)
	part(model, "EarLeft", Vector3.new(0.45, 0.7, 0.35), CFrame.new(1.55, 1.35, -0.45), color)
	part(model, "EarRight", Vector3.new(0.45, 0.7, 0.35), CFrame.new(1.55, 1.35, 0.45), color)
	part(model, "Tail", Vector3.new(1.8, 0.35, 0.35), CFrame.new(-1.8, 0.4, 0) * CFrame.Angles(0, 0, math.rad(25)), color)
	for _, z in { -0.45, 0.45 } do
		part(model, "Leg", Vector3.new(0.35, 1, 0.35), CFrame.new(0.6, -0.8, z), color)
		part(model, "Leg", Vector3.new(0.35, 1, 0.35), CFrame.new(-0.7, -0.8, z), color)
	end
	model.PrimaryPart = body
	model:PivotTo(CFrame.new(position))
	return model
end

function AmbientLifeService.new(world)
	local self = setmetatable({}, AmbientLifeService)
	self.running = true
	self.actors = {}
	local folder = Instance.new("Folder")
	folder.Name = "TinyWorldAmbientCharacters"
	folder.Parent = world.root
	local birdColor = Color3.fromRGB(89, 123, 156)
	for index, position in {
		Vector3.new(-32, 3, -18), Vector3.new(-8, 3, 30), Vector3.new(24, 3, 16), Vector3.new(38, 3, -28),
	} do
		table.insert(self.actors, { model = bird(folder, "VillageBird" .. index, position, birdColor), origin = position, radius = 5 + index, speed = 0.35 + index * 0.04, flying = true })
	end
	for index, position in { Vector3.new(-20, 1.2, 10), Vector3.new(28, 1.2, -5) } do
		table.insert(self.actors, { model = cat(folder, "VillageCat" .. index, position, if index == 1 then Color3.fromRGB(188, 133, 77) else Color3.fromRGB(93, 96, 104)), origin = position, radius = 4, speed = 0.18 + index * 0.03, flying = false })
	end

	task.spawn(function()
		while self.running do
			local t = os.clock()
			for index, actor in self.actors do
				if actor.model.Parent then
					local angle = t * actor.speed + index
					local y = if actor.flying then actor.origin.Y + math.sin(angle * 1.8) * 1.2 else actor.origin.Y
					local position = actor.origin + Vector3.new(math.cos(angle) * actor.radius, y - actor.origin.Y, math.sin(angle) * actor.radius)
					local forward = Vector3.new(-math.sin(angle), 0, math.cos(angle))
					actor.model:PivotTo(CFrame.lookAt(position, position + forward))
				end
			end
			task.wait(0.2)
		end
	end)
	return self
end

function AmbientLifeService:stop()
	self.running = false
end

return AmbientLifeService
