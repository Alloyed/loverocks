require 'spec.test_config'()
describe("loverocks purge", function()
	local purge = require 'loverocks.commands.purge'
	require 'spec.env'.setup()
end)
