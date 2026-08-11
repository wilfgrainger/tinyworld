local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))

local ArchitecturalDetailBuilder = {}

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Anchored = true
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("TinyWorldArtRole", role)
	item:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	item.Parent = parent
	return item
end

local function decorative(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	role: string
): Part
	local item = part(parent, name, size, cframe, color, material, role)
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	return item
end

function ArchitecturalDetailBuilder.addPitchedRoof(parent: Instance, spec)
	local model = Instance.new("Model")
	model.Name = spec.name or "PitchedRoof"
	model:SetAttribute("TinyWorldArtRole", spec.role or "architectural-pitched-roof")
	model:SetAttribute("TinyWorldVisualState", "authored-native")
	model.Parent = parent

	local width = spec.width
	local depth = spec.depth
	local rise = spec.rise or math.max(3, width * 0.18)
	local eave = spec.eave or 1.25
	local thickness = spec.thickness or 0.7
	local center = spec.center
	local color = spec.color or VisualTheme.Colors.roof
	local material = spec.material or Enum.Material.Slate
	local halfRun = (width / 2) + eave
	local slopeLength = math.sqrt((halfRun * halfRun) + (rise * rise))
	local angle = math.atan2(rise, halfRun)
	local verticalCenter = rise / 2
	local horizontalCenter = halfRun / 2
	local role = spec.role or "architectural-roof"

	decorative(
		model,
		"RoofLeft",
		Vector3.new(slopeLength, thickness, depth + (eave * 2)),
		CFrame.new(center + Vector3.new(-horizontalCenter, verticalCenter, 0)) * CFrame.Angles(0, 0, -angle),
		color,
		material,
		role .. "-plane"
	)
	decorative(
		model,
		"RoofRight",
		Vector3.new(slopeLength, thickness, depth + (eave * 2)),
		CFrame.new(center + Vector3.new(horizontalCenter, verticalCenter, 0)) * CFrame.Angles(0, 0, angle),
		color,
		material,
		role .. "-plane"
	)
	decorative(
		model,
		"RoofRidge",
		Vector3.new(0.8, 0.65, depth + (eave * 2) + 0.4),
		CFrame.new(center + Vector3.new(0, rise + 0.2, 0)),
		spec.ridgeColor or VisualTheme.Colors.roofLight,
		material,
		role .. "-ridge"
	)

	if spec.gableTrimColor then
		for _, z in { -(depth / 2 + eave + 0.08), depth / 2 + eave + 0.08 } do
			decorative(
				model,
				if z < 0 then "GableTrimBack" else "GableTrimFront",
				Vector3.new(width + (eave * 2), 0.35, 0.35),
				CFrame.new(center + Vector3.new(0, rise * 0.18, z)),
				spec.gableTrimColor,
				Enum.Material.Wood,
				role .. "-gable-trim"
			)
		end
	end

	return model
end

