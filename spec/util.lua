local lfs = require 'lfs'
local T   = require 'loverocks.schema'
local log = require 'loverocks.log'

local util = {}

function util.rm(path)
	T(path, 'string')

	local ftype, ok, err
	ftype, err = lfs.attributes(path, 'mode')
	if not ftype then return nil, err end

	if ftype == 'directory' then
		for f in lfs.dir(path) do
			if f ~= "." and f ~= ".." then
				local fp = path .. "/" .. f
				ok, err = util.rm(fp)
				if not ok then return nil, err end
			end
		end
	end

	log:fs("rm %s", path)
	return os.remove(path)
end

return setmetatable(util, {__index = require 'loverocks.util'})
