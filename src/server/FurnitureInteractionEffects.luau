local Debris = game:GetService("Debris")

local FurnitureInteractionEffects = {}

local LIGHT_VERBS = {
	switch = true,
	cook = true,
	read = true,
	play = true,
	craft = true,
}

local WATER_VERBS = {
	water = true,
	wash = true,
	shower = true,
	bathe = true,
}

local function firstVisualPart(model: Model): BasePart?
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("TinyWorldInteractionAnchor") ~= true then
			return descendant
		end
	end
	return nil
end

local function effectAnchor(model: Model): BasePart?
	local anchor = model:FindFirstChild("InteractionAnchor", true)
	if anchor and anchor:IsA("BasePart") then
		return anchor
	end
	return firstVisualPart(model)
end

local function setLight(model: Model, active: boolean, warm: boolean)
	local anchor = effectAnchor(model)
	if anchor == nil then
		return
	end
	local light = anchor:FindFirstChild("TinyWorldFurnitureLight")
	if light == nil then
		light = Instance.new("PointLight")
		light.Name = "TinyWorldFurnitureLight"
		light.Range = 9
		light.Brightness = 1.3
		light.Shadows = true
		light.Parent = anchor
	end
	if light:IsA("PointLight") then
		light.Color = if warm then Color3.fromRGB(255, 198, 113) else Color3.fromRGB(219, 233, 255)
		light.Enabled = active
	end
end

local function emitDroplets(model: Model)
	local anchor = effectAnchor(model)
	if anchor == nil then
		return
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "TinyWorldWaterFeedback"
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.45, 0.75)
	emitter.Speed = NumberRange.new(2.5, 4.5)
	emitter.SpreadAngle = Vector2.new(35, 35)
	emitter.Acceleration = Vector3.new(0, -7, 0)
	emitter.Color = ColorSequence.new(Color3.fromRGB(121, 199, 232), Color3.fromRGB(210, 238, 247))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.22),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	emitter.Parent = anchor
	emitter:Emit(12)
	Debris:AddItem(emitter, 1.2)
end

local function findDoorLikePart(model: Model): BasePart?
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local lower = string.lower(descendant.Name)
			if
				string.find(lower, "door", 1, true)
				or string.find(lower, "lid", 1, true)
				or string.find(lower, "drawer", 1, true)
			then
				return descendant
			end
		end
	end
	return nil
end

local function toggleDoorLike(model: Model, active: boolean)
	local part = findDoorLikePart(model)
	if part == nil then
		setLight(model, active, true)
		return
	end
	local closed = part:GetAttribute("TinyWorldClosedCFrame")
	if typeof(closed) ~= "CFrame" then
		closed = part.CFrame
		part:SetAttribute("TinyWorldClosedCFrame", closed)
	end
	part.CFrame = if active then closed * CFrame.Angles(0, math.rad(-28), 0) else closed
end

local function seatPlayer(player: Player)
	local character = player.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Sit = true
	end
end

local function pulse(model: Model)
	local part = firstVisualPart(model)
	if part == nil then
		return
	end
	local original = part:GetAttribute("TinyWorldOriginalInteractionColor")
	if typeof(original) ~= "Color3" then
		original = part.Color
		part:SetAttribute("TinyWorldOriginalInteractionColor", original)
	end
	part.Color = original:Lerp(Color3.new(1, 1, 1), 0.22)
	task.delay(0.35, function()
		if part.Parent then
			part.Color = original
		end
	end)
end

function FurnitureInteractionEffects.apply(player: Player, model: Model, interaction: string, active: boolean)
	if interaction == "sit" or interaction == "rest" then
		seatPlayer(player)
		pulse(model)
		return
	end
	if interaction == "open" or interaction == "store" or interaction == "dress" then
		toggleDoorLike(model, active)
		return
	end
	if LIGHT_VERBS[interaction] then
		setLight(model, active, interaction == "switch" or interaction == "cook")
		pulse(model)
		return
	end
	if WATER_VERBS[interaction] then
		emitDroplets(model)
		return
	end
	if interaction == "plant" or interaction == "harvest" then
		pulse(model)
		setLight(model, active, false)
		return
	end
	pulse(model)
end

return FurnitureInteractionEffects