function ArchitecturalDetailBuilder.addWindow(parent: Instance, spec)
	local model = Instance.new("Model")
	model.Name = spec.name or "FramedWindow"
	model:SetAttribute("TinyWorldArtRole", spec.role or "architectural-window")
	model:SetAttribute("TinyWorldVisualState", "authored-native")
	model.Parent = parent

	local width = spec.width or 4
	local height = spec.height or 3.5
	local depth = spec.depth or 0.32
	local frame = spec.frame or 0.42
	local base = spec.cframe
	local frameColor = spec.frameColor or VisualTheme.Colors.timberDark
	local glassColor = spec.glassColor or VisualTheme.Colors.inkGlass
	local role = spec.role or "architectural-window"

	local glass = decorative(
		model,
		"Glass",
		Vector3.new(math.max(0.5, width - (frame * 2)), math.max(0.5, height - (frame * 2)), depth),
		base * CFrame.new(0, 0, -0.02),
		glassColor,
		Enum.Material.Glass,
		role .. "-glass"
	)
	glass.Transparency = spec.transparency or 0.32
	glass.Reflectance = 0.04

	local framePieces = {
		Top = {
			offset = Vector3.new(0, (height / 2) - (frame / 2), 0.08),
			size = Vector3.new(width, frame, depth + 0.12),
		},
		Bottom = {
			offset = Vector3.new(0, -(height / 2) + (frame / 2), 0.08),
			size = Vector3.new(width, frame, depth + 0.12),
		},
		Left = {
			offset = Vector3.new(-(width / 2) + (frame / 2), 0, 0.08),
			size = Vector3.new(frame, height, depth + 0.12),
		},
		Right = {
			offset = Vector3.new((width / 2) - (frame / 2), 0, 0.08),
			size = Vector3.new(frame, height, depth + 0.12),
		},
	}
	for name, values in framePieces do
		decorative(
			model,
			"Frame" .. name,
			values.size,
			base * CFrame.new(values.offset),
			frameColor,
			Enum.Material.Wood,
			role .. "-frame"
		)
	end

	decorative(
		model,
		"MullionVertical",
		Vector3.new(frame * 0.6, height - (frame * 2), depth + 0.14),
		base * CFrame.new(0, 0, 0.09),
		frameColor,
		Enum.Material.Wood,
		role .. "-mullion"
	)
	decorative(
		model,
		"MullionHorizontal",
		Vector3.new(width - (frame * 2), frame * 0.6, depth + 0.14),
		base * CFrame.new(0, 0, 0.09),
		frameColor,
		Enum.Material.Wood,
		role .. "-mullion"
	)
	decorative(
		model,
		"Sill",
		Vector3.new(width + 0.7, 0.35, 0.85),
		base * CFrame.new(0, -(height / 2) - 0.15, 0.28),
		spec.sillColor or VisualTheme.Colors.woodLight,
		Enum.Material.Wood,
		role .. "-sill"
	)

	if spec.warmLight then
		local light = Instance.new("PointLight")
		light.Name = "WindowWarmLight"
		light.Brightness = 0.35
		light.Range = 8
		light.Color = VisualTheme.Colors.warmLight
		light.Shadows = false
		light.Parent = glass
	end

	return model
end

function ArchitecturalDetailBuilder.addDoor(parent: Instance, spec)
	local model = Instance.new("Model")
	model.Name = spec.name or "EntryDoor"
	model:SetAttribute("TinyWorldArtRole", spec.role or "architectural-door")
	model.Parent = parent
	local width = spec.width or 4
	local height = spec.height or 6.5
	local base = spec.cframe
	local role = spec.role or "architectural-door"
	local frameColor = spec.frameColor or VisualTheme.Colors.woodLight
	local door = decorative(
		model,
		"Door",
		Vector3.new(width, height, 0.45),
		base,
		spec.color or VisualTheme.Colors.timberDark,
		Enum.Material.Wood,
		role .. "-leaf"
	)
	decorative(
		model,
		"Header",
		Vector3.new(width + 1, 0.45, 0.65),
		base * CFrame.new(0, height / 2 + 0.18, 0),
		frameColor,
		Enum.Material.Wood,
		role .. "-frame"
	)
	for _, side in { -1, 1 } do
		decorative(
			model,
			if side < 0 then "FrameLeft" else "FrameRight",
			Vector3.new(0.45, height + 0.5, 0.65),
			base * CFrame.new(side * (width / 2 + 0.22), 0, 0),
			frameColor,
			Enum.Material.Wood,
			role .. "-frame"
		)
	end
	local handle = decorative(
		model,
		"Handle",
		Vector3.new(0.32, 0.55, 0.32),
		base * CFrame.new(width * 0.28, 0, 0.38),
		VisualTheme.Colors.gold,
		Enum.Material.Metal,
		role .. "-handle"
	)
	handle.Shape = Enum.PartType.Cylinder
	return model, door
end

function ArchitecturalDetailBuilder.addPorch(parent: Instance, spec)
	local model = Instance.new("Model")
	model.Name = spec.name or "Porch"
	model:SetAttribute("TinyWorldArtRole", spec.role or "architectural-porch")
	model.Parent = parent
	local base = spec.cframe
	local width = spec.width or 10
	local depth = spec.depth or 5
	local role = spec.role or "architectural-porch"
	part(
		model,
		"Deck",
		Vector3.new(width, 0.55, depth),
		base,
		spec.deckColor or VisualTheme.Colors.timber,
		Enum.Material.WoodPlanks,
		role .. "-deck"
	)
	part(
		model,
		"Step",
		Vector3.new(width * 0.78, 0.45, 1.6),
		base * CFrame.new(0, -0.45, depth / 2 + 0.8),
		VisualTheme.Colors.pathEdge,
		Enum.Material.Cobblestone,
		role .. "-step"
	)
	for _, side in { -1, 1 } do
		decorative(
			model,
			if side < 0 then "PostLeft" else "PostRight",
			Vector3.new(0.55, 5.5, 0.55),
			base * CFrame.new(side * (width * 0.38), 2.7, depth * 0.24),
			VisualTheme.Colors.woodLight,
			Enum.Material.Wood,
			role .. "-post"
		)
	end
	decorative(
		model,
		"Canopy",
		Vector3.new(width + 1.4, 0.55, depth * 0.72),
		base * CFrame.new(0, 5.25, depth * 0.12) * CFrame.Angles(0, 0, math.rad(-4)),
		spec.canopyColor or VisualTheme.Colors.roof,
		Enum.Material.Slate,
		role .. "-canopy"
	)
	return model
