local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local OnboardingRules = require(shared:WaitForChild("OnboardingRules"))
local AnalyticsEvents = require(shared:WaitForChild("AnalyticsEvents"))
local RemoteGuard = require(script.Parent:WaitForChild("security"):WaitForChild("RemoteGuard"))
local TinyAnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local OnboardingService = {}
OnboardingService.__index = OnboardingService

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

function OnboardingService.new(ProfileStore, PlayerStateService, AppearanceService)
	local self = setmetatable({}, OnboardingService)
	self.ProfileStore = ProfileStore
	self.PlayerStateService = PlayerStateService
	self.AppearanceService = AppearanceService
	self.remote = getRemote()
	self.remoteConnection = self.remote.OnServerEvent:Connect(function(player, payload)
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
	if complete and self.AppearanceService then
		-- AppearanceService is the single writer for the complete TinyWorld look:
		-- body palette, hair fallback, shoes fallback and active-outfit attribute.
		self.AppearanceService:applyProfile(player, profile)
	end
	return complete
end

function OnboardingService:setupPlayer(player: Player, profile)
	self:_setState(player, profile)
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
	if not RemoteGuard.checkRate(player, "onboarding_submit", 5, 10) then
		RemoteGuard.warn(player, "onboarding_submit", "rate_limit")
		self:_reply(player, false, "Please wait a moment before trying again.")
		return
	end
	if type(payload) ~= "table" then
		RemoteGuard.warn(player, "onboarding_submit", "invalid_payload")
		self:_reply(player, false, "Please choose a name, style, and outfit.")
		return
	end
	if not RemoteGuard.stringWithin(payload.displayName, 3, 16) then
		RemoteGuard.warn(player, "onboarding_submit", "display_name_length")
		self:_reply(player, false, "Use 3-16 letters, numbers, spaces, _ or - for your name.")
		return
	end
	if
		type(payload.avatarStyle) ~= "string"
		or #payload.avatarStyle > 16
		or type(payload.starterOutfit) ~= "string"
		or #payload.starterOutfit > 16
	then
		RemoteGuard.warn(player, "onboarding_submit", "selection_shape")
		self:_reply(player, false, "Please choose a valid style and outfit.")
		return
	end

	local validName = OnboardingRules.validateDisplayName(payload.displayName)
	if not validName then
		self:_reply(player, false, "Use 3-16 letters, numbers, spaces, _ or - for your name.")
		return
	end
	if not OnboardingRules.isValidAvatarStyle(payload.avatarStyle) then
		RemoteGuard.warn(player, "onboarding_submit", "avatar_style")
		self:_reply(player, false, "Choose Boy or Girl to continue.")
		return
	end
	if not OnboardingRules.isValidStarterOutfit(payload.starterOutfit) then
		RemoteGuard.warn(player, "onboarding_submit", "starter_outfit")
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
	TinyAnalyticsService.log(player, AnalyticsEvents.OnboardingCompleted)
	self.PlayerStateService.message(player, "Welcome to TinyWorld, " .. profile.displayName .. "!")
	self:_reply(player, true, "Your TinyWorld setup is saved.")
end

function OnboardingService:removePlayer(player: Player)
	RemoteGuard.clearPlayer(player)
end

return OnboardingService
