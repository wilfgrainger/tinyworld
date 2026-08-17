local R8AssetRules = {}

local REQUIRED_STRING_FIELDS = {
	"id",
	"path",
	"sha256",
	"role",
	"source",
	"license",
	"revision",
}

local function validSha256(value)
	return type(value) == "string" and #value == 64 and string.match(value, "^[0-9a-f]+$") ~= nil
end

function R8AssetRules.validateManifest(manifest)
	if type(manifest) ~= "table" then
		return false, "manifest must be a table"
	end
	if manifest.schemaVersion ~= 1 then
		return false, "schemaVersion must be 1"
	end
	if manifest.artRevision ~= "ART R8" then
		return false, "artRevision must be ART R8"
	end
	if type(manifest.models) ~= "table" then
		return false, "models must be a table"
	end

	local seen = {}
	for _, model in manifest.models do
		if type(model) ~= "table" then
			return false, "model entry must be a table"
		end
		for _, field in REQUIRED_STRING_FIELDS do
			local value = model[field]
			if type(value) ~= "string" or value == "" then
				return false, field .. " must be a non-empty string"
			end
		end
		if seen[model.id] then
			return false, "duplicate model id: " .. model.id
		end
		seen[model.id] = true
		if not validSha256(model.sha256) then
			return false, "sha256 must be 64 lowercase hex characters"
		end
		if model.devApproved ~= true then
			return false, "model is not DEV approved: " .. model.id
		end
	end

	return true, nil
end

return R8AssetRules