end

function ArchitecturalDetailBuilder.addChimney(parent: Instance, spec)
	local model = Instance.new("Model")
	model.Name = spec.name or "Chimney"
	model:SetAttribute("TinyWorldArtRole", spec.role or "architectural-chimney")
	model.Parent = parent
	local base = spec.cframe
	local height = spec.height or 5
	local role = spec.role or "architectural-chimney"
	part(
		model,
		"Stack",
		Vector3.new(2.2, height, 2.2),
		base,
		spec.color or VisualTheme.Colors.path,
		Enum.Material.Brick,
		role .. "-stack"
	)
	decorative(
		model,
		"Cap",
		Vector3.new(2.8, 0.45, 2.8),
		base * CFrame.new(0, height / 2 + 0.2, 0),
		VisualTheme.Colors.inkSoft,
		Enum.Material.Slate,
		role .. "-cap"
	)
	return model
end

function ArchitecturalDetailBuilder.addLantern(parent: Instance, spec)
	local model = Instance.new("Model")
	model.Name = spec.name or "Lantern"
	model:SetAttribute("TinyWorldArtRole", spec.role or "architectural-lantern")
	model:SetAttribute("TinyWorldVisualState", "authored-native")
	model.Parent = parent
	local base = spec.cframe
	local role = spec.role or "architectural-lantern"
	local metal = spec.metalColor or VisualTheme.Colors.inkSoft

	if spec.postHeight then
		decorative(
			model,
			"Post",
			Vector3.new(0.48, spec.postHeight, 0.48),
			base * CFrame.new(0, -(spec.postHeight / 2) - 0.65, 0),
			metal,
			Enum.Material.Metal,
			role .. "-post"
		)
	else
		decorative(
			model,
			"WallBracket",
			Vector3.new(1.4, 0.28, 0.28),
			base * CFrame.new(0, 0.7, -0.65),
			metal,
			Enum.Material.Metal,
			role .. "-bracket"
		)
	end
	decorative(
		model,
		"Cap",
		Vector3.new(1.5, 0.25, 1.5),
		base * CFrame.new(0, 0.75, 0),
		metal,
		Enum.Material.Metal,
		role .. "-cap"
	)
	decorative(
		model,
		"Base",
		Vector3.new(1.35, 0.25, 1.35),
		base * CFrame.new(0, -0.75, 0),
		metal,
		Enum.Material.Metal,
		role .. "-base"
	)
	for _, x in { -0.58, 0.58 } do
		for _, z in { -0.58, 0.58 } do
			decorative(
				model,
				"Frame" .. tostring(x) .. tostring(z),
				Vector3.new(0.12, 1.35, 0.12),
				base * CFrame.new(x, 0, z),
				metal,
				Enum.Material.Metal,
				role .. "-frame"
			)
		end
	end
	local glass = decorative(
		model,
		"WarmGlass",
		Vector3.new(1.05, 1.25, 1.05),
		base,
		VisualTheme.Colors.warmLight,
		Enum.Material.Glass,
		role .. "-glass"
	)
	glass.Transparency = 0.18
	local core = decorative(
		model,
		"LightCore",
		Vector3.new(0.45, 0.75, 0.45),
		base,
		VisualTheme.Colors.warmLight,
		Enum.Material.Neon,
		role .. "-emissive-core"
	)
	local light = Instance.new("PointLight")
	light.Name = "PracticalLight"
	light.Brightness = spec.brightness or 0.65
	light.Range = spec.range or 11
	light.Color = spec.lightColor or VisualTheme.Colors.warmLight
	light.Shadows = false
	light.Parent = core
	return model, light
end

return ArchitecturalDetailBuilder
