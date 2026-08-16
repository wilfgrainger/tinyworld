local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local palette = require(shared:WaitForChild("VisualPalette"))

local VisualTheme = {
	Colors = {},
	Ambient = {
		MAX_CHIMNEY_SMOKE_EMITTERS = 3,
		MAX_WARM_WINDOW_LIGHTS = 4,
		MAX_WATER_HIGHLIGHTS = 4,
		MAX_FOLIAGE_HOOKS = 6,
		MAX_BIRD_HOOKS = 3,
		MAX_BUTTERFLY_HOOKS = 4,
		MAX_TOTAL_EFFECTS = 24,
		SMOKE_RATE = 1,
	},
}

for name, hex in palette do
	VisualTheme.Colors[name] = Color3.fromHex(hex)
end

local function getOrCreate(className: string, name: string)
	local existing = Lighting:FindFirstChild(name)
	if existing and existing:IsA(className) then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local created = Instance.new(className)
	created.Name = name
	created.Parent = Lighting
	return created
end

function VisualTheme.configureLighting()
	Lighting:SetAttribute("TinyWorldArtRevision", "ART R7")
	Lighting:SetAttribute("TinyWorldLightingStyle", "bright-premium-toy-world")
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2.35
	Lighting.ClockTime = 14.1
	Lighting.Ambient = Color3.fromRGB(132, 142, 157)
	Lighting.OutdoorAmbient = VisualTheme.Colors.sky
	Lighting.ColorShift_Top = Color3.fromRGB(255, 242, 213)
	Lighting.ColorShift_Bottom = Color3.fromRGB(197, 229, 178)
	Lighting.EnvironmentDiffuseScale = 0.42
	Lighting.EnvironmentSpecularScale = 0.28

	local atmosphere = getOrCreate("Atmosphere", "TinyWorldAtmosphere")
	atmosphere.Density = 0.11
	atmosphere.Offset = 0.3
	atmosphere.Color = Color3.fromRGB(205, 239, 250)
	atmosphere.Decay = Color3.fromRGB(129, 151, 175)
	atmosphere.Glare = 0.05
	atmosphere.Haze = 0.38

	local correction = getOrCreate("ColorCorrectionEffect", "TinyWorldColorGrade")
	correction.Brightness = 0.055
	correction.Contrast = 0.055
	correction.Saturation = 0.16
	correction.TintColor = Color3.fromRGB(255, 250, 238)

	local bloom = getOrCreate("BloomEffect", "TinyWorldBloom")
	bloom.Intensity = 0.075
	bloom.Size = 20
	bloom.Threshold = 1.35

	local sunRays = getOrCreate("SunRaysEffect", "TinyWorldSunRays")
	sunRays.Intensity = 0.025
	sunRays.Spread = 0.72
end

return VisualTheme
