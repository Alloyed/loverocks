local util = require 'loverocks.util'
local lfs = require 'lfs'
describe("loverocks install", function()
	local Install = require 'loverocks.commands.install'
	setup(function()
		require('loverocks.log').use.info = true
		require('loverocks.log').use.ask  = false
		local New = require 'loverocks.commands.new'
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

	-- FIXME: make a local mirror so this test doesn't require internet access
	it("Can install normal rocks", function()
		finally(function()
			util.luarocks("purge")
		end)
		Install:run {
			new_packages = {"inspect"}
		}
		assert(loadfile("rocks/share/lua/5.1/inspect.lua"))
	end)
end)
