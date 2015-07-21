local lfs      = require 'lfs'
local datafile = require 'datafile'

local log    = require 'loverocks.log'

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
			t[f] = assert(util.slurp(dir .. "/" .. f))
		end
	end

	return t
end

function util.is_dir(path)
	return lfs.attributes(path, 'mode') == 'directory'
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

	local ok, err = file:write(str)
	if not ok then return nil, err end

	local ok, err = file:close()
	if not ok then return nil, err end

	return true
end

local function spit_dir(tbl, dest)
	log:fs("mkdir %s", dest)
	if not util.is_dir(dest) then
		local ok, err = lfs.mkdir(dest)
		if not ok then return nil, err end
	end

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
		return assert(spit_file(o, dest))
	end
end

function util.get_home()
    return (os.getenv("HOME") or os.getenv("USERPROFILE"))
end

function util.clean_path(path)
	if path:match("^%~/") then
		path = path:gsub("^%~/", util.get_home() .. "/")
	end
	if not path:match("^/") and not path:match("%./") then
		path = lfs.currentdir()  .. "/" .. path
	end
	return path
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

function util.exists(path)
	local f, err = io.open(path, 'r')
	if f then
		f:close()
		return true
	end
	return nil, err
end

-- a replacement datafile.path()
function util.dpath(resource)
	-- for some reason datafile.path doesn't work
	local tmpfile, path = datafile.open(resource, 'r')
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

-- produce str with magic characters escaped, for pattern-building
function util.escape_str(s)
	return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'))
end

function util.mkdir_p(directory)
	directory = util.clean_path(directory)
	local path = nil
	if directory:sub(2, 2) == ":" then
		path = directory:sub(1, 2)
		directory = directory:sub(4)
	else
		if directory:match("^/") then
			path = ""
		end
	end
	for d in directory:gmatch("([^".."/".."]+)".."/".."*") do
		path = path and path .. "/" .. d or d
		local mode = lfs.attributes(path, "mode")
		if not mode then
			local ok, err = lfs.mkdir(path)
			if not ok then
				return false, err
			end
			elseif mode ~= "directory" then
				return false, path.." is not a directory"
			end
		end
		return true
end

return util
