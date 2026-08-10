local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("TinyWorld"):WaitForChild("Shared")
local Rules = require(shared:WaitForChild("RemoteGuardRules"))

local RemoteGuard = {}
local windows = {}

local function actionTable(player: Player)
	local actions = windows[player]
	if actions == nil then
		actions = {}
		windows[player] = actions
	end
	return actions
end

function RemoteGuard.checkRate(player: Player, action: string, limit: number, windowSeconds: number): boolean
	local actions = actionTable(player)
	local allowed, nextState = Rules.consumeWindow(actions[action], os.clock(), limit, windowSeconds)
	actions[action] = nextState
	return allowed
end

function RemoteGuard.stringWithin(value: any, minimumLength: number, maximumLength: number): boolean
	return Rules.stringWithin(value, minimumLength, maximumLength)
end

function RemoteGuard.integerInRange(value: any, minimum: number, maximum: number): boolean
	return Rules.integerInRange(value, minimum, maximum)
end

function RemoteGuard.numberInRange(value: any, minimum: number, maximum: number): boolean
	return Rules.numberInRange(value, minimum, maximum)
end

function RemoteGuard.allowedId(value: any, allowed: any): boolean
	return Rules.allowedId(value, allowed)
end

function RemoteGuard.playerWithinDistance(player: Player, position: Vector3, maxDistance: number): boolean
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	return (root.Position - position).Magnitude <= maxDistance
end

function RemoteGuard.warn(player: Player, action: string, reason: string)
	warn(string.format("TinyWorld security: user=%d action=%s rejected=%s", player.UserId, action, reason))
end

function RemoteGuard.clearPlayer(player: Player)
	windows[player] = nil
end

Players.PlayerRemoving:Connect(RemoteGuard.clearPlayer)

return RemoteGuard
