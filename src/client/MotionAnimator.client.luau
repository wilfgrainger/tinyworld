local RunService = game:GetService("RunService")

local modelOffsets = {}
local phaseSnapshots = {}

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

local function forgetDescendant(descendant: Instance)
	if descendant:IsA("Model") then
		modelOffsets[descendant] = nil
		phaseSnapshots[descendant] = nil
	end
end

workspace.DescendantRemoving:Connect(forgetDescendant)

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, descendant in workspace:GetDescendants() do
		if not descendant:IsA("Model") then
			continue
		end
		local state = descendant:GetAttribute("TinyWorldMotionState")
		if state == nil then
			continue
		end

		rememberModel(descendant)
		local phase = descendant:GetAttribute("TinyWorldMotionPhase") or 0
		local snapshot = phaseSnapshots[descendant]
		if snapshot == nil or snapshot.phase ~= phase then
			snapshot = { phase = phase, receivedAt = now }
			phaseSnapshots[descendant] = snapshot
		end
		local visualPhase = if state == "parked" or state == "docked" then 0 else snapshot.phase + ((now - snapshot.receivedAt) * 8)
		local pivot = descendant:GetPivot()
		for part, offset in modelOffsets[descendant] do
			if part.Parent == nil then
				continue
			end
			local role = part:GetAttribute("TinyWorldMotionRole")
			local rotation = if role == "wheel-spin" then CFrame.Angles(visualPhase, 0, 0) else CFrame.Angles(0, math.sin(visualPhase * 1.7) * 0.12, 0)
			part.CFrame = pivot * offset * rotation
		end
	end
end)
