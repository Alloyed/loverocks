require 'spec.test_config'()
describe("loverocks deps", function()
	local deps = require 'loverocks.commands.deps'
	require 'spec.env'.setup()
end)
