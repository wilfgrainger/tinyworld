local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local ReleaseInfo = require(shared:WaitForChild("ReleaseInfo"))
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("TinyWorldBuildStamp")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TinyWorldBuildStamp"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 11
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local stamp = Instance.new("TextLabel")
stamp.Name = "CandidateStamp"
stamp.Position = UDim2.fromOffset(12, 120)
stamp.Size = UDim2.fromOffset(300, 24)
stamp.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
stamp.BackgroundTransparency = 0.18
stamp.BorderSizePixel = 0
stamp.TextColor3 = Color3.fromRGB(255, 255, 255)
stamp.TextTransparency = 0.04
stamp.Font = Enum.Font.GothamMedium
stamp.TextSize = 12
stamp.TextXAlignment = Enum.TextXAlignment.Center
stamp.TextYAlignment = Enum.TextYAlignment.Center
stamp.Text = string.format(
	"%s %s · v%s · %s · %s",
	ReleaseInfo.productName,
	ReleaseInfo.channel,
	ReleaseInfo.productVersion,
	ReleaseInfo.candidate,
	ReleaseInfo.artRevision
)
stamp.Active = false
stamp.Selectable = false
stamp.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 7)
corner.Parent = stamp

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.84
stroke.Thickness = 1
stroke.Parent = stamp
