local util = require 'loverocks.util'
local lfs  = require 'lfs'
local New = require 'loverocks.commands.new'

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
