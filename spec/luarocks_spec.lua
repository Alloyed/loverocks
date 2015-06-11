local util = require 'loverocks.util'
local lfs = require 'lfs'
describe("`loverocks lua`", function()
	setup(function()
		require('loverocks.log').use.info = false
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

	it("finds the appropriate config file", function()
		local s = assert(util.strluarocks("help"))
		assert(s:match("Lua version: 5.1"), "version not 5.1")
		assert(s:match("User%s+:%s+rocks/config.lua%s+%(ok%)"), "config not found")
	end)
end)
