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

lua.alias = {}

function lua:run(arg)
	local s = table.concat(arg, " ")
	os.execute("luarocks " .. s)
end

return lua
