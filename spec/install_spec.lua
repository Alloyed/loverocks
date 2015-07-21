local lfs = require 'lfs'

local util = require 'loverocks.util'
local lua  = require 'loverocks.commands.lua'

local cwd = lfs.currentdir()
describe("loverocks install", function()
	local Install = require 'loverocks.commands.install'
	require 'spec.test_config'()
	setup(function()
		local New = require 'loverocks.commands.new'
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

	it("Can install normal rocks", function()
		finally(function()
			lua.luarocks {"purge"}
		end)
		Install:run {
			new_packages = {"inspect"},
			only_server = cwd .. "/test-repo"
		}
		assert(loadfile("rocks/share/lua/5.1/inspect.lua"))
	end)
end)
