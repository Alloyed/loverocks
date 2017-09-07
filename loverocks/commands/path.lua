local fs = require 'luarocks.fs'
local log = require 'loverocks.log'

local path = {}

function path.build(parser)
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

function path.run(conf, _)
	local rocks_tree = "rocks"
	if conf and conf.rocks_tree then
		rocks_tree = conf.rocks_tree
	end

	if not fs.is_dir(rocks_tree) then
		log:error("rocks tree %q not found", rocks_tree)
	end

	local p  = {}
	local cp = {}

	add_dir(p, '.')
	add_dir(p, './' .. rocks_tree ..'/share/lua/5.1')

	add_cdir(cp, '.')
	add_cdir(cp, './' .. rocks_tree ..'/lib/lua/5.1')

	local p_str  = table.concat(p, ';')
	local cp_str = table.concat(cp, ';')

	io.write(string.format(script, p_str, cp_str))
end

return path
