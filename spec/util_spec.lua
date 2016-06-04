require 'spec.test_config'()
local util = require 'loverocks.util'
local spec_util = require 'spec.util'
local lfs  = require 'lfs'

describe("util", function()
	-- TODO: add error cases
	it("slurp/spit/rm single files", function()
		local path = "meme"
		local data = "MEMEBOYS"

		assert(util.spit(data, path))
		assert.equal(data, util.slurp(path))
		assert(spec_util.rm(path))
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
				dirB = {
					fileD = "ADS",
					fileE = "ASD",
				}
			}
		}
		assert(util.spit(data, out))
		assert.same(data, util.slurp(out))
		assert(spec_util.rm(out))
		assert.falsy(util.is_dir(out))
	end)

	it("can list directories", function()
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

		local function set(a)
			local t = {}
			for _, n in ipairs(a) do
				t[n] = true
			end
			return t
		end

		assert(util.spit(data, out))
		assert.equal("lr/fileB", util.files("lr/fileB"))
		assert.same(set {
			"lr/dirA/dirB/fileE",
			"lr/dirA/dirB/fileD",
		}, set(util.files("lr/dirA/dirB")))
		assert.same(set {
			"lr/fileB",
			"lr/dirA/fileB",
			"lr/dirA/fileC",
			"lr/dirA/dirB/fileE",
			"lr/dirA/dirB/fileD",
			"lr/fileA"
		}, set(util.files(out)))
		assert(spec_util.rm(out))
		assert.falsy(util.is_dir(out))
	end)

	it("can clean paths", function()
		local HOME = util.get_home()
		assert.equal(util.clean_path("~/hi"), HOME .. "/hi")
		assert.equal(util.clean_path("/hi"), "/hi")
		assert.equal(util.clean_path("hi"), lfs.currentdir() .. "/hi")
	end)

end)

