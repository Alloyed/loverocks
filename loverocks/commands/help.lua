local help = {}

function help:build(parser)
	parser:argument "command"
end

return help
