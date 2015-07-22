local util = require 'loverocks.util'
local log = require 'loverocks.log'
local config = require 'loverocks.config'

local lua = {}

function lua:build(parser)
	parser:description "Pass a command onto luarocks"
	parser:handle_options(false)
	parser:argument "arguments"
		:args("*")
		:description [[
The arguments to pass to luarocks.
Use `loverocks lua help` to find out more.]]
end

function lua:run(arg)
	return lua.luarocks(arg.arguments)
end

local WIN_LROCKSTR = [[
set LUAROCKS_CONFIG="rocks/config.lua"
%s --tree "rocks" %s]]

local LROCKSTR = [[
LUAROCKS_CONFIG='rocks/config.lua' %s --tree='rocks' %s]]

function lua.luarocks(a)
	local argstr = table.concat(a, " ")
	if require('loverocks.os') == "windows" then
		error("This command is not yet supported on windows, sorry~")
		argstr = WIN_LROCKSTR:format(config('luarocks'), argstr)
	else
		argstr = LROCKSTR:format(config('luarocks'), argstr)
	end
	log:fs("%s", argstr)

	local f = io.popen(argstr)
	for l in f:lines() do
		log:info("%s", l)
	end

	return 0
end

function lua.strluarocks(...)
	local argstr = table.concat({...}, " ")
	argstr = LROCKSTR:format(config('luarocks'), argstr)
	log:fs("%s", argstr)

	return util.stropen(argstr)
end

return lua
