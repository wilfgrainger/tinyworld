local TestUtil = {}

function TestUtil.equal(actual: any, expected: any, message: string?)
	if actual ~= expected then
		error(message or string.format("expected %s, got %s", tostring(expected), tostring(actual)), 2)
	end
end

function TestUtil.isTrue(value: any, message: string?)
	if value ~= true then
		error(message or string.format("expected true, got %s", tostring(value)), 2)
	end
end

function TestUtil.isFalse(value: any, message: string?)
	if value ~= false then
		error(message or string.format("expected false, got %s", tostring(value)), 2)
	end
end

return TestUtil
