local fs = require 'luarocks.fs'
local T   = require 'loverocks.schema'
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

	for f in fs.dir(dir) do
		t[f] = assert(util.slurp(dir .. "/" .. f))
	end

	return t
end

function util.slurp(path)
	T(path, 'string')

	if fs.is_dir(path) then
		return slurp_dir(path)
	elseif fs.is_file(path) then
		return slurp_file(path)
	else
		return nil, 'The path provided is neither a directory nor a file'
	end
end

local function spit_file(str, dest)
	local file, ok, err
	log:fs("spit %s", dest)
	file, err = io.open(dest, "w")
	if not file then return nil, err end

	ok, err = file:write(str)
	if not ok then return nil, err end

	ok, err = file:close()
	if not ok then return nil, err end

	return true
end

local function spit_dir(tbl, dest)
	log:fs("mkdir %s", dest)
	if not fs.is_dir(dest) then
		local ok, err = fs.make_dir(dest)
		if not ok then return nil, err end
	end

	for f, s in pairs(tbl) do
		if f ~= "." and f ~= ".." then
			local ok, err = util.spit(s, dest .. "/" .. f)
			if not ok then return nil, err end
		end
	end

	return true
end

-- Keep getting the argument order mixed up
function util.spit(o, dest)
	T(o, T.sum('table', 'string'))
	T(dest, 'string')

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
	T(path, 'string')

	if path:match("^%~/") then
		path = path:gsub("^%~/", util.get_home() .. "/")
	end
	if not path:match("^/") and   -- /my-file
	   not path:match("^%./") and -- ./my-file
	   not path:match("^%a:") then -- C:\my-file
		path = fs.current_dir() .. "/" .. path
	end
	return path
end

return util
