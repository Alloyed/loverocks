local util = require 'loverocks.util'
local lua = {}

function lua:build(parser)
	parser:description "Pass a command onto luarocks"
	parser:argument "arguments"
		:args("*")
		:description([[
		The arguments to pass to luarocks.
		Use `loverocks lua help` to find out more.
		]])
end

function lua:run(arg)
	return util.luarocks(unpack(arg))
end

return lua
