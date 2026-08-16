local AssetService = game:GetService("AssetService")

local ProductionMeshFactory = {}

local DEFAULT_SEGMENTS = 10
local DEFAULT_RINGS = 5

local MATERIALS = {
	plaster = Enum.Material.SmoothPlastic,
	stone = Enum.Material.Cobblestone,
	marble = Enum.Material.Marble,
	slate = Enum.Material.Slate,
	wood = Enum.Material.Wood,
	woodPlanks = Enum.Material.WoodPlanks,
	brick = Enum.Material.Brick,
	metal = Enum.Material.Metal,
	glass = Enum.Material.Glass,
	fabric = Enum.Material.Fabric,
	foliage = Enum.Material.LeafyGrass,
	ground = Enum.Material.Ground,
	water = Enum.Material.Glass,
	paint = Enum.Material.SmoothPlastic,
}

local function signPow(value: number, exponent: number): number
	if value == 0 then
		return 0
	end
	return math.sign(value) * (math.abs(value) ^ exponent)
end

local function addTriangle(mesh: EditableMesh, a: number, b: number, c: number)
	mesh:AddTriangle(a, b, c)
end

local function addQuad(mesh: EditableMesh, a: number, b: number, c: number, d: number)
	addTriangle(mesh, a, b, c)
	addTriangle(mesh, a, c, d)
end

local function addCuboidGeometry(mesh: EditableMesh, size: Vector3, offset: Vector3?)
	local center = offset or Vector3.zero
	local hx = size.X / 2
	local hy = size.Y / 2
	local hz = size.Z / 2
	local points = {
		Vector3.new(-hx, -hy, -hz),
		Vector3.new(hx, -hy, -hz),
		Vector3.new(hx, hy, -hz),
		Vector3.new(-hx, hy, -hz),
		Vector3.new(-hx, -hy, hz),
		Vector3.new(hx, -hy, hz),
		Vector3.new(hx, hy, hz),
		Vector3.new(-hx, hy, hz),
	}
	local ids = {}
	for index, point in points do
		ids[index] = mesh:AddVertex(point + center)
	end
	addQuad(mesh, ids[1], ids[4], ids[3], ids[2])
	addQuad(mesh, ids[5], ids[6], ids[7], ids[8])
	addQuad(mesh, ids[1], ids[5], ids[8], ids[4])
	addQuad(mesh, ids[2], ids[3], ids[7], ids[6])
	addQuad(mesh, ids[4], ids[8], ids[7], ids[3])
	addQuad(mesh, ids[1], ids[2], ids[6], ids[5])
end

local function addSuperellipsoid(mesh: EditableMesh, size: Vector3, exponent: number, segments: number, rings: number)
	local hx = size.X / 2
	local hy = size.Y / 2
	local hz = size.Z / 2
	local rows = {}
	for ring = 0, rings do
		local eta = -math.pi / 2 + (math.pi * ring / rings)
		local row = {}
		for segment = 0, segments - 1 do
			local omega = 2 * math.pi * segment / segments
			local cosEta = math.cos(eta)
			local x = hx * signPow(cosEta, exponent) * signPow(math.cos(omega), exponent)
			local y = hy * signPow(math.sin(eta), exponent)
			local z = hz * signPow(cosEta, exponent) * signPow(math.sin(omega), exponent)
			row[segment + 1] = mesh:AddVertex(Vector3.new(x, y, z))
		end
		rows[ring + 1] = row
	end
	for ring = 1, rings do
		local current = rows[ring]
		local nextRow = rows[ring + 1]
		for segment = 1, segments do
			local nextSegment = (segment % segments) + 1
			addQuad(mesh, current[segment], current[nextSegment], nextRow[nextSegment], nextRow[segment])
		end
	end
end

