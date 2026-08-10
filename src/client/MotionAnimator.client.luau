local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local modelOffsets = {}
local phaseSnapshots = {}
local motionModels = {}

local function rememberModel(model: Model)
	if modelOffsets[model] == nil then
		local pivot = model:GetPivot()
		local offsets = {}
		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				local role = descendant:GetAttribute("TinyWorldMotionRole")
				if role == "wheel-spin" or role == "flag-flutter" then
					offsets[descendant] = pivot:ToObjectSpace(descendant.CFrame)
				end
			end
		end
		modelOffsets[model] = offsets
	end
end

local function trackModel(model: Instance)
	if not model:IsA("Model") then
		return
	end
	motionModels[model] = true
	rememberModel(model)
end

local function forgetModel(model: Instance)
	motionModels[model] = nil
	modelOffsets[model] = nil
	phaseSnapshots[model] = nil
end

for _, model in CollectionService:GetTagged("TinyWorldMotionModel") do
	trackModel(model)
end
CollectionService:GetInstanceAddedSignal("TinyWorldMotionModel"):Connect(trackModel)
CollectionService:GetInstanceRemovedSignal("TinyWorldMotionModel"):Connect(forgetModel)

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for model in motionModels do
		if model.Parent == nil then
			forgetModel(model)
			continue
		end
		local state = model:GetAttribute("TinyWorldMotionState")
		if state == nil then
			continue
		end

		local phase = model:GetAttribute("TinyWorldMotionPhase") or 0
		local snapshot = phaseSnapshots[model]
		if snapshot == nil or snapshot.phase ~= phase then
			snapshot = { phase = phase, receivedAt = now }
			phaseSnapshots[model] = snapshot
		end
		local visualPhase = if state == "parked" or state == "docked"
			then 0
			else snapshot.phase + ((now - snapshot.receivedAt) * 8)
		local pivot = model:GetPivot()
		for part, offset in modelOffsets[model] do
			if part.Parent == nil then
				continue
			end
			local role = part:GetAttribute("TinyWorldMotionRole")
			local rotation = if role == "wheel-spin"
				then CFrame.Angles(visualPhase, 0, 0)
				else CFrame.Angles(0, math.sin(visualPhase * 1.7) * 0.12, 0)
			part.CFrame = pivot * offset * rotation
		end
	end
end)
