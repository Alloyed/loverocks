local argparse = require 'loverocks.argparse'
local commands = require 'loverocks.commands'
local log      = require 'loverocks.log'

local function main(...)
	local version = "Loverocks " .. (require 'loverocks.version')

	local parser = argparse "loverocks" {
		description = version .. ", a wrapper to make luarocks and love play nicely.",
	}
	local help = commands.modules.help
	help:add_command("main", parser)

	for _, name in pairs(commands.names) do
		local cmd = commands.modules[name]
		local cmd_parser = parser:command(name)

		help:add_command(name, cmd_parser)
		cmd:build(cmd_parser)
	end

	parser:flag "--version"
		:description "Print version info."
		:action(function()
			print(version)
			os.exit(0)
		end)
	parser:flag "-v" "--verbose"
		:description "Use verbose output."
		:action(function()
			log:verbose()
		end)
	parser:flag "-q" "--quiet"
		:description "Suppress output. also enables -c"
		:action(function()
			log:quiet()
		end)
	parser:flag "-c" "--confirm"
		:description "Confirm without prompting. useful for scripts."
		:action(function()
			log.use.ask = false
		end)

	local B = parser:parse{...}

	for name, cmd in pairs(commands.modules) do
		if B[name] then
			return cmd:run(B)
		end
	end
end

return main
