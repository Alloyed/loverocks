require 'spec.test_config'()

describe("install.build", function()
	local install = require 'loverocks.commands.install'
	it("works", function()
		local argparse = require 'argparse'
		local parser = argparse()
		install.build(parser)

		assert.same(
			{packages = {'inspect'}},
			parser:parse{'inspect'})

		assert.same(
			{packages = {'inspect', 'argparse'}},
			parser:parse{'inspect', 'argparse'})

		assert.same(
			{packages = {'inspect'}, only_server = "wat"},
			parser:parse{'inspect', '--only-server', 'wat'})

		assert.same(
			{packages = {'inspect'}, only_deps = true},
			parser:parse{'inspect', '--only-deps'})

		assert.same(
			{packages = {'inspect'}, server = 'wat'},
			parser:parse{'inspect', '--server', 'wat'})

		assert.same(
			{packages = {'inspect'}, server = 'wat'},
			parser:parse{'inspect', '-s', 'wat'})
	end)
end)

describe("loverocks install", function()
	local install = require 'loverocks.commands.install'
	local purge = require 'loverocks.commands.purge'

	require 'spec.env'.setup()

	it("Can install normal rocks", function()
		install.run(conf, {
			packages = {"inspect"},
			only_server = cwd .. "/test-repo"
		})
		local mod = loadfile("rocks/share/lua/5.1/inspect.lua")
		assert.equal('table', type(mod()))
	end)

	it("can install to custom rocks trees", function()
		conf.rocks_tree = "foobar"
		install.run(conf, {
			packages = {"inspect"},
			only_server = cwd .. "/test-repo"
		})
		local mod = loadfile("foobar/share/lua/5.1/inspect.lua")
		assert.equal('table', type(mod()))
	end)

	it("can use custom rocks servers", function()
		conf.rocks_servers = { cwd .. "/test-repo" }
		install.run(conf, {
			packages = {"cpml"},
		})
		assert.equal('table', type(loadfile("rocks/share/lua/5.1/cpml/modules/vec2.lua")()))
	end)

	it("can install dependencies of a rock", function()
		install.run(conf, {
			packages = {"love3d"},
			only_deps = true,
			only_server = cwd .. "/test-repo"
		})

		assert.equal('nil', type(loadfile("rocks/share/lua/5.1/love3d/init.lua")))
		assert.equal('table', type(loadfile("rocks/share/lua/5.1/cpml/modules/vec2.lua")()))
	end)
end)
