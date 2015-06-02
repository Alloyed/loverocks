local util = require 'loverocks.util'
describe("loverocks new", function()
	local New = require 'loverocks.commands.new'
	it("can be used by API", function()
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
		local f = assert(io.open("my-project"))
		assert(util.rm("my-project"))
	end)

	it("gives deterministic results", function()
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
		util.spit((util.slurp("my-project")), "my-projectB")
		assert(util.rm("my-project"))
		New:run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}

		assert.same(util.slurp("my-project"), util.slurp("my-projectB"))
		assert(util.rm("my-projectB"))
		assert(util.rm("my-project"))
	end)
end)
