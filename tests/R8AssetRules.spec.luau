local TestUtil = require("./TestUtil")
local R8AssetRules = require("../src/shared/R8AssetRules")

local function validModel(id)
	return {
		id = id,
		path = "assets/models/r8/Homes/HomeTier1.rbxmx",
		sha256 = string.rep("a", 64),
		role = "home",
		source = "TinyWorld original",
		license = "Project-owned original",
		revision = "r8.1",
		devApproved = true,
	}
end

return function()
	local ok, reason = R8AssetRules.validateManifest({
		schemaVersion = 1,
		artRevision = "ART R8",
		models = { validModel("home-tier-1") },
	})
	TestUtil.isTrue(ok)
	TestUtil.equal(reason, nil)

	local duplicateOk = R8AssetRules.validateManifest({
		schemaVersion = 1,
		artRevision = "ART R8",
		models = { validModel("same"), validModel("same") },
	})
	TestUtil.isFalse(duplicateOk)

	local unapproved = validModel("unapproved")
	unapproved.devApproved = false
	local approvedOk = R8AssetRules.validateManifest({
		schemaVersion = 1,
		artRevision = "ART R8",
		models = { unapproved },
	})
	TestUtil.isFalse(approvedOk)

	local blankPath = validModel("blank-path")
	blankPath.path = ""
	local pathOk = R8AssetRules.validateManifest({
		schemaVersion = 1,
		artRevision = "ART R8",
		models = { blankPath },
	})
	TestUtil.isFalse(pathOk)

	local badHash = validModel("bad-hash")
	badHash.sha256 = "abc"
	local hashOk = R8AssetRules.validateManifest({
		schemaVersion = 1,
		artRevision = "ART R8",
		models = { badHash },
	})
	TestUtil.isFalse(hashOk)
end
