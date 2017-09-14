require 'spec.test_config'()
describe("remove.build", function()
end)
describe("loverocks remove", function()
	local remove = require 'loverocks.commands.remove' --luacheck: ignore remove
	require 'spec.env'.setup()
end)
