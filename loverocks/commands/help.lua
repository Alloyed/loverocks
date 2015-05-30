local log = require 'loverocks.log'

local help = {}
help.commands = {}

function help:add_command(name, command)
	self.commands[name] = command
end

function help:build(parser)
	parser:description "Show the help for another command"
	parser:argument "command"
		:args("?")
		:description "the command to look up the help for"
end

function help:run(args)
	local command = args.command

	if command then
		local cmd = self.commands[command]
		if not cmd then
			log:error("no such command %s", command)
		end
		print(cmd:get_help())
	else
		print(self.commands.main:get_help())
	end
end

return help
