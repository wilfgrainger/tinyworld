local AmbientLifeService = {}
AmbientLifeService.__index = AmbientLifeService

function AmbientLifeService.new(_world)
	local self = setmetatable({}, AmbientLifeService)
	-- v0.6.2 deliberately ships no creature actors rather than presenting
	-- primitive Part-built animals as finished ambient character art.
	-- Reintroduce ambient characters only through the approved asset pipeline
	-- with provenance and exact-candidate Studio evidence.
	self.running = true
	return self
end

function AmbientLifeService:stop()
	self.running = false
end

return AmbientLifeService
