local log = require 'loverocks.log'

local help = {}
help.commands = {}

function help.add_command(name, parser)
	help.commands[name] = parser
end

function help.build(parser)
	parser:description "Show the help for another command"
	parser:argument "command"
		:args("?")
		:description "the command to look up the help for"
end

function help.run(args)
	if args.command then
		local parser = help.commands[args.command]
		if not parser then
			log:error("no such command %s", args.command)
		end
		print(parser:get_help())
	else
		print(help.commands.main:get_help())
	end
end

return help
