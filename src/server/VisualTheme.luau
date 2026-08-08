local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local palette = require(shared:WaitForChild("VisualPalette"))

local VisualTheme = {
	Colors = {},
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
	Lighting.Technology = Enum.Technology.ShadowMap
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2.1
	Lighting.ClockTime = 14.4
	Lighting.Ambient = VisualTheme.Colors.inkSoft
	Lighting.OutdoorAmbient = VisualTheme.Colors.sky
	Lighting.ColorShift_Top = VisualTheme.Colors.warmLight
	Lighting.ColorShift_Bottom = VisualTheme.Colors.meadow
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 0.2

	local atmosphere = getOrCreate("Atmosphere", "TinyWorldAtmosphere")
	atmosphere.Density = 0.18
	atmosphere.Offset = 0.2
	atmosphere.Color = VisualTheme.Colors.sky
	atmosphere.Decay = VisualTheme.Colors.inkSoft
	atmosphere.Glare = 0.08
	atmosphere.Haze = 0.7

	local correction = getOrCreate("ColorCorrectionEffect", "TinyWorldColorGrade")
	correction.Brightness = 0.03
	correction.Contrast = 0.06
	correction.Saturation = 0.08
	correction.TintColor = VisualTheme.Colors.paper

	local bloom = getOrCreate("BloomEffect", "TinyWorldBloom")
	bloom.Intensity = 0.08
	bloom.Size = 24
	bloom.Threshold = 1.2
end

return VisualTheme
