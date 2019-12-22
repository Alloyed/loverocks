require 'spec.test_config'()
local fs = require 'luarocks.fs'

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
	--luacheck: push ignore conf cwd

	it("satisfies deps listed in conf", function()
		conf.dependencies = {"inspect"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		assert(loadfile("rocks/share/lua/5.1/inspect.lua"))
	end)

	it("can follow deps chains #atm", function()
		conf.dependencies = {"inspect", "love3d"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		assert(loadfile("rocks/share/lua/5.1/inspect.lua"))
		assert(loadfile("rocks/share/lua/5.1/love3d/init.lua"))
		assert(loadfile("rocks/share/lua/5.1/cpml/modules/vec2.lua"))
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

	it("will regen missing rockstrees #atm", function()
		fs.delete("./rocks")
		assert.falsy(fs.is_dir("./rocks"))
		conf.dependencies = {"inspect"}
		deps.run(conf, {only_server = cwd .. "/test-repo"})
		assert.truthy(fs.is_file("./rocks/init.lua"))
		assert(loadfile("rocks/share/lua/5.1/inspect.lua"))
	end)

	--luacheck: pop
end)
