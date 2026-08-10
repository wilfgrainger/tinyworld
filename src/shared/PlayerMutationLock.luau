local PlayerMutationLock = {}

local owners = setmetatable({}, { __mode = "k" })

local function validOwner(owner: any): boolean
	return type(owner) == "string" and owner ~= ""
end

function PlayerMutationLock.acquire(profile: any, owner: any): boolean
	if type(profile) ~= "table" or not validOwner(owner) then
		return false
	end
	local current = owners[profile]
	if current ~= nil and current ~= owner then
		return false
	end
	owners[profile] = owner
	return true
end

function PlayerMutationLock.release(profile: any, owner: any): boolean
	if type(profile) ~= "table" or owners[profile] ~= owner then
		return false
	end
	owners[profile] = nil
	return true
end

function PlayerMutationLock.canMutate(profile: any, owner: any?): boolean
	if type(profile) ~= "table" then
		return false
	end
	local current = owners[profile]
	return current == nil or (validOwner(owner) and current == owner)
end

function PlayerMutationLock.isLocked(profile: any): boolean
	return type(profile) == "table" and owners[profile] ~= nil
end

return PlayerMutationLock
