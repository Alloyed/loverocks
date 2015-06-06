local util = require 'loverocks.util'
local lua = {}

function lua:build(parser)
	parser:description "Pass a command onto luarocks"
	parser:argument "arguments"
		:args("*")
		:description [[
The arguments to pass to luarocks.
Use `loverocks lua help` to find out more.]]
end

function lua:run(in_arg)
	local add = false
	local arg = {}
	for i, v in pairs(in_arg) do
		if v == "lua" then
			add = true
		elseif add then
			table.insert(arg, v)
		end
	end
	return util.luarocks(unpack(arg))
end

return lua