local function addFrustum(mesh: EditableMesh, size: Vector3, segments: number, topScale: number)
	local bottomRadiusX = size.X / 2
	local bottomRadiusZ = size.Z / 2
	local topRadiusX = bottomRadiusX * topScale
	local topRadiusZ = bottomRadiusZ * topScale
	local bottomY = -size.Y / 2
	local topY = size.Y / 2
	local bottom = {}
	local top = {}
	for segment = 0, segments - 1 do
		local angle = 2 * math.pi * segment / segments
		local cosAngle = math.cos(angle)
		local sinAngle = math.sin(angle)
		bottom[segment + 1] = mesh:AddVertex(Vector3.new(bottomRadiusX * cosAngle, bottomY, bottomRadiusZ * sinAngle))
		top[segment + 1] = mesh:AddVertex(Vector3.new(topRadiusX * cosAngle, topY, topRadiusZ * sinAngle))
	end
	local bottomCenter = mesh:AddVertex(Vector3.new(0, bottomY, 0))
	local topCenter = mesh:AddVertex(Vector3.new(0, topY, 0))
	for segment = 1, segments do
		local nextSegment = (segment % segments) + 1
		addQuad(mesh, bottom[segment], bottom[nextSegment], top[nextSegment], top[segment])
		addTriangle(mesh, bottomCenter, bottom[nextSegment], bottom[segment])
		addTriangle(mesh, topCenter, top[segment], top[nextSegment])
	end
end

local function addGableRoof(mesh: EditableMesh, size: Vector3)
	local hx = size.X / 2
	local hy = size.Y / 2
	local hz = size.Z / 2
	local front = {
		mesh:AddVertex(Vector3.new(-hx, -hy, hz)),
		mesh:AddVertex(Vector3.new(hx, -hy, hz)),
		mesh:AddVertex(Vector3.new(0, hy, hz)),
	}
	local back = {
		mesh:AddVertex(Vector3.new(-hx, -hy, -hz)),
		mesh:AddVertex(Vector3.new(hx, -hy, -hz)),
		mesh:AddVertex(Vector3.new(0, hy, -hz)),
	}
	addTriangle(mesh, front[1], front[2], front[3])
	addTriangle(mesh, back[3], back[2], back[1])
	addQuad(mesh, front[1], front[3], back[3], back[1])
	addQuad(mesh, front[3], front[2], back[2], back[3])
	addQuad(mesh, front[2], front[1], back[1], back[2])
end

local function addHipRoof(mesh: EditableMesh, size: Vector3)
	local hx = size.X / 2
	local hy = size.Y / 2
	local hz = size.Z / 2
	local base = {
		mesh:AddVertex(Vector3.new(-hx, -hy, -hz)),
		mesh:AddVertex(Vector3.new(hx, -hy, -hz)),
		mesh:AddVertex(Vector3.new(hx, -hy, hz)),
		mesh:AddVertex(Vector3.new(-hx, -hy, hz)),
	}
	local ridgeLength = math.min(size.Z * 0.28, size.X * 0.3)
	local ridgeBack = mesh:AddVertex(Vector3.new(0, hy, -ridgeLength / 2))
	local ridgeFront = mesh:AddVertex(Vector3.new(0, hy, ridgeLength / 2))
	addQuad(mesh, base[1], base[4], base[3], base[2])
	addTriangle(mesh, base[1], base[2], ridgeBack)
	addTriangle(mesh, base[4], ridgeFront, base[3])
	addQuad(mesh, base[1], ridgeBack, ridgeFront, base[4])
	addQuad(mesh, base[2], base[3], ridgeFront, ridgeBack)
end

