local log = require 'loverocks.log'

local help = {}
help.commands = {}

function help.add_command(name, command)
	help.commands[name] = command
end

function help.build(parser)
	parser:description "Show the help for another command"
	parser:argument "command"
		:args("?")
		:description "the command to look up the help for"
end

function help.run(args)
	local command = args.command

	if command then
		local cmd = help.commands[command]
		if not cmd then
			log:error("no such command %s", command)
		end
		print(cmd:get_help())
	else
		print(help.commands.main:get_help())
	end
end

return help
