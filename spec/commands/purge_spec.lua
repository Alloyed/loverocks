local util = require 'spec.util'
require 'spec.test_config'()

describe("purge.build", function()
	local purge = require 'loverocks.commands.purge'
	it("works", function()
		local argparse = require 'argparse'
		local parser = argparse()
		purge.build(parser)

		-- look mom, no args!
		assert.same(
		{},
		parser:parse{})

		assert.is_false((parser:pparse{"nope"}))
	end)
end)

describe("loverocks purge", function()
	local purge = require 'loverocks.commands.purge'
	local deps  = require 'loverocks.commands.deps'

	require 'spec.env'.setup()

	it("removes all modules without removing the tree", function()
		conf.dependencies = {"inspect", "love3d"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		assert.truthy(loadfile("rocks/share/lua/5.1/inspect.lua"))
		assert.truthy(loadfile("rocks/share/lua/5.1/love3d/init.lua"))
		purge.run(conf, {})
		assert.falsy(loadfile("rocks/share/lua/5.1/inspect.lua"))
		assert.falsy(loadfile("rocks/share/lua/5.1/love3d/init.lua"))
	end)

	it("will error if rocks tree does not exist", function()
		local log = require('loverocks.log')
		local e = log.use.error
		finally(function() log.use.error = e end)
		log.use.error = false

		util.rm("rocks")
		assert.falsy(loadfile("rocks/init.lua"))
		assert.has_errors(function() purge.run(conf, {}) end, "os.exit(1)")
		assert.falsy(loadfile("rocks/init.lua"))
	end)
end)
