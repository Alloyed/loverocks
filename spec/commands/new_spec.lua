local util = require 'loverocks.util'
local lfs  = require 'lfs'
local New = require 'loverocks.commands.new'

describe("loverocks new", function()
	require 'spec.test_config'()
	setup(function()
		New.run {
			project      = "my-project",
			template     = "love",
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
		-- TODO: write a proper linter.
		assert(loadfile("my-project/conf.lua"))
		assert(loadfile("my-project/rocks/init.lua"))
	end)

	it("gives deterministic results", function()
		util.spit((util.slurp("my-project")), "my-projectB")
		finally(function() assert(util.rm("my-projectB")) end)
		assert(util.rm("my-project"))

		New.run {
			project      = "my-project",
			template     = "love",
			love_version = "0.9.2",
		}

		assert.same(util.slurp("my-project"), util.slurp("my-projectB"))
	end)
end)

describe("loverocks new parser", function()
	local argparse = require 'argparse'
	local parser
	setup(function()
		parser = argparse()
		function parser:error(msg)
			local log = require 'loverocks.log'
			log:_warning(self:get_usage().."\n")
			log:error("%s", msg)
		end
		New.build(parser)
	end)

	it("errors on empty args", function()
		require('loverocks.log').use.error = false
		finally(function() require('loverocks.log').use.error = true end)

		assert.has_errors(function()
			return parser:parse{}
		end)
	end)

	it("passes in project files", function()
		assert.same(
			{project = 'my_project', template = 'love'},
			parser:parse{'my_project'})

		assert.same(
			{project = 'your_project', template = 'love'},
			parser:parse{'your_project'})

		assert.same(
			{project = 'my complex name', template = 'love'},
			parser:parse{'my complex name'})
	end)

	it("changes templates", function()
		assert.same(
			{project = 'my_project', template = 'my_template'},
			parser:parse{"my_project", "--template", "my_template"})

		assert.same(
			{project = 'my_project', template = 'your_template'},
			parser:parse{"my_project", "-t", "your_template"})

		assert.same(
			{project = 'my_project', template = 'my complex template'},
			parser:parse{"my_project", "--template", "my complex template"})
	end)

	it("can manually choose a love version", function()
		assert.same(
			{project = 'my_project', template = 'love', love_version = "0.10.0"},
			parser:parse{"my_project", "--love-version", "0.10.0"})

		assert.same(
			{project = 'my_project', template = 'love', love_version = "0.8.0"},
			parser:parse{"my_project", "--love-version", "0.8.0"})
	end)
end)