local function addWindowSet(mesh: EditableMesh, size: Vector3)
	local width = size.X
	local height = size.Y
	local depth = size.Z
	local frame = math.max(0.22, math.min(width, height) * 0.09)
	addCuboidGeometry(mesh, Vector3.new(width, frame, depth), Vector3.new(0, height / 2 - frame / 2, 0))
	addCuboidGeometry(mesh, Vector3.new(width, frame, depth), Vector3.new(0, -height / 2 + frame / 2, 0))
	addCuboidGeometry(mesh, Vector3.new(frame, height, depth), Vector3.new(-width / 2 + frame / 2, 0, 0))
	addCuboidGeometry(mesh, Vector3.new(frame, height, depth), Vector3.new(width / 2 - frame / 2, 0, 0))
	addCuboidGeometry(mesh, Vector3.new(frame * 0.65, height - frame * 2, depth * 1.04), Vector3.zero)
	addCuboidGeometry(mesh, Vector3.new(width - frame * 2, frame * 0.65, depth * 1.04), Vector3.zero)
end

local function addArchSegment(mesh: EditableMesh, size: Vector3, segments: number, thickness: number)
	local width = size.X
	local height = size.Y
	local depth = size.Z
	local outerRadius = width / 2
	local innerRadius = math.max(1, outerRadius - thickness)
	local legHeight = math.max(0.5, height - outerRadius)
	local springY = -height / 2 + legHeight
	local hz = depth / 2
	local frontOuter = {}
	local frontInner = {}
	local backOuter = {}
	local backInner = {}
	for segment = 0, segments do
		local angle = math.pi * segment / segments
		local outer = Vector3.new(math.cos(angle) * outerRadius, springY + math.sin(angle) * outerRadius, hz)
		local inner = Vector3.new(math.cos(angle) * innerRadius, springY + math.sin(angle) * innerRadius, hz)
		frontOuter[segment + 1] = mesh:AddVertex(outer)
		frontInner[segment + 1] = mesh:AddVertex(inner)
		backOuter[segment + 1] = mesh:AddVertex(Vector3.new(outer.X, outer.Y, -hz))
		backInner[segment + 1] = mesh:AddVertex(Vector3.new(inner.X, inner.Y, -hz))
	end
	for segment = 1, segments do
		local nextSegment = segment + 1
		addQuad(mesh, frontOuter[segment], frontOuter[nextSegment], frontInner[nextSegment], frontInner[segment])
		addQuad(mesh, backInner[segment], backInner[nextSegment], backOuter[nextSegment], backOuter[segment])
		addQuad(mesh, frontOuter[segment], backOuter[segment], backOuter[nextSegment], frontOuter[nextSegment])
		addQuad(mesh, frontInner[nextSegment], backInner[nextSegment], backInner[segment], frontInner[segment])
	end
	local legWidth = thickness
	local legCenterX = outerRadius - thickness / 2
	local legCenterY = -height / 2 + legHeight / 2
	addCuboidGeometry(mesh, Vector3.new(legWidth, legHeight, depth), Vector3.new(-legCenterX, legCenterY, 0))
	addCuboidGeometry(mesh, Vector3.new(legWidth, legHeight, depth), Vector3.new(legCenterX, legCenterY, 0))
end

local function addWaterArc(mesh: EditableMesh, size: Vector3, segments: number)
	local width = size.X
	local height = size.Y
	local radius = math.max(0.08, size.Z / 2)
	local sides = 6
	local rings = {}
	for step = 0, segments do
		local t = step / segments
		local x = -width / 2 + width * t
		local normalized = t * 2 - 1
		local y = height * (1 - normalized * normalized)
		local ring = {}
		for side = 0, sides - 1 do
			local angle = 2 * math.pi * side / sides
			ring[side + 1] = mesh:AddVertex(Vector3.new(x, y + math.cos(angle) * radius, math.sin(angle) * radius))
		end
		rings[step + 1] = ring
	end
	for step = 1, segments do
		for side = 1, sides do
			local nextSide = (side % sides) + 1
			addQuad(mesh, rings[step][side], rings[step][nextSide], rings[step + 1][nextSide], rings[step + 1][side])
		end
	end
end

