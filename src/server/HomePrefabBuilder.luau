local VisualTheme = require(script.Parent:WaitForChild("VisualTheme"))
local R8AssetLibrary = require(script.Parent:WaitForChild("R8AssetLibrary"))

local HomePrefabBuilder = {}

local function themeAccent(profile): Color3
	if profile.homeTheme == "Harbor" then
		return VisualTheme.Colors.skyDeep
	elseif profile.homeTheme == "Sunset" then
		return VisualTheme.Colors.berry
	end
	return VisualTheme.Colors.flower
end

local function applyTheme(shell: Model, profile)
	local accent = themeAccent(profile)
	for _, descendant in shell:GetDescendants() do
		if descendant:IsA("BasePart") then
			if descendant.Name == "DoorAccent" or string.find(descendant.Name, "Accent", 1, true) then
				descendant.Color = accent
			end
		end
	end
end

local function configureAnchors(shell: Model)
	local frontDoorAnchor = shell:FindFirstChild("FrontDoorAnchor", true)
	if frontDoorAnchor == nil or not frontDoorAnchor:IsA("BasePart") then
		error("R8 home prefab missing FrontDoorAnchor")
	end
	frontDoorAnchor.Transparency = 1
	frontDoorAnchor.CanCollide = false
	frontDoorAnchor.CanTouch = false
	frontDoorAnchor.CanQuery = true
	frontDoorAnchor:SetAttribute("TinyWorldInteractionAnchor", true)
	frontDoorAnchor:SetAttribute("TinyWorldArtRole", "home-front-door-anchor")

	local interiorOrigin = shell:FindFirstChild("InteriorOrigin", true)
	if interiorOrigin == nil or not interiorOrigin:IsA("BasePart") then
		error("R8 home prefab missing InteriorOrigin")
	end
	interiorOrigin.Transparency = 1
	interiorOrigin.CanCollide = false
	interiorOrigin.CanTouch = false
	interiorOrigin.CanQuery = false
	interiorOrigin:SetAttribute("TinyWorldArtRole", "home-interior-origin")
end

function HomePrefabBuilder.buildShell(parent: Instance, anchor: Vector3, profile, house): Model
	local tier = math.clamp(tonumber(profile.houseTier) or 1, 1, 5)
	local shell = R8AssetLibrary.clonePrefab("Homes", "HomeTier" .. tostring(tier))
	shell.Name = "ResidentialShell"
	shell:SetAttribute("TinyWorldArtRole", "hero-home-shell")
	shell:SetAttribute("TinyWorldPhysicalAffordance", "world-object")
	shell:SetAttribute("TinyWorldRecognizableSilhouette", true)
	shell:SetAttribute("TinyWorldVisualState", "authored-prefab-r8")
	shell:SetAttribute("TinyWorldArtRevision", "ART R8")
	shell:SetAttribute("TinyWorldHouseTier", tier)
	shell:SetAttribute("TinyWorldHouseTheme", profile.homeTheme)
	shell:SetAttribute("TinyWorldHouseName", if house then house.name else "TinyWorld Home")
	shell.Parent = parent
	shell:PivotTo(CFrame.new(anchor))

	configureAnchors(shell)
	applyTheme(shell, profile)
	return shell
end

return HomePrefabBuilder
