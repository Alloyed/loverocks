require 'spec.test_config'()
local util = require 'spec.util'

describe("deps.build()", function()
	local deps = require 'loverocks.commands.deps'
	it("works", function()
		local parser = require 'argparse'()
		deps.build(parser)
		assert.same(
			{},
			parser:parse{})

		assert.same(
			{only_server = "wat"},
			parser:parse{'--only-server', 'wat'})

		assert.same(
			{server = 'wat'},
			parser:parse{'--server', 'wat'})

		assert.same(
			{server = 'wat'},
			parser:parse{'-s', 'wat'})

		assert.is_false((parser:pparse({'nope'})))
	end)
end)
describe("loverocks deps", function()
	local deps = require 'loverocks.commands.deps'

	require 'spec.env'.setup()

	it("satisfies deps listed in conf", function()
		conf.dependencies = {"inspect"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		local mod = loadfile("rocks/share/lua/5.1/inspect.lua")
		assert.equal('table', type(mod()))
	end)

	it("can follow deps chains", function()
		conf.dependencies = {"inspect", "love3d"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		assert.equal('table', type(loadfile("rocks/share/lua/5.1/inspect.lua")()))
		assert.equal('function', type(loadfile("rocks/share/lua/5.1/love3d/init.lua")))
		assert.equal('table', type(loadfile("rocks/share/lua/5.1/cpml/modules/vec2.lua")()))
	end)

	it("will error if missing deps table", function()
		conf.dependencies = nil

		local log = require('loverocks.log')
		local e = log.use.error
		finally(function() log.use.error = e end)
		log.use.error = false

		assert.has_errors(function()
			deps.run(conf, {only_server = cwd .. "/test-repo"})
		end)
	end)

	it("will regen missing rockstrees", function()
		util.rm("./rocks")
		assert.falsy(util.is_dir("./rocks"))
		conf.dependencies = {"inspect"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		assert.truthy(util.is_file("./rocks/init.lua"))
		assert.equal('table', type(loadfile("rocks/share/lua/5.1/inspect.lua")()))
	end)
end)
