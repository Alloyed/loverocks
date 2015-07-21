local util = require 'loverocks.util'
local lfs  = require 'lfs'
local New = require 'loverocks.commands.new'
local Init = require 'loverocks.commands.init'

describe("loverocks new", function()
	require 'spec.test_config'()
	setup(function()
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
	end)

	teardown(function()
		assert(util.rm("my-project"))
	end)

	it("installs files", function()
		assert(io.open("my-project/conf.lua")):close()
	end)

	it("installs valid lua", function()
		-- FIXME: write a proper linter.
		assert(loadfile("my-project/conf.lua"))
		assert(loadfile("my-project/rocks/config.lua"))
		assert(loadfile("my-project/rocks/init.lua"))
	end)

	it("gives deterministic results", function()
		util.spit((util.slurp("my-project")), "my-projectB")
		finally(function() assert(util.rm("my-projectB")) end)
		assert(util.rm("my-project"))

		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}

		assert.same(util.slurp("my-project"), util.slurp("my-projectB"))
	end)
end)

describe("loverocks init", function()
	before_each(function()
		require('loverocks.log').use.info = false
		require('loverocks.log').use.ask  = false
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
	end)
	after_each(function()
		assert(util.rm("my-project"))
	end)

	it("can recreate a rocks tree", function()
		assert(util.rm("my-project/rocks"))
		Init:run { template = "love9", path = "my-project" }
		assert(loadfile("my-project/conf.lua"))
		assert(loadfile("my-project/rocks/config.lua"))
		assert(loadfile("my-project/rocks/init.lua"))
	end)

	it("can recreate a rockspec", function()
		assert(util.rm("my-project/my-project-scm-1.rockspec"))
		Init:run { template = "love9", path = "my-project" }
		assert(loadfile("my-project/my-project-scm-1.rockspec"))
		assert(loadfile("my-project/conf.lua"))
		assert(loadfile("my-project/rocks/config.lua"))
		assert(loadfile("my-project/rocks/init.lua"))
	end)

	it("can inject itself into conf.lua", function()
		assert(util.spit([[
		function love.conf(t)
			t.identity="my-project"
		end
		]], "my-project/conf.lua"))
		Init:run { template = "love9", path = "my-project" }
		assert(util.slurp("my-project/conf.lua"):match("require 'rocks' %(%)"))
		assert(loadfile("my-project/conf.lua"))
		assert(loadfile("my-project/rocks/config.lua"))
		assert(loadfile("my-project/rocks/init.lua"))
	end)
end)
