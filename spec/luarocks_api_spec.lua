local api = require 'loverocks.api'
local util = require 'loverocks.util'
local lfs = require 'lfs'

describe("loverocks api", function()
	setup(function()
		local New = require 'loverocks.commands.new'
		require 'spec.test_config'()
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
		lfs.chdir("my-project")
	end)

	teardown(function()
		lfs.chdir("..")
		assert(util.rm("my-project"))
	end)

	it("can search", function()
		local pkg = api.search("inspect", "2.0-1")[1]
		assert.same(pkg, {
			package = "inspect",
			repo = "https://luarocks.org",
			version = "2.0-1"
		})
	end)

	it("can install/remove", function()
		assert(api.install("inspect", "2.0-1", {}))
		assert(api.remove("inspect", "2.0-1", {}))
	end)
end)
