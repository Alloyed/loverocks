local util = require 'loverocks.util'
local lfs = require 'lfs'

describe("util", function()
	-- TODO: add error cases
	it("slurp/spit/rm single files", function()
		local path = "meme"
		local data = "MEMEBOYS"

		assert(util.spit(data, path))
		assert.equal(data, util.slurp(path))
		assert(util.rm(path))
		assert.falsy(util.is_dir(path))
	end)

	it("slurp/spit/rm directories", function()
		local out  = "lr"
		local data = {
			fileA = "",
			fileB = "ABCD",
			dirA = {
				fileC = "DCBA",
				fileB = "wwww",
			}
		}

		assert(util.spit(data, out))
		assert.same(data, util.slurp(out))
		assert(util.rm(out))
		assert.falsy(util.is_dir(out))
	end)

	it("can clean paths", function()
		local HOME = util.get_home()
		assert.equal(util.clean_path("~/hi"), HOME .. "/hi")
		assert.equal(util.clean_path("/hi"), "/hi")
		assert.equal(util.clean_path("hi"), lfs.currentdir() .. "/hi")
	end)

	it("can mkdir directories", function()
		assert(util.mkdir_p("/tmp/hello_friend/okay/sure"))
		assert(util.is_dir("/tmp/hello_friend/okay/sure"))
		assert(util.rm("/tmp/hello_friend"))

		assert(util.mkdir_p("hello_friend/okay/sure"))
		assert(util.is_dir("hello_friend/okay/sure"))
		assert(util.rm("hello_friend"))
	end)
end)

