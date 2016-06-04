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

function help.run(_, args)
	if args.command then
		local parser = help.commands[args.command]
		if not parser then
			log:error("no such command %s", args.command)
		end
		io.write(parser:get_help().."\n")
	else
		io.write(help.commands.main:get_help().."\n")
	end
end

return help
