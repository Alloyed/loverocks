local lfs = require 'lfs'
local log = require 'loverocks.log'
local util = {}

local function slurp_file(fname)
	local file, err = io.open(fname, 'r')
	assert(file, err)
	local s = file:read('*a')
	file:close()
	return s
end

local function slurp_dir(dir)
	local t = {}

	for f in lfs.dir(dir) do
		if f ~= "." and f  ~= ".." then
			t[f] = util.slurp(dir .. "/" .. f)
		end
	end

	return t
end

function util.slurp(path)
	local ftype = lfs.attributes(path, 'mode')
	if ftype == 'directory' then
		return slurp_dir(path)
	else
		return slurp_file(path)
	end
end

local function spit_file(str, dest)
	log:fs("spit  %s", dest)
	local file, err = io.open(dest, "w")
	if not file then
		return nil, err
	end

	assert(file:write(str))
	assert(file:close())
	return true
end

local function spit_dir(tbl, dest)
	log:fs("mkdir %s", dest)
	lfs.mkdir(dest)
	for f, s in pairs(tbl) do
		if f ~= "." and f  ~= ".." then
			local ok, err = util.spit(s, dest .. "/" .. f)
			if not ok then
				return nil, err
			end
		end
	end

	return true
end

-- Keep getting the argument order mixed up
function util.spit(o, dest)
	if type(o) == 'table' then
		return spit_dir(o, dest)
	else
		return spit_file(o, dest)
	end
end

function util.rm(path)
	log:fs("rm -r %s", path)
	local ftype = lfs.attributes(path, 'mode')
	if ftype == 'directory' then
		for f in lfs.dir(path) do
			if f ~= "." and f  ~= ".." then
				local fp = path .. "/" .. f
				local ok, err = util.rm(fp)
				if not ok then
					return nil, err
				end
			end
		end
	end

	return os.remove(path)
end

function util.luarocks(...)
	local argstr = "luarocks --tree='rocks' " .. table.concat({...}, " ")
	log:fs(argstr)

	return os.execute(argstr)
end

return util
