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
		assert.is_nil(io.open(path))
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
		assert.is_nil(io.open(out))
	end)
end)

