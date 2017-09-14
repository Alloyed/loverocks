require 'spec.test_config'()
local util = require 'loverocks.util'
local fs  = require 'luarocks.fs'

describe("util", function()
	-- TODO: add error cases
	it("slurp/spit single files", function()
		local path = "meme"
		local data = "MEMEBOYS"

		assert(util.spit(data, path))
		assert.equal(data, util.slurp(path))

		fs.delete(path)
		assert.falsy(fs.is_dir(path))
	end)

	it("slurp/spit directories", function()
		local out  = "lr"
		local data = {
			fileA = "",
			fileB = "ABCD",
			dirA = {
				fileC = "DCBA",
				fileB = "wwww",
				dirB = {
					fileD = "ADS",
					fileE = "ASD",
				}
			}
		}
		assert(util.spit(data, out))
		assert.same(data, util.slurp(out))

		fs.delete(out)
		assert.falsy(fs.is_dir(out))
	end)

	it("can clean paths", function()
		local HOME = util.get_home()
		assert.equal(util.clean_path("~/hi"), HOME .. "/hi")
		assert.equal(util.clean_path("/hi"), "/hi")
		assert.equal(util.clean_path("hi"), fs.current_dir() .. "/hi")
	end)

end)
