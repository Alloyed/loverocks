local api = require 'loverocks.api'
local util = require 'loverocks.util'
local lfs = require 'lfs'

local cwd = lfs.currentdir()
describe("loverocks api", function()
	setup(function()
		local New = require 'loverocks.commands.new'
		require 'spec.test_config'()
		assert(util.is_dir("test-repo"))
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
		lfs.chdir("my-project")
	end)

	teardown(function()
		lfs.chdir(cwd)
		assert(util.rm("my-project"))
	end)

	it("can search", function()
		pending("")
		local pkg = api.search("inspect", "2.0-1", {only_from=cwd .. "/test-repo"})[1]
		assert.equal("inspect", pkg.package)
		assert.equal("2.0-1", pkg.version)
	end)

	it("can install/remove", function()
		assert(api.install("inspect", "2.0-1", {only_from=cwd .. "/test-repo"}))
		assert(api.remove("inspect", "2.0-1", {only_from=cwd .. "/test-repo"}))
	end)
end)
