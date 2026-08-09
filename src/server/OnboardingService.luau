local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local OnboardingRules = require(shared:WaitForChild("OnboardingRules"))

local OnboardingService = {}
OnboardingService.__index = OnboardingService

local PALETTES = {
	Meadow = {
		torso = Color3.fromRGB(104, 153, 93),
		arms = Color3.fromRGB(246, 231, 183),
		legs = Color3.fromRGB(112, 76, 48),
	},
	Harbor = {
		torso = Color3.fromRGB(67, 119, 168),
		arms = Color3.fromRGB(211, 220, 226),
		legs = Color3.fromRGB(38, 56, 82),
	},
	Sunset = {
		torso = Color3.fromRGB(222, 111, 51),
		arms = Color3.fromRGB(255, 205, 91),
		legs = Color3.fromRGB(91, 54, 44),
	},
}

local function getRemote(): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild("TinyWorld")
	local existing = folder:FindFirstChild("OnboardingRemote")
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = "OnboardingRemote"
	remote.Parent = folder
	return remote
end

local function applyPalette(player: Player, outfit: string)
	local palette = PALETTES[outfit]
	local character = player.Character
	if palette == nil or character == nil then
		return
	end

	local bodyColors = character:FindFirstChildOfClass("BodyColors")
	if bodyColors == nil then
		bodyColors = Instance.new("BodyColors")
		bodyColors.Parent = character
	end

	bodyColors.TorsoColor = BrickColor.new(palette.torso)
	bodyColors.LeftArmColor = BrickColor.new(palette.arms)
	bodyColors.RightArmColor = BrickColor.new(palette.arms)
	bodyColors.LeftLegColor = BrickColor.new(palette.legs)
	bodyColors.RightLegColor = BrickColor.new(palette.legs)
end

function OnboardingService.new(ProfileStore, PlayerStateService)
	local self = setmetatable({}, OnboardingService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.remote = getRemote()
	self.characterConnections = {}
	self.remote.OnServerEvent:Connect(function(player, payload)
		self:_submit(player, payload)
	end)
	return self
end

function OnboardingService:_reply(player: Player, ok: boolean, message: string)
	self.remote:FireClient(player, { ok = ok, message = message })
end

function OnboardingService:_setState(player: Player, profile)
	local complete = OnboardingRules.isComplete(profile)
	self.PlayerStateService.sync(player, profile)
	player:SetAttribute("TinyWorldOnboardingComplete", complete)
	player:SetAttribute("TinyWorldOnboardingRequired", not complete)
	if complete then
		applyPalette(player, profile.starterOutfit)
	end
	return complete
end

function OnboardingService:setupPlayer(player: Player, profile)
	local oldConnection = self.characterConnections[player]
	if oldConnection then
		oldConnection:Disconnect()
	end

	self:_setState(player, profile)
	self.characterConnections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.25)
		local latest = self.ProfileStore.get(player)
		if latest and OnboardingRules.isComplete(latest) then
			applyPalette(player, latest.starterOutfit)
		end
	end)
end

function OnboardingService:_filterName(player: Player, name: string): (string?, string?)
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(name, player.UserId)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	if not ok or type(result) ~= "string" then
		return nil, "TinyWorld could not check that name. Please try again."
	end

	local valid, _, trimmed = OnboardingRules.validateDisplayName(result)
	if not valid or trimmed == nil then
		return nil, "Please choose a different display name."
	end
	return trimmed, nil
end

function OnboardingService:_submit(player: Player, payload: any)
	local profile = self.ProfileStore.get(player)
	if profile == nil or OnboardingRules.isComplete(profile) then
		return
	end
	if type(payload) ~= "table" then
		self:_reply(player, false, "Please choose a name, style, and outfit.")
		return
	end

	local validName = OnboardingRules.validateDisplayName(payload.displayName)
	if not validName then
		self:_reply(player, false, "Use 3-16 letters, numbers, spaces, _ or - for your name.")
		return
	end
	if not OnboardingRules.isValidAvatarStyle(payload.avatarStyle) then
		self:_reply(player, false, "Choose Boy or Girl to continue.")
		return
	end
	if not OnboardingRules.isValidStarterOutfit(payload.starterOutfit) then
		self:_reply(player, false, "Choose one of the three free outfits to continue.")
		return
	end

	local filteredName, filterError = self:_filterName(player, payload.displayName)
	if filteredName == nil then
		self:_reply(player, false, filterError or "Please choose a different display name.")
		return
	end

	local previous = {
		displayName = profile.displayName,
		avatarStyle = profile.avatarStyle,
		starterOutfit = profile.starterOutfit,
		onboardingComplete = profile.onboardingComplete,
	}
	profile.displayName = filteredName
	profile.avatarStyle = payload.avatarStyle
	profile.starterOutfit = payload.starterOutfit
	profile.onboardingComplete = true

	if not self.ProfileStore.saveNow(player) then
		profile.displayName = previous.displayName
		profile.avatarStyle = previous.avatarStyle
		profile.starterOutfit = previous.starterOutfit
		profile.onboardingComplete = previous.onboardingComplete
		self:_setState(player, profile)
		self:_reply(player, false, "TinyWorld could not save your setup. Nothing was changed; please try again.")
		return
	end

	self:_setState(player, profile)
	self.PlayerStateService.message(player, "Welcome to TinyWorld, " .. profile.displayName .. "!")
	self:_reply(player, true, "Your TinyWorld setup is saved.")
end

function OnboardingService:removePlayer(player: Player)
	local connection = self.characterConnections[player]
	if connection then
		connection:Disconnect()
		self.characterConnections[player] = nil
	end
end

return OnboardingService

