local util = require 'loverocks.util'
local log = require 'loverocks.log'
local loadconf = require 'loadconf'

local Path = {}

function Path.build(parser)
	parser:description(
		"Generates a script to set LUA_PATH to match the current project's path. " ..
		"This can be used to test scripts and path outside of LOVE.")
end


local script = [[
export LUA_PATH='%s'
export LUA_CPATH='%s'
]]

local function add_dir(t, d)
	table.insert(t, d .. '/?.lua')
	table.insert(t, d .. '/?/init.lua')
end

local function add_cdir(t, d)
	if require('loverocks.os') == 'unix' then
		table.insert(t, d .. '/?.so')
	else
		table.insert(t, d .. '/?.dll')
	end
end

function Path.run()
	local rocks_tree = "rocks"
	local conf = loadconf.parse_file("./conf.lua")
	if conf and conf.rocks_tree then
		rocks_tree = conf.rocks_tree
	end

	if not util.is_dir(rocks_tree) then
		log:error("rocks tree %q not found", rocks_tree)
	end

	local path  = {}
	local cpath = {}

	add_dir(path, '.')
	add_dir(path, './' .. rocks_tree ..'/share/lua/5.1')

	add_cdir(cpath, '.')
	add_cdir(cpath, './' .. rocks_tree ..'/lib/lua/5.1')

	local path_str  = table.concat(path, ';')
	local cpath_str = table.concat(cpath, ';')

	print(string.format(script, path_str, cpath_str))
end

return Path
