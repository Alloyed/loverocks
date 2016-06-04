-- Monkeypatched loadconf.
-- Why am I patching my own library? because!

local _loadconf = require 'loadconf'
local loadconf = {}
for k, v in pairs(_loadconf) do
	loadconf[k] = v
end

local lfs   = require 'lfs'

local util  = require 'loverocks.util'
local unzip = require 'loverocks.unzip'

-- Simple shallow merge.
-- New values replace old, so base[k] == new[k] for every k in new
local function merge(base, new)
	for k, v in pairs(new) do
		base[k] = v
	end

	return true -- Mutates!
end

local function load_dir(dir)
	local conf = {}

	local base_conf, err = loadconf.parse_file(dir .. "/conf.lua")
	if not base_conf then return base_conf, err end

	merge(conf, base_conf)

	return conf
end

local function load_archive(fname)
	local conf = {}

	local body, err = unzip.read(fname, "conf.lua")
	if not body then return nil, err end

	local base_conf
	base_conf, err = loadconf.parse_string(body)

	if not base_conf then return base_conf, err end

	merge(conf, base_conf)

	return conf
end

-- builds and returns a loadconf table.
-- This is on a best-effort basis. If we can't find any config then we return
-- an empty table
function loadconf.require(...)
	assert(select('#', ...) == 1) -- ensure src was passed in
	local src = ...
	
	if src == nil then
		src = lfs.currentdir() -- game source is the working dir
	end

	src = util.clean_path(src)

	if not loadconf._config then
		local conf, err = nil, tostring(src) .. " is not a file or directory"
		if util.is_file(src) then
			conf, err = load_archive(src)
		elseif util.is_dir(src) then
			conf, err = load_dir(src)
		end

		if not conf then
			conf = {_loverocks_no_config = err}
		end

		loadconf._config = conf
	end

	return loadconf._config
end

return loadconf
