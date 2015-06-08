local lfs      = require 'lfs'
local datafile = require 'datafile'

local log    = require 'loverocks.log'
local config = require 'loverocks.config'

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
	local ftype, err = lfs.attributes(path, 'mode')
	if ftype == 'directory' then
		return slurp_dir(path)
	elseif ftype then
		return slurp_file(path)
	else
		return nil, err
	end
end

local function spit_file(str, dest)
	log:fs("spit  %s", dest)
	local file, err = io.open(dest, "w")
	if not file then return nil, err end

	local ok, err = file:write()
	if not ok then return nil, err end

	local ok, err = file:close()
	if not ok then return nil, err end

	return true
end

local function spit_dir(tbl, dest)
	log:fs("mkdir %s", dest)
	local ok, err = lfs.mkdir(dest)
	if not ok then return nil, err end

	for f, s in pairs(tbl) do
		if f ~= "." and f  ~= ".." then
			local ok, err = util.spit(s, dest .. "/" .. f)
			if not ok then return nil, err end
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
	local ftype, err = lfs.attributes(path, 'mode')
	if not ftype then return nil, err end

	if ftype == 'directory' then
		for f in lfs.dir(path) do
			if f ~= "." and f  ~= ".." then
				local fp = path .. "/" .. f
				local ok, err = util.rm(fp)
				if not ok then return nil, err end
			end
		end
	end

	return os.remove(path)
end

-- a replacement datafile.path()
function util.dpath(resource)
	-- for some reason datafile.path doesn't work
	local tmpfile, path = datafile.open(resource)
	local err = path

	if not tmpfile then
		return nil, err
	end
	tmpfile:close()

	return path
end

-- get first file matching pat
function util.get_first(path, pat)
	local ftype = lfs.attributes(path, 'mode')
	assert(ftype == 'directory', tostring(path) .. " is not a directory")
	for f in lfs.dir(path) do
		if f:match(pat) then
			return f
		end
	end
	return nil, "Not found"
end

-- like io.popen, but returns a string instead of a file
function util.stropen(cli)
	local f = io.popen(cli, 'r')
	local s = f:read('*a')
	f:close()
	return s
end

local LROCKSTR = [[
LUAROCKS_CONFIG='rocks/config.lua' %s --tree='rocks' %s
]]
function util.luarocks(...)
	local argstr = table.concat({...}, " ")
	argstr = LROCKSTR:format(config('luarocks'), argstr)
	log:fs(argstr)

	return os.execute(argstr)
end

function util.strluarocks(...)
	local argstr = table.concat({...}, " ")
	argstr = LROCKSTR:format(config('luarocks'), argstr)
	log:fs(argstr)

	return util.stropen(argstr)
end

-- produce str with magic characters escaped, for pattern-building
function util.escape_str(s)
    return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'))
end

return util
