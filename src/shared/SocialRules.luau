local SocialRules = {}

SocialRules.MAX_PARTY_SIZE = 4

function SocialRules.privacyAllows(privacy: string, isOwner: boolean, isFriend: boolean): boolean
	if isOwner then
		return true
	end
	if privacy == "Open" then
		return true
	elseif privacy == "Friends" then
		return isFriend
	end
	return false
end

function SocialRules.partySize(members: { [any]: boolean }): number
	local count = 0
	for member, active in members do
		if active and member ~= nil then
			count += 1
		end
	end
	return count
end

function SocialRules.joinParty(members: { [any]: boolean }, member: any): (boolean, string)
	if members[member] then
		return false, "already_member"
	end
	if SocialRules.partySize(members) >= SocialRules.MAX_PARTY_SIZE then
		return false, "party_full"
	end
	members[member] = true
	return true, "joined"
end

function SocialRules.leaveParty(members: { [any]: boolean }, member: any): (boolean, string)
	if not members[member] then
		return false, "not_member"
	end
	members[member] = nil
	return true, "left"
end

function SocialRules.canShareActivity(members: { [any]: boolean }, member: any): boolean
	return members[member] == true and SocialRules.partySize(members) >= 2
end

return SocialRules
