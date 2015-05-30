local lua = {}

function lua:build(parser)
	parser:description "Pass a command onto luarocks"
end

lua.alias = {}

return lua
