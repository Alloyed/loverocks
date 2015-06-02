local util = require 'loverocks.util'
local lfs = require 'lfs'

print("hi")

describe("util", function()
	it("slurp <-> spit", function()
		local path = "meme"
		local data = "MEMEBOYS"
		util.spit(data, path)
		assert.equal(data, util.slurp(path))
		os.remove(path)
		assert.is_nil(io.open(path))
	end)
	it("slurp/spit directories", function()
		local out  = "lr"
		local data = {
			fileA = "",
			fileB = "ABCD",
			dirA = {
				fileC = "DCBA",
				fileB = "wwww",
			}
		}

		util.spit(data, out)
		assert.same(data, util.slurp(out))
		assert(util.rm(out))
		assert.is_nil(io.open(out))
	end)
end)