local function addGeometry(mesh: EditableMesh, component)
	local sizeArray = component.size or { 1, 1, 1 }
	local size = Vector3.new(sizeArray[1], sizeArray[2], sizeArray[3])
	local shape = component.shape
	if shape == "beveledBox" or shape == "panel" then
		local bevel = component.bevel or math.min(size.X, size.Y, size.Z) * 0.12
		local normalized = math.clamp(bevel / math.max(0.001, math.min(size.X, size.Y, size.Z) / 2), 0.05, 0.85)
		local exponent = 0.18 + normalized * 0.22
		addSuperellipsoid(mesh, size, exponent, component.segments or 12, component.rings or 7)
	elseif shape == "ellipsoid" then
		addSuperellipsoid(mesh, size, 1, component.segments or DEFAULT_SEGMENTS, component.rings or DEFAULT_RINGS)
	elseif shape == "frustum" then
		addFrustum(mesh, size, component.segments or DEFAULT_SEGMENTS, component.topScale or 0.7)
	elseif shape == "cylinder" then
		addFrustum(mesh, size, component.segments or 16, 1)
	elseif shape == "gableRoof" then
		addGableRoof(mesh, size)
	elseif shape == "hipRoof" then
		addHipRoof(mesh, size)
	elseif shape == "windowSet" then
		addWindowSet(mesh, size)
	elseif shape == "archSegment" then
		addArchSegment(mesh, size, component.segments or 12, component.thickness or math.max(1, size.X * 0.12))
	elseif shape == "waterArc" then
		addWaterArc(mesh, size, component.segments or 12)
	else
		error("Unsupported ART R4 mesh shape: " .. tostring(shape))
	end
end

local function componentCFrame(component): CFrame
	local position = component.position or { 0, 0, 0 }
	local rotation = component.rotation or { 0, 0, 0 }
	return CFrame.new(position[1], position[2], position[3])
		* CFrame.Angles(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))
end

function ProductionMeshFactory.createComponent(parent: Instance, component, rootCFrame: CFrame, palette): MeshPart?
	local editableMesh = AssetService:CreateEditableMesh()
	if editableMesh == nil then
		warn("[TinyWorld ART R4] EditableMesh allocation failed for", component.name)
		return nil
	end

	local ok, geometryError = pcall(function()
		addGeometry(editableMesh, component)
	end)
	if not ok then
		warn("[TinyWorld ART R4] mesh geometry failed for", component.name, geometryError)
		editableMesh:Destroy()
		return nil
	end

	local meshPart = nil
	local created, createError = pcall(function()
		meshPart = AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {
			CollisionFidelity = Enum.CollisionFidelity.Box,
		})
	end)
	if not created or meshPart == nil then
		warn("[TinyWorld ART R4] MeshPart creation failed for", component.name, createError)
		editableMesh:Destroy()
		return nil
	end

	meshPart.Name = component.name
	meshPart.Anchored = true
	meshPart.CanCollide = false
	meshPart.CanTouch = false
	meshPart.CanQuery = false
	meshPart.CFrame = rootCFrame * componentCFrame(component)
	meshPart.Color = palette.colors[component.color] or Color3.fromRGB(255, 255, 255)
	meshPart.Material = MATERIALS[component.material] or Enum.Material.SmoothPlastic
	meshPart.Transparency = component.transparency or 0
	meshPart.CastShadow = component.role ~= "fountain-water-arc" and component.role ~= "fountain-water"
	meshPart:SetAttribute("TinyWorldArtRole", component.role or "production-mesh")
	meshPart:SetAttribute("TinyWorldVisualState", "production-preview-r4")
	meshPart:SetAttribute("TinyWorldProductionMesh", true)
	meshPart.Parent = parent

	if component.role == "lantern-glass" then
		local light = Instance.new("PointLight")
		light.Name = "ART_R4_PracticalLight"
		light.Brightness = 0.48
		light.Range = 10
		light.Color = palette.colors.warmLight or Color3.fromRGB(255, 224, 155)
		light.Shadows = true
		light.Parent = meshPart
	end

	return meshPart
end

return ProductionMeshFactory
